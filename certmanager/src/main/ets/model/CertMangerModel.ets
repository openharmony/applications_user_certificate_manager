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
import cert from '@ohos.security.cert';

const TAG = 'CertManager Model: ';

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
  CM_MODEL_ERROR_
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
  DIALOG_ERROR_PARAM_INVALID = -1010,
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

export class CertMangerModel {
  getCertOrCredList(optType: CMModelOptType, callback: Function): void {
    console.info(TAG + 'getCertOrCredList start');

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
    console.info(TAG + 'getCertOrCred start');

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
    console.info(TAG + 'deleteCertOrCred start');

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
    console.info(TAG + 'setCertStatus start');

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
    console.info(TAG + 'delAllCertOrCred start');

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
    console.info(TAG + 'getAuthAppList start');

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
    console.info(TAG + 'setAppAuth start');
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
    console.info(TAG + 'setAppAuth start');

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

  installCertOrCred(optType: CMModelOptType, alias: string, data: Uint8Array, pwd: string, callback: Function): void {
    console.info(TAG + 'installCertOrCred start');
    switch (optType) {
      case CMModelOptType.CM_MODEL_OPT_USER_CA:
        this.installUserCertificate(data, alias, optType, (errCode: CMModelErrorCode, uri: string) => {
          callback(errCode, uri);
        });
        break;
      case CMModelOptType.CM_MODEL_OPT_USER_CA_P7B:
        this.installUserCertificate(data, alias, optType, (errCode: CMModelErrorCode, uri: string) => {
          callback(errCode, uri);
        });
        break;
      case CMModelOptType.CM_MODEL_OPT_APP_CRED:
        this.installPublicCertificate(data, alias, pwd, (errCode: CMModelErrorCode) => {
          callback(errCode);
        });
        break;
      case CMModelOptType.CM_MODEL_OPT_SYSTEM_CRED:
        this.installSystemAppCertificate(data, alias, pwd, (errCode: CMModelErrorCode) => {
          callback(errCode);
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
    console.info(TAG + 'getSystemTrustedCertificateList start');
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
            console.info('subjectNameCN is:' + subjectNameCN);
          }
          certList.push(new CertAbstractVo(String(result.certList[i].uri), String(result.certList[i].certAlias),
            Boolean(result.certList[i].status), String(result.certList[i].subjectName), String(subjectNameCN)));
        }
        console.info(TAG + 'getSystemTrustedCertificateList end');
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, certList);
      } else {
        console.error(TAG + 'getSystemTrustedCertificateList failed, undefined');
        callback(CMModelErrorCode.CM_MODEL_ERROR_FAILED, undefined);
      }
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG + 'getSystemTrustedCertificateList err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION, undefined);
    }
  }

  private async getSystemTrustedCertificate(certUri: string, callback: Function): Promise<void> {
    console.info(TAG + 'getSystemTrustedCertificate start');
    try {
      let result = await CertManager.getSystemTrustedCertificate(certUri);
      let subjectNameMap: Map<string, string> = new Map();
      let issuerNameMap: Map<string, string> = new Map();
      let dateMap: Map<string, string> = new Map();
      let regex1: RegExp = new RegExp('(?<=CN=).*?(?=,)', 'g');
      let regex2: RegExp = new RegExp('(?<=OU=).*?(?=,)', 'g');
      let regex3: RegExp = new RegExp('(?<=O=).*', 'g');

      if (result.certInfo !== undefined) {
        if (result.certInfo.subjectName.length !== 0) {
          let subjectNameCN = result.certInfo.subjectName.match(regex1);
          console.info('subjectNameCN is:' + subjectNameCN);
          let subjectNameOU = result.certInfo.subjectName.match(regex2);
          console.info('subjectNameOU is:' + subjectNameOU);
          let subjectNameO = result.certInfo.subjectName.match(regex3);
          console.info('subjectNameO is:' + subjectNameO);
          subjectNameMap.set('常用名称:', String(subjectNameCN));
          subjectNameMap.set('组织:', String(subjectNameO));
          subjectNameMap.set('组织单位:', String(subjectNameOU));
          subjectNameMap.set('序列号:', String(result.certInfo.serial));
        }
        if (result.certInfo.issuerName.length !== 0) {
          let issuerNameCN = result.certInfo.issuerName.match(regex1);
          console.info('issuerNameCN is:' + issuerNameCN);
          let issuerNameOU = result.certInfo.issuerName.match(regex2);
          console.info('issuerNameOU is:' + issuerNameOU);
          let issuerNameO = result.certInfo.issuerName.match(regex3);
          console.info('issuerNameO is:' + issuerNameO);
          issuerNameMap.set('常用名称:', String(issuerNameCN));
          issuerNameMap.set('组织:', String(issuerNameO));
          issuerNameMap.set('组织单位:', String(issuerNameOU));
        }
        dateMap.set('颁发时间:', String(result.certInfo.notBefore));
        dateMap.set('有效期至:', String(result.certInfo.notAfter));

        let certData: Uint8Array = result.certInfo.cert;
        let certInfo = new CertInfoVo(String(result.certInfo.uri), String(result.certInfo.certAlias),
          Boolean(result.certInfo.status), String(result.certInfo.issuerName), String(result.certInfo.subjectName),
          String(result.certInfo.serial), String(result.certInfo.notBefore),
          String(result.certInfo.notAfter), String(result.certInfo.fingerprintSha256),
          certData, subjectNameMap, issuerNameMap, dateMap);
        console.info(TAG + 'getSystemTrustedCertificate end');
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, certInfo);
      } else {
        console.error(TAG + 'getSystemTrustedCertificate failed, undefined');
        callback(CMModelErrorCode.CM_MODEL_ERROR_FAILED, undefined);
      }
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG + 'getSystemTrustedCertificate err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION, undefined);
    }
  }

  private async getAllUserTrustedCertificates(callback: Function): Promise<void> {
    console.info(TAG + 'getAllUserTrustedCertificates start');
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
            console.info('subjectNameCN is:' + subjectNameCN);
          }
          if (String(result.certList[i].uri).indexOf('u=0;') === -1) {
            certList.push(new CertAbstractVo(String(result.certList[i].uri), String(result.certList[i].certAlias),
              Boolean(result.certList[i].status), String(result.certList[i].subjectName), String(subjectNameCN)));
          }
        }
        console.info(TAG + 'getAllUserTrustedCertificates end');
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, certList);
      } else {
        console.error(TAG + 'getAllUserTrustedCertificates failed, undefined');
        callback(CMModelErrorCode.CM_MODEL_ERROR_FAILED, undefined);
      }
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG + 'getAllUserTrustedCertificates err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
    }
  }

  private async getUserTrustedCertificate(certUri: string, callback: Function): Promise<void> {
    console.info(TAG + 'getUserTrustedCertificate start');
    try {
      let result = await CertManager.getUserTrustedCertificate(certUri);
      let subjectNameMap: Map<string, string> = new Map();
      let issuerNameMap: Map<string, string> = new Map();
      let dateMap: Map<string, string> = new Map();
      let regex1: RegExp = new RegExp('(?<=CN=).*?(?=,)', 'g');
      let regex2: RegExp = new RegExp('(?<=OU=).*?(?=,)', 'g');
      let regex3: RegExp = new RegExp('(?<=O=).*', 'g');

      if (result.certInfo !== undefined) {
        if (result.certInfo.subjectName.length !== 0) {
          let subjectNameCN = result.certInfo.subjectName.match(regex1);
          console.info('subjectNameCN is:' + subjectNameCN);
          let subjectNameOU = result.certInfo.subjectName.match(regex2);
          console.info('subjectNameOU is:' + subjectNameOU);
          let subjectNameO = result.certInfo.subjectName.match(regex3);
          console.info('SubjectNameO is:' + subjectNameO);
          subjectNameMap.set('常用名称:', String(subjectNameCN));
          subjectNameMap.set('组织:', String(subjectNameO));
          subjectNameMap.set('组织单位:', String(subjectNameOU));
          subjectNameMap.set('序列号:', String(result.certInfo.serial));
        }
        if (result.certInfo.issuerName.length !== 0) {
          let issuerNameCN = result.certInfo.issuerName.match(regex1);
          console.info('issuerNameCN is:' + issuerNameCN);
          let issuerNameOU = result.certInfo.issuerName.match(regex2);
          console.info('issuerNameOU is:' + issuerNameOU);
          let issuerNameO = result.certInfo.issuerName.match(regex3);
          console.info('issuerNameO is:' + issuerNameO);
          issuerNameMap.set('常用名称:', String(issuerNameCN));
          issuerNameMap.set('组织:', String(issuerNameO));
          issuerNameMap.set('组织单位:', String(issuerNameOU));
        }
        dateMap.set('颁发时间:', String(result.certInfo.notBefore));
        dateMap.set('有效期至:', String(result.certInfo.notAfter));
        let certData: Uint8Array = result.certInfo.cert;
        let certInfo = new CertInfoVo(String(result.certInfo.uri), String(result.certInfo.certAlias),
          Boolean(result.certInfo.status), String(result.certInfo.issuerName), String(result.certInfo.subjectName),
          String(result.certInfo.serial), String(result.certInfo.notBefore),
          String(result.certInfo.notAfter), String(result.certInfo.fingerprintSha256),
          certData, subjectNameMap, issuerNameMap, dateMap);
        console.info(TAG + 'getUserTrustedCertificate end');
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, certInfo);
      } else {
        console.error(TAG + 'getUserTrustedCertificate failed, undefined');
        callback(CMModelErrorCode.CM_MODEL_ERROR_FAILED, undefined);
      }
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG + 'getUserTrustedCertificate err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION, undefined);
    }
  }

  private async deleteUserTrustedCertificate(certUri: string, callback: Function): Promise<void> {
    console.info(TAG + 'deleteUserTrustedCertificate start');
    try {
      await CertManager.uninstallUserTrustedCertificate(certUri);
      console.info(TAG + 'deleteUserTrustedCertificate end');
      callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG + 'deleteUserTrustedCertificate err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
    }
  }

  private async setCertificateStatus(certUri: string, store: number,
                                     status: boolean, callback: Function): Promise<void> {
    console.info(TAG + 'setCertificateStatus start');
    try {
      await CertManager.setCertificateStatus(certUri, store, status);
      console.info(TAG + 'setCertificateStatus end');
      callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG + 'setCertificateStatus failed with err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
    }
  }

  private async getAppCredList(callback: Function): Promise<void> {
    console.info(TAG + 'getAppCredList start');
    try {
      let result = await CertManager.getAllPublicCertificates();
      let credList: CredentialAbstractVo[] = [];
      if (result && result.credentialList !== undefined) {
        for (let i = 0; i < result.credentialList.length; i++) {
          credList.push(new CredentialAbstractVo(String(result.credentialList[i].type),
            String(result.credentialList[i].alias), String(result.credentialList[i].keyUri)));
        }
        console.info(TAG + 'getAppCredList end');
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, credList);
      } else {
        console.error(TAG + 'getAppCredList failed, undefined.');
        callback(CMModelErrorCode.CM_MODEL_ERROR_FAILED, undefined);
      }
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG + 'getAppCredList failed with err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
    }
  }

  private async getSystemCredList(callback: Function): Promise<void> {
    console.info(TAG + 'getSystemList start');
    try {
      let result = await CertManager.getAllSystemAppCertificates();
      let credList: CredentialAbstractVo[] = [];
      if (result.credentialList !== undefined) {
        for (let i = 0; i < result.credentialList.length; i++) {
          credList.push(new CredentialAbstractVo(String(result.credentialList[i].type),
            String(result.credentialList[i].alias), String(result.credentialList[i].keyUri)));
        }
        console.info(TAG + 'getSystemCredList end');
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, credList);
      } else {
        console.error(TAG + 'getSystemCredList failed, undefined.');
        callback(CMModelErrorCode.CM_MODEL_ERROR_FAILED, undefined)
      }
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG, 'getSystemCredList failed with err, message: ' + e.message + ', code: ' + e.code)
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION)
    }
  }

  private async getAppCredential(certUri: string, callback: Function): Promise<void> {
    console.info(TAG + 'getAppCredential start');
    try {
      let result = await CertManager.getPublicCertificate(certUri);
      if (result.credential !== undefined) {
        let certData: Uint8Array = result.credential.credData;
        let credInfo = new CredentialVo(String(result.credential.type), String(result.credential.alias),
          String(result.credential.keyUri), Number(result.credential.certNum),
          Number(result.credential.keyNum), certData);
        console.info(TAG + 'getAppCredential end');
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, credInfo);
      } else {
        console.error(TAG + 'getAppCredential failed, undefined');
        callback(CMModelErrorCode.CM_MODEL_ERROR_FAILED, undefined);
      }
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG + 'getAppCredential failed with err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION, undefined);
    }
  }

  private async getSystemCredential(certUri: string, callback: Function): Promise<void> {
    console.info(TAG + 'getSystemCredential start');
    try {
      let result = await CertManager.getSystemAppCertificate(certUri);
      if (result.credential !== undefined) {
        let certData: Uint8Array = result.credential.credData;
        let credInfo = new CredentialVo(String(result.credential.type), String(result.credential.alias),
          String(result.credential.keyUri), Number(result.credential.certNum),
          Number(result.credential.keyNum), certData);
        console.info(TAG + 'getSystemCredential end');
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, credInfo);
      } else {
        console.error(TAG + 'getSystemCredential failed, undefined');
        callback(CMModelErrorCode.CM_MODEL_ERROR_FAILED, undefined);
      }
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG + 'getSystemCredential failed with err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION, undefined);
    }
  }

  private async deleteAppCredential(certUri: string, callback: Function): Promise<void> {
    console.info(TAG + 'deleteAppCredential start');
    try {
      await CertManager.uninstallPublicCertificate(certUri);
      console.info(TAG + 'deleteAppCredential end');
      callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG + 'deleteAppCredential failed with err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
    }
  }

  private async deleteSystemCredential(certUri: string, callback: Function): Promise<void> {
    console.info(TAG, 'deleteSystemCredential start');
    try {
      await CertManager.uninstallSystemAppCertificate(certUri);
      console.info(TAG, 'deleteSystemCredential end');
      callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG + 'deleteSystemCredential failed with err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
    }
  }

  private async delAllUserCertificate(callback: Function): Promise<void> {
    console.info(TAG + 'delAllUserCertificate start');
    try {
      await CertManager.uninstallAllUserTrustedCertificate();
      console.info(TAG + 'delAllUserCertificate end');
      callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG + 'delAllUserCertificate failed with err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
    }
  }

  private async delAllAppCredential(callback: Function): Promise<void> {
    console.info(TAG + 'delAllAppCredential start');
    try {
      await CertManager.uninstallAllAppCertificate();
      console.info(TAG + 'delAllAppCredential end');
      callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG + 'delAllAppCredential failed with err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
    }
  }

  private async getAuthorizedAppList(uri: string, callback: Function): Promise<void> {
    console.info(TAG + 'getAuthorizedAppList start');
    try {
      let result = await CertManager.getAuthorizedAppList(uri);
      console.info(TAG + 'getAuthorizedAppList end');
      callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, result.appUidList);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG + 'getAuthorizedAppList failed with err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION, undefined);
    }
  }

  private async setAuthorizedAppStatus(
    uri: string,
    appUid: string,
    status: boolean,
    callback: Function
  ): Promise<void> {
    console.info(TAG + 'setAuthorizedAppStatus start');
    try {
      if (status) {
        let result = await CertManager.grantPublicCertificate(uri, appUid);
        console.info(TAG + 'setAuthorizedAppStatus true end');
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, result.uri);
      } else {
        console.info(TAG + 'appId:' + appUid + 'uri:' + uri);
        await CertManager.removeGrantedPublicCertificate(uri, appUid);
        console.info(TAG + 'setAuthorizedAppStatus false end');
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS);
      }
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error(TAG + 'setAuthorizedAppStatus failed with err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
    }
  }

  private async installUserCertificate(data: Uint8Array, alias: string, optType: CMModelOptType, callback: Function): Promise<void> {
    console.info(TAG + 'installUserCertificate start');
    if ((data === undefined) || (data.length === 0)) {
      callback(CMModelErrorCode.CM_MODEL_ERROR_INCORRECT_FORMAT);
      console.error(TAG + 'installUserCertificate data is empty.');
      return;
    }
    try {
      let certFormat: CertManager.CertFileFormat = CertManager.CertFileFormat.PEM_DER;
      if (optType == CMModelOptType.CM_MODEL_OPT_USER_CA_P7B) {
        certFormat = CertManager.CertFileFormat.P7B;
      }
      let result = await CertManager.installUserTrustedCertificate({
        inData: data,
        alias: alias,
        certFormat: certFormat,
        certScope: CertManager.CertScope.CURRENT_USER
      });
      console.info(TAG + 'installUserCertificate end');
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
        console.error(TAG + 'installUserCertificate failed with err, message: ' + e.message + ', code: ' + e.code);
        callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
      }
    }
  }

  private async installPublicCertificate(
    data: Uint8Array,
    alias: string,
    pwd: string,
    callback: Function
  ): Promise<void> {
    console.info(TAG + 'installPublicCertificate start');
    try {
      await CertManager.installPublicCertificate(data, pwd, alias);
      console.info(TAG + 'installPublicCertificate end');
      callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      if (e.code === CertManager.CMErrorCode.CM_ERROR_INCORRECT_FORMAT) {
        callback(CMModelErrorCode.CM_MODEL_ERROR_INCORRECT_FORMAT)
      } else if (e.code === CertManager.CMErrorCode.CM_ERROR_MAX_CERT_COUNT_REACHED) {
        callback(CMModelErrorCode.CM_MODEL_ERROR_MAX_QUANTITY_REACHED)
      } else if (e.code === CertManager.CMErrorCode.CM_ERROR_ALIAS_LENGTH_REACHED_LIMIT) {
        callback(CMModelErrorCode.CM_MODEL_ERROR_ALIAS_LENGTH_REACHED_LIMIT)
      } else if (e.code === CertManager.CMErrorCode.CM_ERROR_PASSWORD_IS_ERR) {
        callback(CMModelErrorCode.CM_MODEL_ERROR_PASSWORD_ERR);
      } else {
        console.error(TAG + 'installPublicCertificate failed with err, message: ' + e.message + ', code: ' + e.code);
        callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
      }
    }
  }

  private async installSystemAppCertificate(
    data: Uint8Array,
    alias: string,
    pwd: string,
    callback: Function
  ): Promise<void> {
    console.info(TAG, 'installSystemAppCertificate start');
    try {
      await CertManager.installSystemAppCertificate(data, pwd, alias);
      console.info(TAG + 'installSystemAppCertificate end');
      callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      if (e.code === CertManager.CMErrorCode.CM_ERROR_INCORRECT_FORMAT) {
        callback(CMModelErrorCode.CM_MODEL_ERROR_INCORRECT_FORMAT);
      } else if (e.code === CertManager.CMErrorCode.CM_ERROR_MAX_CERT_COUNT_REACHED) {
        callback(CMModelErrorCode.CM_MODEL_ERROR_MAX_QUANTITY_REACHED);
      } else if (e.code === CertManager.CMErrorCode.CM_ERROR_ALIAS_LENGTH_REACHED_LIMIT) {
        callback(CMModelErrorCode.CM_MODEL_ERROR_ALIAS_LENGTH_REACHED_LIMIT);
      } else if (e.code === CertManager.CMErrorCode.CM_ERROR_PASSWORD_IS_ERR) {
        callback(CMModelErrorCode.CM_MODEL_ERROR_PASSWORD_ERR);
      } else {
        console.error(TAG + 'installSystemAppCertificate failed with err, message: ' + e.message + ', code: ' + e.code);
        callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
      }
    }
  }
}

let certMangerModel = new CertMangerModel();

export default certMangerModel as CertMangerModel;
