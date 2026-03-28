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

import Logger from '../../../common/util/Logger';
import { RequestAuthPageVersion } from '../common/Constants';
import certMgrDialog from '@ohos.security.certManagerDialog';
import certMgr from '@ohos.security.certManager'
import { CredentialFilterBuilder,
  PrivateCredentialCertChainProvider,
  PublicCredentialCertChainProvider,
  UkeyCredentialCertChainProvider
} from '../common/CredentialFilter';
import { StringUtil } from '../../../common/util/StringUtil';
import { SYSCAP_HUKS_CRYPTO_EXTENTION } from '../../../common/constants/CertManagerConstants';
import { CredentialAbstractVo } from '../../../model/CertManagerVo/CredentialAbstractVo';
import certMangerModel, { CMModelErrorCode, DialogErrorCode } from '../../../model/CertMangerModel';
import { util } from '@kit.ArkTS';
import bundleNameModel from '../../../model/BundleModel';

export default class RequestAuthModel {
  private _logger: Logger = new Logger('RequestAuthModel');
  private _keyAlgIds: string[] = [];

  public get keyAlgIds(): string[] {
    return this._keyAlgIds;
  }

  private _issuers: Uint8Array[] = [];

  public get issuers(): Uint8Array[] {
    return this._issuers;
  }

  private _certTypes: certMgrDialog.CertificateType[] = [];

  public get certTypes(): certMgrDialog.CertificateType[] {
    return this._certTypes;
  }

  public get logger(): Logger {
    return this._logger;
  }

  private _version: RequestAuthPageVersion = RequestAuthPageVersion.VERSION_DEFAULT;

  public get version(): RequestAuthPageVersion {
    return this._version;
  }

  private _bundleName: string = '';

  public get bundleName(): string {
    return this._bundleName;
  }

  private _appUid: number = -1;

  public get appUid(): number {
    return this._appUid;
  }

  private _appName: string = '';

  public get appName(): string {
    return this._appName;
  }

  private _selectUri: string = '';

  public get selectUri(): string {
    return this._selectUri;
  }

  private _serverUrl: string = '';

  public get serverUrl(): string {
    return this._serverUrl;
  }

  private _appPublicCredList: CredentialAbstractVo[] = [];

  public get appPublicCredList(): CredentialAbstractVo[] {
    return this._appPublicCredList;
  }

  private _appPrivateCredList: CredentialAbstractVo[] = [];

  public get appPrivateCredList(): CredentialAbstractVo[] {
    return this._appPrivateCredList;
  }

  private _ukeyCredList: CredentialAbstractVo[] = [];

  public get ukeyCredList(): CredentialAbstractVo[] {
    return this._ukeyCredList;
  }

  private _selectCertType: certMgrDialog.CertificateType = certMgrDialog.CertificateType.CREDENTIAL_USER;

  public get selectCertType(): certMgrDialog.CertificateType {
    return this._selectCertType;
  }

  private _authedUri: string = '';

  public get authedUri(): string {
    return this._authedUri;
  }

  private _ukeyPurpose: certMgr.CertificatePurpose = certMgr.CertificatePurpose.PURPOSE_DEFAULT;

  public get ukeyPurpose(): certMgr.CertificatePurpose {
    return this._ukeyPurpose;
  }

  /**
   * 添加成员变量时，此方法要相应修改
   * @returns
   */
  clone(): RequestAuthModel {
    let model = new RequestAuthModel();
    model._version = this._version;
    model._certTypes = this._certTypes;
    model._issuers = this._issuers;
    model._keyAlgIds = this._keyAlgIds;
    model._bundleName = this._bundleName;
    model._appUid = this._appUid;
    model._appName = this._appName;
    model._selectUri = this._selectUri;
    model._serverUrl = this._serverUrl;
    model._appPublicCredList = this._appPublicCredList;
    model._appPrivateCredList = this._appPrivateCredList;
    model._ukeyCredList = this._ukeyCredList;
    model._selectCertType = this._selectCertType;
    model._authedUri = this._authedUri;
    model._ukeyPurpose = this._ukeyPurpose;
    return model;
  }

