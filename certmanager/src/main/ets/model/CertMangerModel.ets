/**
 * Copyright (c) 2022-2024 Huawei Device Co., Ltd.
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

import { CertAbstractVo } from './CertManagerVo/CertAbstractVo';
import { CertInfoVo } from './CertManagerVo/CertInfoVo';
import { CredentialAbstractVo } from './CertManagerVo/CredentialAbstractVo';
import { CredentialVo } from './CertManagerVo/CredentialVo';
import { BusinessError } from '@ohos.base';
import CertManager from '@ohos.security.certManager';
import certMgrDialog from '@ohos.security.certManagerDialog';
import Logger from '../common/util/Logger';

export enum CMModelErrorCode {
  CM_MODEL_ERROR_SUCCESS = 0,
  CM_MODEL_ERROR_FAILED = -1,
  CM_MODEL_ERROR_EXCEPTION = -2,
  CM_MODEL_ERROR_UNKNOWN_OPT = -3,
  CM_MODEL_ERROR_NOT_SUPPORT = -4,
  CM_MODEL_ERROR_NOT_FOUND = -5,
  CM_MODEL_ERROR_INCORRECT_FORMAT = -6,
  CM_MODEL_ERROR_MAX_QUANTITY_REACHED = -7,
  CM_MODEL_ERROR_ALIAS_LENGTH_REACHED_LIMIT = -8,
  CM_MODEL_ERROR_PASSWORD_ERR = -9,
  CM_MODEL_ERROR_ADVANCED_SECURITY = -10,
}

export enum CMModelOptType {
  CM_MODEL_OPT_UNKNOWN = 0,
  CM_MODEL_OPT_SYSTEM_CA = 1,
  CM_MODEL_OPT_USER_CA = 2,
  CM_MODEL_OPT_APP_CRED = 3,
  CM_MODEL_OPT_PRIVATE_CRED = 4,
  CM_MODEL_OPT_SYSTEM_CRED = 5,
  CM_MODEL_OPT_USER_CA_P7B = 6,
}

export enum DialogErrorCode {
  DIALOG_ERROR_INTERNAL = -1000,
  DIALOG_OPERATION_CANCELS = -1001,
  DIALOG_ERROR_NOT_ENTERPRISE_DEVICE = -1003,
  DIALOG_ERROR_INCORRECT_FORMAT = -1005,
  DIALOG_ERROR_MAX_QUANTITY_REACHED = -1006,
  DIALOG_ERROR_SA_INTERNAL_ERROR = -1007,
  DIALOG_ERROR_PARAM_INVALID = -1010,
  DIALOG_ERROR_CAPACITY_NOT_SUPPORT = -1012,
  DIALOG_ERROR_NO_CERTS_AVAILIBLE = -1013,
}

export enum CmDialogOperationType {
  INSTALL = 1,
  UNINSTALL = 2,
  SHOWDETAIL = 3
}

export enum CertManagerStore {
  /* credential certificate store for end entity certificates. */
  CERT_MANAGER_CREDENTIAL_STORE = 0,
  /* read only, updated by system only. */
  CERT_MANAGER_SYSTEM_TRUSTED_STORE = 1,
  /* modifiable by applications and user. */
  CERT_MANAGER_USER_TRUSTED_STORE = 2,
  /* application specific trusted certificate store; modifiable by the application only. */
  CERT_MANAGER_APPLICATION_TRUSTED_STORE = 3,
}

const logger: Logger = new Logger('CertMangerModel');

export class CertMangerModel {
  getCertOrCredList(optType: CMModelOptType, callback: Function): void {
    logger.info('getCertOrCredList start');

    switch (optType) {
      case CMModelOptType.CM_MODEL_OPT_SYSTEM_CA:
        this.getSystemTrustedCertificateList((errCode: CMModelErrorCode, certList: Array<CertAbstractVo>) => {
          callback(errCode, certList);
        });
        break;
      case CMModelOptType.CM_MODEL_OPT_USER_CA:
        this.getAllUserTrustedCertificates((errCode: CMModelErrorCode, certList: Array<CertAbstractVo>) => {
          callback(errCode, certList);
        });
        break;
      case CMModelOptType.CM_MODEL_OPT_APP_CRED:
        this.getAppCredList((errCode: CMModelErrorCode, credList: Array<CredentialAbstractVo>) => {
          callback(errCode, credList);
        });
        break;
      case CMModelOptType.CM_MODEL_OPT_SYSTEM_CRED:
        this.getSystemCredList((errCode: CMModelErrorCode, credList: Array<CredentialAbstractVo>) => {
          callback(errCode, credList)
        })
	break;
      default:
        callback(CMModelErrorCode.CM_MODEL_ERROR_UNKNOWN_OPT, undefined);
        break;
    }
  }

