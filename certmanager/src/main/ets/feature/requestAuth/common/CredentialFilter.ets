/**
 * Copyright (c) 2026-2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { CredentialAbstractVo } from '../../../model/CertManagerVo/CredentialAbstractVo';
import Logger from '../../../common/util/Logger';
import CertManager from '@ohos.security.certManager';
import { cert } from '@kit.DeviceCertificateKit';

/**
 * CertChainProvider负责查询凭据详情，获取证书链
 * 若新增凭据类型，需要新增该抽象类的实现
 */
export abstract class CertChainProvider {
  async getCertChain(credential: CredentialAbstractVo): Promise<cert.X509CertChain> {
    return new Promise<cert.X509CertChain>(async (resolve, reject) => {
      try {
        let chainData: Uint8Array = await this.getCertChainData(credential) ?? new Uint8Array();

        let encodingBlob: cert.EncodingBlob = {
          data: chainData,
          encodingFormat: cert.EncodingFormat.FORMAT_PEM
        };
        let certChain = await cert.createX509CertChain(encodingBlob);
        return resolve(certChain);
      } catch (err) {
        return reject(err);
      }
    })
  }

  abstract getCertChainData(credential: CredentialAbstractVo): Promise<Uint8Array | undefined>;
}

/**
 * 过滤器负责过滤证书链
 * 若有新增条件，需要新增该接口的实现类
 */
export interface ICertificateFilter {
  filter(certChain: cert.X509CertChain): Promise<boolean>;
}

/**
 * 原始过滤条件
 */
export class CredentialFilterCriteria {
  public keyAlgIds: string[] = [];
  public issuers: Uint8Array[] = [];

  public withKeyAlgorithms(keyAlgIds: string[]): CredentialFilterCriteria {
    this.keyAlgIds = keyAlgIds;
    return this;
  }

  public withIssuers(issuers: Uint8Array[]): CredentialFilterCriteria {
    this.issuers = issuers;
    return this;
  }

  public isEmpty(): boolean {
    return this.keyAlgIds.length === 0 && this.issuers.length === 0;
  }
}

/**
 * 密钥算法过滤器
 */
export class KeyAlgorithmFilter implements ICertificateFilter {
  private static readonly RSA_OID: string = '1.2.840.113549.1.1.1';
  private static readonly EC_OID: string = '1.2.840.10045.2.1';
  private static readonly SUPPORTED_ALGORITHMS: Set<string> = new Set(['RSA', 'EC', 'ECDSA']);
  private static readonly TAG: string = 'KeyAlgorithmFilter';
  private logger: Logger = new Logger(KeyAlgorithmFilter.TAG);

  private oidSet: Set<string>;

  constructor(keyAlgIds: string[]) {
    this.oidSet = this.mapAlgorithmsToOids(keyAlgIds);
  }

  private mapAlgorithmsToOids(keyAlgIds: string[]): Set<string> {
    const oidSet: Set<string> = new Set();
    /**
     * 把算法名称映射为OID。如果过滤的算法列表中有不支持的算法，则不进行算法过滤
     */
    for (const alg of keyAlgIds) {
      if (!KeyAlgorithmFilter.SUPPORTED_ALGORITHMS.has(alg)) {
        return new Set();
      }
      if (alg === 'RSA') {
        oidSet.add(KeyAlgorithmFilter.RSA_OID);
      } else if (alg === 'EC' || alg === 'ECDSA') {
        oidSet.add(KeyAlgorithmFilter.EC_OID);
      }
    }
    return oidSet;
  }

  public async filter(certChain: cert.X509CertChain): Promise<boolean> {
    if (this.oidSet.size === 0) {
      return Promise.resolve<boolean>(true);
    }
    return this.checkCertAlgorithm(certChain);
  }