  private validateCertTypes(value: object | undefined): Array<certMgrDialog.CertificateType> {
    if (value === undefined || value === null) {
      return [certMgrDialog.CertificateType.CREDENTIAL_USER];
    }
    if (!Array.isArray(value)) {
      this.logger.warn(`certTypes is not an array, using default`);
      return [certMgrDialog.CertificateType.CREDENTIAL_USER];
    }
    let validCertTypes: certMgrDialog.CertificateType[] = [];
    const allowedTypes = [
      certMgrDialog.CertificateType.CREDENTIAL_USER,
      certMgrDialog.CertificateType.CREDENTIAL_APP,
      certMgrDialog.CertificateType.CREDENTIAL_UKEY
    ];
    for (const item of value as Array<certMgrDialog.CertificateType>) {
      if (allowedTypes.includes(item)) {
        validCertTypes.push(item as certMgrDialog.CertificateType);
      }
    }
    return validCertTypes.length > 0 ? validCertTypes : [certMgrDialog.CertificateType.CREDENTIAL_USER];
  }

  private validateCertPurpose(value: object | undefined): certMgr.CertificatePurpose {
    if (value === undefined || value === null) {
      return this._ukeyPurpose;
    }
    const allowedPurposes: certMgr.CertificatePurpose[] = [
      certMgr.CertificatePurpose.PURPOSE_DEFAULT,
      certMgr.CertificatePurpose.PURPOSE_ALL,
      certMgr.CertificatePurpose.PURPOSE_SIGN,
      certMgr.CertificatePurpose.PURPOSE_ENCRYPT
    ];
    if (typeof value === 'number' && allowedPurposes.includes(value)) {
      return value as certMgr.CertificatePurpose;
    }
    this.logger.warn(`Invalid certPurpose, using default`);
    return this._ukeyPurpose;
  }

  private validateKeyAlgIds(value: object | undefined): Array<string> {
    if (value === undefined || value === null) {
      return this._keyAlgIds;
    }
    if (!Array.isArray(value)) {
      this.logger.warn(`keyAlgIds is not an array, using default`);
      return this._keyAlgIds;
    }
    let validAlgIds: string[] = [];
    const allowedAlgs = ['ECC', 'RSA', 'ECDSA'];
    for (const item of value as Array<object>) {
      if (typeof item === 'string' && allowedAlgs.includes(item)) {
        validAlgIds.push(item);
      }
    }
    return validAlgIds.length > 0 ? validAlgIds : this._keyAlgIds;
  }

  private validateIssuers(value: object | undefined): Array<Uint8Array> {
    if (value === undefined || value === null) {
      return this._issuers;
    }
    if (!Array.isArray(value)) {
      this.logger.warn(`issuers is not an array, using default`);
      return this._issuers;
    }
    let validIssuers: Uint8Array[] = [];
    for (const item of value as Array<object>) {
      if (typeof item === 'string') {
        validIssuers.push(new util.Base64Helper().decodeSync(item));
      }
    }
    return validIssuers;
  }

  private validateString(value: object | undefined, defaultValue: string): string {
    if (value === undefined || value === null) {
      return defaultValue;
    }
    if (typeof value !== 'string') {
      this.logger.warn(`check object is not a string, using default`);
      return defaultValue;
    }
    return value;
  }

  private validateNumber(value: object | undefined, defaultValue: number): number {
    if (value === undefined || value === null) {
      return defaultValue;
    }
    if (typeof value !== 'string') {
      this.logger.warn(`check object is not a number, using default`);
      return defaultValue;
    }
    return value;
  }