  getCertOrCred(optType: CMModelOptType, uri: string, callback: Function): void {
    logger.info('getCertOrCred start');

    switch (optType) {
      case CMModelOptType.CM_MODEL_OPT_SYSTEM_CA:
        this.getSystemTrustedCertificate(uri, (errCode: CMModelErrorCode, certInfo: CertInfoVo) => {
          callback(errCode, certInfo);
        });
        break;
      case CMModelOptType.CM_MODEL_OPT_USER_CA:
        this.getUserTrustedCertificate(uri, (errCode: CMModelErrorCode, certInfo: CertInfoVo) => {
          callback(errCode, certInfo);
        });
        break;
      case CMModelOptType.CM_MODEL_OPT_APP_CRED:
        this.getAppCredential(uri, (errCode: CMModelErrorCode, credInfo: CredentialVo) => {
          callback(errCode, credInfo);
        });
        break;
      case CMModelOptType.CM_MODEL_OPT_SYSTEM_CRED:
        this.getSystemCredential(uri, (errCode: CMModelErrorCode, credInfo: CredentialVo) => {
          callback(errCode, credInfo)
        })
        break;
      default:
        callback(CMModelErrorCode.CM_MODEL_ERROR_UNKNOWN_OPT, undefined);
        break;
    }
  }

  deleteCertOrCred(optType: CMModelOptType, uri: string, callback: Function): void {
    logger.info('deleteCertOrCred start');

    switch (optType) {
      case CMModelOptType.CM_MODEL_OPT_USER_CA:
        this.deleteUserTrustedCertificate(uri, (errCode: CMModelErrorCode) => {
          callback(errCode);
        });
        break;
      case CMModelOptType.CM_MODEL_OPT_APP_CRED:
        this.deleteAppCredential(uri, (errCode: CMModelErrorCode) => {
          callback(errCode);
        });
        break;
      case CMModelOptType.CM_MODEL_OPT_SYSTEM_CA:
        callback(CMModelErrorCode.CM_MODEL_ERROR_NOT_SUPPORT);
      case CMModelOptType.CM_MODEL_OPT_SYSTEM_CRED:
        this.deleteSystemCredential(uri, (errCode: CMModelErrorCode) => {
          callback(errCode)
        })
        break;
      default:
        callback(CMModelErrorCode.CM_MODEL_ERROR_UNKNOWN_OPT);
        break;
    }
  }

  setCertStatus(optType: CMModelOptType, uri: string, status: boolean, callback: Function): void {
    logger.info('setCertStatus start');

    switch (optType) {
      case CMModelOptType.CM_MODEL_OPT_USER_CA:
        this.setCertificateStatus(uri, CertManagerStore.CERT_MANAGER_USER_TRUSTED_STORE, status,
          (errCode: CMModelErrorCode) => {
          callback(errCode);
        });
        break;
      case CMModelOptType.CM_MODEL_OPT_SYSTEM_CA:
        this.setCertificateStatus(uri, CertManagerStore.CERT_MANAGER_SYSTEM_TRUSTED_STORE, status,
          (errCode: CMModelErrorCode) => {
          callback(errCode);
        });
        break;
      case CMModelOptType.CM_MODEL_OPT_APP_CRED:
      case CMModelOptType.CM_MODEL_OPT_SYSTEM_CRED:
        callback(CMModelErrorCode.CM_MODEL_ERROR_NOT_SUPPORT);
        break;
      default:
        callback(CMModelErrorCode.CM_MODEL_ERROR_UNKNOWN_OPT);
        break;
    }
  }