  private async checkCertAlgorithm(certChain: cert.X509CertChain): Promise<boolean> {
    return new Promise<boolean>((resolve, reject) => {
      try {
        this.logger.warn('enter checkCertAlgorithm');
        const certs = certChain.getCertList();

        if (certs.length === 0) {
          this.logger.warn('Certificate chain is empty');
          return resolve(false);
        }

        const firstCert: cert.X509Cert = certs[0];
        for (let keyAlgOid of this.oidSet) {
          this.logger.info(`pubKeyAlgName: ${firstCert.getSignatureAlgOid()}, match keyAlgOid: ${keyAlgOid}`);
          if (firstCert.match({ publicKeyAlgID: keyAlgOid })) {
            this.logger.info(`match keyAlgOid success.`);
            return resolve(true);
          }
        }
        return resolve(false);
      } catch (err) {
        this.logger.error('Failed to parse certificate for algorithm check: %{public}s', JSON.stringify(err));
        return reject(err);
      }
    })
  }
}

/**
 * 颁发者过滤器
 */
export class IssuerFilter implements ICertificateFilter {
  private issuers: Uint8Array[];
  private static readonly TAG: string = 'IssuerFilter';
  private logger: Logger = new Logger(IssuerFilter.TAG);

  constructor(issuers: Uint8Array[]) {
    this.issuers = issuers;
  }

  public async filter(certChain: cert.X509CertChain): Promise<boolean> {
    if (this.issuers.length === 0) {
      return Promise.resolve<boolean>(true);
    }
    return this.checkCertIssuer(certChain);
  }

  private checkCertIssuer(certChain: cert.X509CertChain): Promise<boolean> {
    try {
      const certs = certChain.getCertList();
      if (certs === undefined || certs.length === 0) {
        return Promise.resolve<boolean>(false);
      }

      /**
       * 匹配叶子证书的颁发者
       */
      for (const targetIssuer of this.issuers) {
        if (certs[0].match({ issuer: targetIssuer })) {
          return Promise.resolve<boolean>(true);
        }
      }
      /**
       * 匹配证书链的主题
       */
      for (const cert of certs) {
        for (const targetIssuer of this.issuers) {
          if (cert.match({ subject: targetIssuer, matchAllSubjectAltNames: true })) {
            return Promise.resolve<boolean>(true);
          }
        }
      }

      return Promise.resolve<boolean>(false);
    } catch (err) {
      this.logger.error('Failed to parse certificate for issuer check: %{public}s', JSON.stringify(err));
      return Promise.reject(err);
    }
  }
}

/**
 * 过滤器链
 */
export class CompositeCertificateFilter implements ICertificateFilter {
  private filters: ICertificateFilter[] = [];
  private static readonly TAG: string = 'CompositeCertificateFilter';
  private logger: Logger = new Logger(CompositeCertificateFilter.TAG);

  public addFilter(filter: ICertificateFilter): CompositeCertificateFilter {
    this.filters.push(filter);
    return this;
  }

  public async filter(certChain: cert.X509CertChain): Promise<boolean> {
    return new Promise<boolean>(async (resolve, reject) => {
      try {
        for (let filter of this.filters) {
          if (!await filter.filter(certChain)) {
            return resolve(false);
          }
        }
        return resolve(true);
      } catch (err) {
        this.logger.error(`Failed to filter certChain, code: ${err?.code}, message: ${err?.message}`);
        reject(err);
      }
    });
  }
}

/**
 * 公共凭据证书链提供者
 */
export class PublicCredentialCertChainProvider extends CertChainProvider {
  private static readonly TAG: string = 'PublicCredentialCertChainProvider';
  private logger: Logger = new Logger(PublicCredentialCertChainProvider.TAG);

  public async getCertChainData(credential: CredentialAbstractVo): Promise<Uint8Array | undefined> {
    try {
      const result: CertManager.CMResult = await CertManager.getPublicCertificate(credential.keyUri);
      if (result.credential?.credentialData) {
        this.logger.info(`getPublicCertificate success`)
        return result.credential.credentialData;
      }
      return undefined;
    } catch (err) {
      this.logger.error('Failed to get cert chain for public credential: %{public}s', JSON.stringify(err));
      return undefined;
    }
  }
}

/**
 * 私有凭据证书链提供者
 */