  public parseParams(wantParams: Record<string, object>): Promise<void> {
    return new Promise<void>(async (resolve, reject) => {
      try {
        this._bundleName = this.validateString(wantParams['bundleName'], '');
        this._appUid = this.validateNumber(wantParams['appUid'], this._appUid);
        if (wantParams['certTypes'] !== undefined) {
          this._version = RequestAuthPageVersion.VERSION_WITH_CERT_TYPES;
        }
        this._certTypes = this.validateCertTypes(wantParams['certTypes']);
        this._ukeyPurpose = this.validateCertPurpose(wantParams['certPurpose']);
        this._keyAlgIds = this.validateKeyAlgIds(wantParams['keyAlgIds']);
        this._issuers = this.validateIssuers(wantParams['issuers']);
        this._serverUrl = this.validateString(wantParams['uri'], '');
        /**
         * 获取调用方应用名
         */
        let appInfo = await bundleNameModel.getAppInfoList(this._appUid);
        this._appName = appInfo.appName;
        return resolve();
      } catch (err) {
        this.logger.error(`parse params failed, code: ${err?.code}, message: ${err?.message}`);
        return reject(err);
      }
    })
  }

  private checkHuksSyscap(credTypes: Array<certMgrDialog.CertificateType>): CMModelErrorCode {
    if (credTypes.includes(certMgrDialog.CertificateType.CREDENTIAL_USER) ||
    credTypes.includes(certMgrDialog.CertificateType.CREDENTIAL_APP)) {
      return CMModelErrorCode.CM_MODEL_ERROR_SUCCESS;
    }
    if (credTypes.includes(certMgrDialog.CertificateType.CREDENTIAL_UKEY) &&
      !canIUse(SYSCAP_HUKS_CRYPTO_EXTENTION)) {
      // When the certificate type specific only ukey,
      // an error code indicating that the device is not supported is returned.
      return CMModelErrorCode.CM_MODEL_ERROR_FAILED;
    }
    return CMModelErrorCode.CM_MODEL_ERROR_SUCCESS;
  }

  /**
   * 加载用户凭据
   * @returns
   */
  private loadUserCredential(): Promise<void> {
    if (!this._certTypes.includes(certMgrDialog.CertificateType.CREDENTIAL_USER)) {
      return Promise.resolve();
    }
    return new Promise<void>(async (resolve, reject) => {
      try {
        let credList = await certMangerModel.getAppCredList();
        this._logger.info(`credList length: ${credList.length}`);
        let provider = new PublicCredentialCertChainProvider();
        // 对结果进行过滤
        this._appPublicCredList = await new CredentialFilterBuilder()
          .withKeyAlgorithms(this._keyAlgIds)
          .withIssuers(this._issuers)
          .withCertChainProvider(provider)
          .filter(credList);
        return resolve();
      } catch (err) {
        this._logger.error(`loadUserCredential err, message: ${err?.message}, code: ${err?.code}`);
        return reject(err);
      }
    })
  }

  /**
   * 加载私有凭据
   * @returns
   */
  private loadAppPrivateCredential(): Promise<void> {
    if (!this._certTypes.includes(certMgrDialog.CertificateType.CREDENTIAL_APP)) {
      return Promise.resolve();
    }
    return new Promise<void>(async (resolve, reject) => {
      try {
        let credList = await certMangerModel.getAllAppPrivateCertificates(this._appUid);
        let provider = new PrivateCredentialCertChainProvider();
        // 对结果进行过滤
        this._appPrivateCredList = await new CredentialFilterBuilder()
          .withKeyAlgorithms(this._keyAlgIds)
          .withIssuers(this._issuers)
          .withCertChainProvider(provider)
          .filter(credList);
        return resolve();
      } catch (err) {
        this._logger.error(`loadAppPrivateCredential err, message: ${err?.message}, code: ${err?.code}`);
        return reject(err);
      }
    })
  }