  delAllCertOrCred(optType: CMModelOptType, callback: Function): void {
    logger.info('delAllCertOrCred start');

    switch (optType) {
      case CMModelOptType.CM_MODEL_OPT_USER_CA:
        this.delAllUserCertificate((errCode: CMModelErrorCode) => {
          callback(errCode);
        });
        break;
      case CMModelOptType.CM_MODEL_OPT_APP_CRED:
        this.delAllAppCredential((errCode: CMModelErrorCode) => {
          callback(errCode);
        });
        break;
      case CMModelOptType.CM_MODEL_OPT_SYSTEM_CA:
      case CMModelOptType.CM_MODEL_OPT_SYSTEM_CRED:
        callback(CMModelErrorCode.CM_MODEL_ERROR_NOT_SUPPORT);
        break;
      default:
        callback(CMModelErrorCode.CM_MODEL_ERROR_UNKNOWN_OPT);
        break;
    }
  }

  getAuthAppList(optType: CMModelOptType, uri: string, callback: Function): void {
    logger.info('getAuthAppList start');

    switch (optType) {
      case CMModelOptType.CM_MODEL_OPT_APP_CRED:
        this.getAuthorizedAppList(uri, (errCode: CMModelErrorCode, appUidList: Array<string>) => {
          callback(errCode, appUidList);
        });
        break;
      case CMModelOptType.CM_MODEL_OPT_USER_CA:
      case CMModelOptType.CM_MODEL_OPT_SYSTEM_CA:
      case CMModelOptType.CM_MODEL_OPT_SYSTEM_CRED:
        callback(CMModelErrorCode.CM_MODEL_ERROR_NOT_SUPPORT);
        break;
      default:
        callback(CMModelErrorCode.CM_MODEL_ERROR_UNKNOWN_OPT);
        break;
    }
  }

  setAppAuthPromise(optType: CMModelOptType, uri: string, appUid: string, status: boolean): Promise<void> {
    logger.info('setAppAuth start');
    switch (optType) {
      case CMModelOptType.CM_MODEL_OPT_APP_CRED:
        return new Promise((resolve, reject) => {
          this.setAuthorizedAppStatus(uri, appUid, status, (errCode: CMModelErrorCode, data: string) => {
            if (errCode === CMModelErrorCode.CM_MODEL_ERROR_SUCCESS) {
              resolve(void(data));
            } else {
              reject(errCode);
            }
          });
        });
      default:
        return new Promise((resolve, reject) => {
          reject(CMModelErrorCode.CM_MODEL_ERROR_UNKNOWN_OPT);
        });
    }
  }

  setAppAuth(optType: CMModelOptType, uri: string, appUid: string, status: boolean, callback: Function): void {
    logger.info('setAppAuth start');

    switch (optType) {
      case CMModelOptType.CM_MODEL_OPT_APP_CRED:
        this.setAuthorizedAppStatus(uri, appUid, status, (errCode: CMModelErrorCode, data: string) => {
          callback(errCode, data);
        });
        break;
      case CMModelOptType.CM_MODEL_OPT_USER_CA:
      case CMModelOptType.CM_MODEL_OPT_SYSTEM_CA:
      case CMModelOptType.CM_MODEL_OPT_SYSTEM_CRED:
        callback(CMModelErrorCode.CM_MODEL_ERROR_NOT_SUPPORT);
        break;
      default:
        callback(CMModelErrorCode.CM_MODEL_ERROR_UNKNOWN_OPT);
        break;
    }
  }

  installCertOrCred(optType: CMModelOptType, data: Uint8Array, pwd: string, callback: Function): void {
    logger.info('installCertOrCred start');
    switch (optType) {
      case CMModelOptType.CM_MODEL_OPT_USER_CA:
        this.installUserCertificate(data, optType, (errCode: CMModelErrorCode, uri: string) => {
          callback(errCode, uri);
        });
        break;
      case CMModelOptType.CM_MODEL_OPT_USER_CA_P7B:
        this.installUserCertificate(data, optType, (errCode: CMModelErrorCode, uri: string) => {
          callback(errCode, uri);
        });
        break;
      case CMModelOptType.CM_MODEL_OPT_APP_CRED:
        this.installPublicCertificate(data, pwd, (errCode: CMModelErrorCode, uri: string) => {
          callback(errCode, uri ?? '');
        });
        break;
      case CMModelOptType.CM_MODEL_OPT_SYSTEM_CRED:
        this.installSystemAppCertificate(data, pwd, (errCode: CMModelErrorCode, uri: string) => {
          callback(errCode, uri ?? '');
        });
        break;
      case CMModelOptType.CM_MODEL_OPT_SYSTEM_CA:
        callback(CMModelErrorCode.CM_MODEL_ERROR_NOT_SUPPORT);
        break;
      default:
        callback(CMModelErrorCode.CM_MODEL_ERROR_UNKNOWN_OPT);
        break;
    }
  }