export class PrivateCredentialCertChainProvider extends CertChainProvider {
  private static readonly TAG: string = 'PrivateCredentialCertChainProvider';
  private logger: Logger = new Logger(PrivateCredentialCertChainProvider.TAG);

  public async getCertChainData(credential: CredentialAbstractVo): Promise<Uint8Array | undefined> {
    try {
      const result: CertManager.CMResult = await CertManager.getPrivateCertificate(credential.keyUri);
      if (result.credential?.credentialData) {
        return result.credential.credentialData;
      }
      return undefined;
    } catch (err) {
      this.logger.error('Failed to get cert chain for private credential: %{public}s', JSON.stringify(err));
      return undefined;
    }
  }
}

/**
 * Ukey证书链提供者
 */
export class UkeyCredentialCertChainProvider extends CertChainProvider {
  private static readonly TAG: string = 'UkeyCredentialCertChainProvider';
  private logger: Logger = new Logger(UkeyCredentialCertChainProvider.TAG);

  constructor() {
    super();
  }

  public async getCertChainData(credential: CredentialAbstractVo): Promise<Uint8Array | undefined> {
    try {
      return credential.credData;
    } catch (err) {
      this.logger.error('Failed to get cert chain for ukey credential: %{public}s', JSON.stringify(err));
      return undefined;
    }
  }
}

/**
 * 证书过滤器，负责控制整体的过滤流程
 */
export class CredentialFilter {
  private static readonly TAG: string = 'CredentialFilter';
  private static instance: CredentialFilter;
  private logger: Logger = new Logger(CredentialFilter.TAG);

  private constructor() {}

  public static getInstance(): CredentialFilter {
    if (!CredentialFilter.instance) {
      CredentialFilter.instance = new CredentialFilter();
    }
    return CredentialFilter.instance;
  }

  public async filterCredentials(
    credentials: CredentialAbstractVo[],
    criteria: CredentialFilterCriteria,
    certChainProvider: CertChainProvider
  ): Promise<CredentialAbstractVo[]> {
    if (criteria.isEmpty()) {
      return credentials;
    }

    const filter = this.buildFilter(criteria);
    const filteredCredentials: CredentialAbstractVo[] = [];

    for (const credential of credentials) {
      try {
        const certChain = await certChainProvider.getCertChain(credential);
        if (certChain && await filter.filter(certChain)) {
          filteredCredentials.push(credential);
        }
      } catch (err) {
        this.logger.warn('Failed to process credential: %{public}s', JSON.stringify(err));
      }
    }

    return filteredCredentials;
  }

  private buildFilter(criteria: CredentialFilterCriteria): CompositeCertificateFilter {
    const compositeFilter = new CompositeCertificateFilter();

    if (criteria.keyAlgIds.length > 0) {
      compositeFilter.addFilter(new KeyAlgorithmFilter(criteria.keyAlgIds));
    }

    if (criteria.issuers.length > 0) {
      compositeFilter.addFilter(new IssuerFilter(criteria.issuers));
    }

    return compositeFilter;
  }
}

/**
 * 过滤器建造者类，简化CredentialFilter的使用
 */
export class CredentialFilterBuilder {
  private criteria: CredentialFilterCriteria = new CredentialFilterCriteria();
  private certChainProvider: CertChainProvider | null = null;

  public withKeyAlgorithms(keyAlgIds: string[]): CredentialFilterBuilder {
    this.criteria.withKeyAlgorithms(keyAlgIds);
    return this;
  }

  public withIssuers(issuers: Uint8Array[]): CredentialFilterBuilder {
    this.criteria.withIssuers(issuers);
    return this;
  }

  public withCertChainProvider(provider: CertChainProvider): CredentialFilterBuilder {
    this.certChainProvider = provider;
    return this;
  }

  public async filter(credentials: CredentialAbstractVo[]): Promise<CredentialAbstractVo[]> {
    if (!this.certChainProvider) {
      throw new Error('CertChainProvider must be set before filtering');
    }
    return CredentialFilter.getInstance().filterCredentials(credentials, this.criteria, this.certChainProvider);
  }
}