  /**
   * 加载USBKey凭据
   * @returns
   */
  private loadUKeyCredential(): Promise<void> {
    if (!this._certTypes.includes(certMgrDialog.CertificateType.CREDENTIAL_UKEY)) {
      return Promise.resolve();
    }
    return new Promise<void>(async (resolve, reject) => {
      try {
        let credList = await certMangerModel.getUkeyCertificateList(this._ukeyPurpose);
        let provider = new UkeyCredentialCertChainProvider();
        // 对结果进行过滤
        this._ukeyCredList = await new CredentialFilterBuilder()
          .withKeyAlgorithms(this._keyAlgIds)
          .withIssuers(this._issuers)
          .withCertChainProvider(provider)
          .filter(credList);
        return resolve();
      } catch (err) {
        this._logger.error(`getUkeyList err, message: ${err?.message}, code: ${err?.code}`);
        return reject(err);
      }
    })
  }

  public loadCredential(): Promise<void> {
    if (this.checkHuksSyscap(this._certTypes) !== CMModelErrorCode.CM_MODEL_ERROR_SUCCESS) {
      this.logger.info(`Device unsupport syscap ${SYSCAP_HUKS_CRYPTO_EXTENTION}`);
      return Promise.reject({
        code: DialogErrorCode.DIALOG_ERROR_CAPACITY_NOT_SUPPORT,
        message: `Device unsupport syscap ${SYSCAP_HUKS_CRYPTO_EXTENTION}`
      });
    }
    return new Promise<void>(async (resolve, reject) => {
      try {
        let results = await Promise.allSettled([
          this.loadUserCredential(),
          this.loadAppPrivateCredential(),
          this.loadUKeyCredential()
        ])
        /**
         * 如果有查询结果不为空，则返回成功
         * 如果查询结果为空，并且发生了异常，返回DIALOG_ERROR_INTERNAL
         * 如果查询结果为空，并且没有发生异常：旧接口返回DIALOG_OPERATION_CANCELS，新接口版本返回DIALOG_ERROR_NO_CERTS_AVAILABLE
         */
        let credNum = this._appPublicCredList.length + this._appPrivateCredList.length +
        this._ukeyCredList.length;
        if (credNum > 0) {
          return resolve();
        }
        for (let result of results) {
          if (result.status === 'rejected') {
            this.logger.error(`An exception occurred during the loading process.`);
            return reject({ code: DialogErrorCode.DIALOG_ERROR_INTERNAL, message: `load creds error.` });
          }
        }
        /**
         * 查询结果为空，根据旧版本/新版本返回错误码
         */
        let errCode = this._version === RequestAuthPageVersion.VERSION_DEFAULT ?
          DialogErrorCode.DIALOG_OPERATION_CANCELS : DialogErrorCode.DIALOG_ERROR_NO_CERTS_AVAILABLE;
        this.logger.error(`The result is empty.`);
        return reject({ code: errCode, message: 'The result is empty.' });
      } catch (err) {
        this.logger.error(`load credentials failed, code: ${err?.code}, message: ${err?.message}`);
        return reject(err);
      }
    })
  }

  /**
   * 用户凭据授权应用
   * @returns
   */
  public grantPublicCertificate(): Promise<void> {
    return new Promise(async (resolve, reject) => {
      try {
        if (this._selectCertType === certMgrDialog.CertificateType.CREDENTIAL_APP ||
          this._selectCertType === certMgrDialog.CertificateType.CREDENTIAL_UKEY) {
          this._authedUri = this._selectUri;
          return resolve();
        }
        if (this._appUid < 0) {
          this._logger.error(`Check appUid invalid.`);
          return reject({ code: DialogErrorCode.DIALOG_ERROR_INTERNAL, message: 'Check appUid invalid.' });
        }
        let result = await certMgr.grantPublicCertificate(this._selectUri, this._appUid);
        this._authedUri = result.uri ?? '';
        return resolve();
      } catch (err) {
        this._logger.error(`Grant app to use public credential error, message: ${err?.message}, code: ${err?.code}`);
        return reject(err);
      }
    })
  }

  /**
   * 点击列表选择凭据
   * @param selectUri
   * @param selectType
   */
  public selectCredItem(selectUri: string, selectType: certMgrDialog.CertificateType): void {
    if (StringUtil.isEmpty(selectUri) || selectUri === this._selectUri) {
      return;
    }
    this._selectUri = selectUri;
    this._selectCertType = selectType;
  }
}