  private async getSystemTrustedCertificateList(callback: Function): Promise<void> {
    logger.info('getSystemTrustedCertificateList start');
    try {
      let subjectNameCN: string = '';
      let result = await CertManager.getSystemTrustedCertificateList();
      let certList: CertAbstractVo[] = [];
      let regex: RegExp = new RegExp('(?<=CN=).*?(?=,)', 'g');
      if (result.certList !== undefined) {
        for (let i = 0; i < result.certList.length; i++) {
          if (result.certList[i].subjectName.length !== 0) {
            let temp = result.certList[i].subjectName.match(regex);
            subjectNameCN = (temp !== undefined) ? String(temp) : '';
            logger.info('subjectNameCN is:' + subjectNameCN);
          }
          certList.push(new CertAbstractVo(String(result.certList[i].uri), String(result.certList[i].certAlias),
            Boolean(result.certList[i].state), String(result.certList[i].subjectName), String(subjectNameCN)));
        }
        logger.info('getSystemTrustedCertificateList end');
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, certList);
      } else {
        logger.error('getSystemTrustedCertificateList failed, undefined');
        callback(CMModelErrorCode.CM_MODEL_ERROR_FAILED, undefined);
      }
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      logger.error('getSystemTrustedCertificateList err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION, undefined);
    }
  }

  private setSubjectName(result: CertManager.CMResult, subjectNameMap: Map<string, string>) {
    if (result.certInfo === undefined) {
      return;
    }
    if (result.certInfo.subjectName.length !== 0) {
      let regex1: RegExp = new RegExp('(?<=CN=).*?(?=,)', 'g');
      let regex2: RegExp = new RegExp('(?<=OU=).*?(?=,)', 'g');
      let regex3: RegExp = new RegExp('(?<=O=).*', 'g');
      let subjectNameCN = result.certInfo.subjectName.match(regex1);
      logger.info('subjectNameCN is:' + subjectNameCN);
      let subjectNameOU = result.certInfo.subjectName.match(regex2);
      logger.info('subjectNameOU is:' + subjectNameOU);
      let subjectNameO = result.certInfo.subjectName.match(regex3);
      logger.info('subjectNameO is:' + subjectNameO);
      subjectNameMap.set('常用名称:', String(subjectNameCN));
      subjectNameMap.set('组织:', String(subjectNameO));
      subjectNameMap.set('组织单位:', String(subjectNameOU));
      subjectNameMap.set('序列号:', String(result.certInfo.serial));
    }
  }

  private setIssuerName(result: CertManager.CMResult, issuerNameMap: Map<string, string>) {
    if (result.certInfo === undefined) {
      return;
    }
    if (result.certInfo.issuerName.length !== 0) {
      let regex1: RegExp = new RegExp('(?<=CN=).*?(?=,)', 'g');
      let regex2: RegExp = new RegExp('(?<=OU=).*?(?=,)', 'g');
      let regex3: RegExp = new RegExp('(?<=O=).*', 'g');
      let issuerNameCN = result.certInfo.issuerName.match(regex1);
      logger.info('issuerNameCN is:' + issuerNameCN);
      let issuerNameOU = result.certInfo.issuerName.match(regex2);
      logger.info('issuerNameOU is:' + issuerNameOU);
      let issuerNameO = result.certInfo.issuerName.match(regex3);
      logger.info('issuerNameO is:' + issuerNameO);
      issuerNameMap.set('常用名称:', String(issuerNameCN));
      issuerNameMap.set('组织:', String(issuerNameO));
      issuerNameMap.set('组织单位:', String(issuerNameOU));
    }
  }

  private async getSystemTrustedCertificate(certUri: string, callback: Function): Promise<void> {
    logger.info('getSystemTrustedCertificate start');
    try {
      let result = await CertManager.getSystemTrustedCertificate(certUri);
      let subjectNameMap: Map<string, string> = new Map();
      let issuerNameMap: Map<string, string> = new Map();
      let dateMap: Map<string, string> = new Map();

      if (result.certInfo !== undefined) {
        this.setSubjectName(result, subjectNameMap);
        this.setIssuerName(result, issuerNameMap);
        dateMap.set('颁发时间:', String(result.certInfo.notBefore));
        dateMap.set('有效期至:', String(result.certInfo.notAfter));

        let certData: Uint8Array = result.certInfo.cert;
        let certInfo = new CertInfoVo(String(result.certInfo.uri), String(result.certInfo.certAlias),
          Boolean(result.certInfo.state), String(result.certInfo.issuerName), String(result.certInfo.subjectName),
          String(result.certInfo.serial), String(result.certInfo.notBefore),
          String(result.certInfo.notAfter), String(result.certInfo.fingerprintSha256),
          certData, subjectNameMap, issuerNameMap, dateMap);
        logger.info('getSystemTrustedCertificate end');
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, certInfo);
      } else {
        logger.error('getSystemTrustedCertificate failed, undefined');
        callback(CMModelErrorCode.CM_MODEL_ERROR_FAILED, undefined);
      }
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      logger.error('getSystemTrustedCertificate err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION, undefined);
    }
  }

  private async getAllUserTrustedCertificates(callback: Function): Promise<void> {
    logger.info('getAllUserTrustedCertificates start');
    try {
      let subjectNameCN: string = '';
      let result = await CertManager.getAllUserTrustedCertificates();
      let certList: CertAbstractVo[] = [];
      let regex: RegExp = new RegExp('(?<=CN=).*?(?=,)', 'g');
      if (result.certList !== undefined) {
        for (let i = 0; i < result.certList.length; i++) {
          if (result.certList[i].subjectName.length !== 0) {
            let temp = result.certList[i].subjectName.match(regex);
            subjectNameCN = (temp !== undefined) ? String(temp) : '';
            logger.info('subjectNameCN is:' + subjectNameCN);
          }
          if (String(result.certList[i].uri).indexOf('u=0;') === -1) {
            certList.push(new CertAbstractVo(String(result.certList[i].uri), String(result.certList[i].certAlias),
              Boolean(result.certList[i].state), String(result.certList[i].subjectName), String(subjectNameCN)));
          }
        }
        logger.info('getAllUserTrustedCertificates end');
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, certList);
      } else {
        logger.error('getAllUserTrustedCertificates failed, undefined');
        callback(CMModelErrorCode.CM_MODEL_ERROR_FAILED, undefined);
      }
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      logger.error('getAllUserTrustedCertificates err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
    }
  }

  private async getUserTrustedCertificate(certUri: string, callback: Function): Promise<void> {
    logger.info('getUserTrustedCertificate start');
    try {
      let result = await CertManager.getUserTrustedCertificate(certUri);
      let subjectNameMap: Map<string, string> = new Map();
      let issuerNameMap: Map<string, string> = new Map();
      let dateMap: Map<string, string> = new Map();
      let regex1: RegExp = new RegExp('(?<=CN=).*?(?=,)', 'g');
      let regex2: RegExp = new RegExp('(?<=OU=).*?(?=,)', 'g');
      let regex3: RegExp = new RegExp('(?<=O=).*', 'g');

      if (result.certInfo !== undefined) {
        this.setSubjectName(result, subjectNameMap);
        this.setIssuerName(result, issuerNameMap);
        dateMap.set('颁发时间:', String(result.certInfo.notBefore));
        dateMap.set('有效期至:', String(result.certInfo.notAfter));
        let certData: Uint8Array = result.certInfo.cert;
        let certInfo = new CertInfoVo(String(result.certInfo.uri), String(result.certInfo.certAlias),
          Boolean(result.certInfo.state), String(result.certInfo.issuerName), String(result.certInfo.subjectName),
          String(result.certInfo.serial), String(result.certInfo.notBefore),
          String(result.certInfo.notAfter), String(result.certInfo.fingerprintSha256),
          certData, subjectNameMap, issuerNameMap, dateMap);
        logger.info('getUserTrustedCertificate end');
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, certInfo);
      } else {
        logger.error('getUserTrustedCertificate failed, undefined');
        callback(CMModelErrorCode.CM_MODEL_ERROR_FAILED, undefined);
      }
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      logger.error('getUserTrustedCertificate err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION, undefined);
    }
  }

  private async deleteUserTrustedCertificate(certUri: string, callback: Function): Promise<void> {
    logger.info('deleteUserTrustedCertificate start');
    try {
      CertManager.uninstallUserTrustedCertificateSync(certUri);
      logger.info('deleteUserTrustedCertificate end');
      callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      logger.error('deleteUserTrustedCertificate err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
    }
  }

  private async setCertificateStatus(certUri: string, store: number,
                                     status: boolean, callback: Function): Promise<void> {
    logger.info('setCertificateStatus start');
    try {
      await CertManager.setCertificateStatus(certUri, store, status);
      logger.info('setCertificateStatus end');
      callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      logger.error('setCertificateStatus failed with err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
    }
  }

  private async getAppCredList(callback: Function): Promise<void> {
    logger.info('getAppCredList start');
    try {
      let result = await CertManager.getAllPublicCertificates();
      let credList: CredentialAbstractVo[] = [];
      if (result && result.credentialList !== undefined) {
        for (let i = 0; i < result.credentialList.length; i++) {
          credList.push(new CredentialAbstractVo(String(result.credentialList[i].type),
            String(result.credentialList[i].alias), String(result.credentialList[i].keyUri)));
        }
        logger.info('getAppCredList end');
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, credList);
      } else {
        logger.error('getAppCredList failed, undefined.');
        callback(CMModelErrorCode.CM_MODEL_ERROR_FAILED, undefined);
      }
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      logger.error('getAppCredList failed with err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
    }
  }

  private async getSystemCredList(callback: Function): Promise<void> {
    logger.info('getSystemList start');
    try {
      let result = await CertManager.getAllSystemAppCertificates();
      let credList: CredentialAbstractVo[] = [];
      if (result.credentialList !== undefined) {
        for (let i = 0; i < result.credentialList.length; i++) {
          credList.push(new CredentialAbstractVo(String(result.credentialList[i].type),
            String(result.credentialList[i].alias), String(result.credentialList[i].keyUri)));
        }
        logger.info('getSystemCredList end');
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, credList);
      } else {
        logger.error('getSystemCredList failed, undefined.');
        callback(CMModelErrorCode.CM_MODEL_ERROR_FAILED, undefined)
      }
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      logger.error('getSystemCredList failed with err, message: ' + e.message + ', code: ' + e.code)
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION)
    }
  }

  private async getAppCredential(certUri: string, callback: Function): Promise<void> {
    logger.info('getAppCredential start');
    try {
      let result = await CertManager.getPublicCertificate(certUri);
      if (result.credential !== undefined) {
        let certData: Uint8Array = result.credential.credentialData;
        let credInfo = new CredentialVo(String(result.credential.type), String(result.credential.alias),
          String(result.credential.keyUri), Number(result.credential.certNum),
          Number(result.credential.keyNum), certData);
        logger.info('getAppCredential end');
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, credInfo);
      } else {
        logger.error('getAppCredential failed, undefined');
        callback(CMModelErrorCode.CM_MODEL_ERROR_FAILED, undefined);
      }
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      logger.error('getAppCredential failed with err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION, undefined);
    }
  }

  private async getSystemCredential(certUri: string, callback: Function): Promise<void> {
    logger.info('getSystemCredential start');
    try {
      let result = await CertManager.getSystemAppCertificate(certUri);
      if (result.credential !== undefined) {
        let certData: Uint8Array = result.credential.credentialData;
        let credInfo = new CredentialVo(String(result.credential.type), String(result.credential.alias),
          String(result.credential.keyUri), Number(result.credential.certNum),
          Number(result.credential.keyNum), certData);
        logger.info('getSystemCredential end');
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, credInfo);
      } else {
        logger.error('getSystemCredential failed, undefined');
        callback(CMModelErrorCode.CM_MODEL_ERROR_FAILED, undefined);
      }
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      logger.error('getSystemCredential failed with err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION, undefined);
    }
  }

  private async deleteAppCredential(certUri: string, callback: Function): Promise<void> {
    logger.info('deleteAppCredential start');
    try {
      await CertManager.uninstallPublicCertificate(certUri);
      logger.info('deleteAppCredential end');
      callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      logger.error('deleteAppCredential failed with err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
    }
  }

  private async deleteSystemCredential(certUri: string, callback: Function): Promise<void> {
    logger.info('deleteSystemCredential start');
    try {
      await CertManager.uninstallSystemAppCertificate(certUri);
      logger.info('deleteSystemCredential end');
      callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      logger.error('deleteSystemCredential failed with err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
    }
  }

  private async delAllUserCertificate(callback: Function): Promise<void> {
    logger.info('delAllUserCertificate start');
    try {
      await CertManager.uninstallAllUserTrustedCertificate();
      logger.info('delAllUserCertificate end');
      callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      logger.error('delAllUserCertificate failed with err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
    }
  }

  private async delAllAppCredential(callback: Function): Promise<void> {
    logger.info('delAllAppCredential start');
    try {
      await CertManager.uninstallAllAppCertificate();
      logger.info('delAllAppCredential end');
      callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      logger.error('delAllAppCredential failed with err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
    }
  }

  private async getAuthorizedAppList(uri: string, callback: Function): Promise<void> {
    logger.info('getAuthorizedAppList start');
    try {
      let result = await CertManager.getAuthorizedAppList(uri);
      logger.info('getAuthorizedAppList end');
      callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, result.appUidList);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      logger.error('getAuthorizedAppList failed with err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION, undefined);
    }
  }

  private async setAuthorizedAppStatus(
    uri: string,
    appUidStr: string,
    status: boolean,
    callback: Function
  ): Promise<void> {
    logger.info('setAuthorizedAppStatus start');
    try {
      let appUid = Number(appUidStr);
      if (status) {
        let result = await CertManager.grantPublicCertificate(uri, appUid);
        logger.info('setAuthorizedAppStatus true end');
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, result.uri);
      } else {
        logger.info('appId:' + appUid + 'uri:' + uri);
        await CertManager.removeGrantedPublicCertificate(uri, appUid);
        logger.info('setAuthorizedAppStatus false end');
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS);
      }
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      logger.error('setAuthorizedAppStatus failed with err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
    }
  }

  private async installUserCertificate(data: Uint8Array, optType: CMModelOptType, callback: Function): Promise<void> {
    logger.info('installUserCertificate start');
    if ((data === undefined) || (data.length === 0)) {
      callback(CMModelErrorCode.CM_MODEL_ERROR_INCORRECT_FORMAT);
      logger.error('installUserCertificate data is empty.');
      return;
    }
    try {
      let certFormat: CertManager.CertFileFormat = CertManager.CertFileFormat.PEM_DER;
      if (optType == CMModelOptType.CM_MODEL_OPT_USER_CA_P7B) {
        certFormat = CertManager.CertFileFormat.P7B;
      }
      let result = await CertManager.installUserTrustedCertificate({
        certData: data,
        certFormat: certFormat,
        certScope: CertManager.CertScope.CURRENT_USER
      });
      logger.info('installUserCertificate end');
      callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, result.uri);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      if (e.code === CertManager.CMErrorCode.CM_ERROR_INCORRECT_FORMAT) {
        callback(CMModelErrorCode.CM_MODEL_ERROR_INCORRECT_FORMAT)
      } else if (e.code === CertManager.CMErrorCode.CM_ERROR_MAX_CERT_COUNT_REACHED) {
        callback(CMModelErrorCode.CM_MODEL_ERROR_MAX_QUANTITY_REACHED)
      } else if (e.code === CertManager.CMErrorCode.CM_ERROR_ALIAS_LENGTH_REACHED_LIMIT) {
        callback(CMModelErrorCode.CM_MODEL_ERROR_ALIAS_LENGTH_REACHED_LIMIT)
      } else {
        logger.error('installUserCertificate failed with err, message: ' + e.message + ', code: ' + e.code);
        callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
      }
    }
  }

  private async installPublicCertificate(
    data: Uint8Array,
    pwd: string,
    callback: Function
  ): Promise<void> {
    logger.info('installPublicCertificate start');
    try {
      let result: CertManager.CMResult = await CertManager.installPublicCertificate(data, pwd);
      logger.info('installPublicCertificate end');
      callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, result.uri ?? '');
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      if (e.code === CertManager.CMErrorCode.CM_ERROR_INCORRECT_FORMAT) {
        callback(CMModelErrorCode.CM_MODEL_ERROR_INCORRECT_FORMAT, '')
      } else if (e.code === CertManager.CMErrorCode.CM_ERROR_MAX_CERT_COUNT_REACHED) {
        callback(CMModelErrorCode.CM_MODEL_ERROR_MAX_QUANTITY_REACHED, '')
      } else if (e.code === CertManager.CMErrorCode.CM_ERROR_ALIAS_LENGTH_REACHED_LIMIT) {
        callback(CMModelErrorCode.CM_MODEL_ERROR_ALIAS_LENGTH_REACHED_LIMIT, '')
      } else if (e.code === CertManager.CMErrorCode.CM_ERROR_PASSWORD_IS_ERR) {
        callback(CMModelErrorCode.CM_MODEL_ERROR_PASSWORD_ERR, '');
      } else {
        logger.error('installPublicCertificate failed with err, message: ' + e.message + ', code: ' + e.code);
        callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION, '');
      }
    }
  }

  private async installSystemAppCertificate(
    data: Uint8Array,
    pwd: string,
    callback: Function
  ): Promise<void> {
    logger.info('installSystemAppCertificate start');
    try {
      let result: CertManager.CMResult = await CertManager.installSystemAppCertificate(data, pwd);
      logger.info('installSystemAppCertificate end');
      callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, result.uri ?? '');
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      if (e.code === CertManager.CMErrorCode.CM_ERROR_INCORRECT_FORMAT) {
        callback(CMModelErrorCode.CM_MODEL_ERROR_INCORRECT_FORMAT, '');
      } else if (e.code === CertManager.CMErrorCode.CM_ERROR_MAX_CERT_COUNT_REACHED) {
        callback(CMModelErrorCode.CM_MODEL_ERROR_MAX_QUANTITY_REACHED, '');
      } else if (e.code === CertManager.CMErrorCode.CM_ERROR_PASSWORD_IS_ERR) {
        callback(CMModelErrorCode.CM_MODEL_ERROR_PASSWORD_ERR, '');
      } else {
        logger.error('installSystemAppCertificate failed with err, message: ' + e.message + ', code: ' + e.code);
        callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION, '');
      }
    }
  }

  async getAllAppPrivateCertificates(appUid: number): Promise<CredentialAbstractVo[]> {
    return new Promise<CredentialAbstractVo[]>(async (resolve, reject) => {
      try {
        let cmResult: CertManager.CMResult | undefined = await CertManager.getAllAppPrivateCertificatesByUid(appUid);
        let result: CredentialAbstractVo[] = [];
        if (cmResult === undefined) {
          logger.info('The application does not have private credentials installed');
        }  else {
          let credAbsList: CertManager.CredentialAbstract[] = cmResult.credentialList ?? [];
          for (let i = 0; i < credAbsList.length; i++) {
            let cred = credAbsList[i];
            result.push(new CredentialAbstractVo(String(cred.type), String(cred.alias), String(cred.keyUri),
              certMgrDialog.CertificateType.CREDENTIAL_APP));
          }
        }
        logger.info(`getAllAppPrivateCertificatesByUid end credList length: ${result.length}`);
        return resolve(result);
      } catch(err) {
        let error = err as BusinessError;
        logger.error(`getAllAppPrivateCertificatesByUid err, message: ${error.message}, code: ${error.code}`);
        return reject({code: CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION, message: 'getAllAppPrivateCertificatesByUid error'});
      }
    });
  }

  async getUkeyCertificateList(certPurpose: CertManager.CertificatePurpose): Promise<CredentialAbstractVo[]> {
    return new Promise<CredentialAbstractVo[]>(async (resolve, reject) => {
      try{
        let cmResult: CertManager.CMResult | undefined = await CertManager.getUkeyCertificateList('', { certPurpose: certPurpose });
        let result: CredentialAbstractVo[] = [];
        if (cmResult !== undefined) {
          let credAbsList: CertManager.CredentialAbstract[] = cmResult.credentialList ?? [];
          for (let i = 0; i < credAbsList.length; i++) {
            let cred = credAbsList[i];
            result.push(new CredentialAbstractVo(String(cred.type), String(cred.alias), String(cred.keyUri),
              certMgrDialog.CertificateType.CREDENTIAL_UKEY));
          }
        }
        logger.info(`getAllAppPrivateCertificatesByUid end credList length: ${result.length}`);
        return resolve(result);
      } catch(err) {
        let error = err as BusinessError;
        logger.error(`getAllAppPrivateCertificatesByUid err, message: ${error.message}, code: ${error.code}`);
        return reject({code: CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION, message: error.message});
      }
    });
  }
}

let certMangerModel = new CertMangerModel();

export default certMangerModel as CertMangerModel;
