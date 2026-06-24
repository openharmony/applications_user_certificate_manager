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
import { AuthIntent, AuthIntentParams } from '../intent/AuthIntent';
import RequestAuthModel from '../model/RequestAuthModel';
import certMgrDialog from '@ohos.security.certManagerDialog';
import certMgr from '@ohos.security.certManager'
import { CMModelErrorCode, DialogErrorCode } from '../../../model/CertMangerModel';
import { SYSCAP_HUKS_CRYPTO_EXTENTION } from '../../../common/constants/CertManagerConstants';
import { RequestAuthPageVersion } from '../common/Constants';
import bundleNameModel from '../../../model/BundleModel';
import { util } from '@kit.ArkTS';

export default class AuthIntentProcessor {
  private logger: Logger = new Logger('AuthIntentProcessor');

  private processLoadCredentials(intentParams: AuthIntentParams): Promise<RequestAuthModel> {
    return new LoadCredentialsProcessor(intentParams).process();
  }

  private processSelectUri(model: RequestAuthModel, intentParams: AuthIntentParams): Promise<RequestAuthModel> {
    if (intentParams.selectUri === undefined || intentParams.selectType == undefined) {
      return Promise.resolve(model);
    }
    model.selectCredItem(intentParams.selectUri, intentParams.selectType);
    return Promise.resolve(model.clone());
  }

  private processRequestAuth(model: RequestAuthModel): Promise<RequestAuthModel> {
    return new Promise(async (resolve, reject) => {
      try {
        await model.grantPublicCertificate();
        return resolve(model.clone());
      } catch (err) {
        this.logger.error(`processRequestAuth err, message: ${err?.message}, code: ${err?.code}`);
        return reject(err);
      }
    })
  }

  public process(
    model: RequestAuthModel,
    intent: AuthIntent,
    intentParams: AuthIntentParams
  ): Promise<RequestAuthModel> {
    switch (intent) {
      case AuthIntent.LOAD_CREDENTIALS:
        return this.processLoadCredentials(intentParams);
      case AuthIntent.CHANGE_SELECTED_CRED:
        return this.processSelectUri(model, intentParams);
      case AuthIntent.REQUEST_AUTH:
        return this.processRequestAuth(model);
      default:
        return Promise.reject({ code: CMModelErrorCode.CM_MODEL_ERROR_FAILED, message: `unrecognized intent` });
    }
  }
}

export class LoadCredentialsProcessor {
  private logger: Logger = new Logger('LoadCredentialsProcessor');
  private model: RequestAuthModel;
  private intentParams: AuthIntentParams;

  constructor(intentParams: AuthIntentParams) {
    this.model = new RequestAuthModel();
    this.intentParams = intentParams;
  }

  public process(): Promise<RequestAuthModel> {
    /**
     * 检查参数
     */
    if (this.intentParams.want === undefined) {
      return Promise.reject({ code: DialogErrorCode.DIALOG_ERROR_PARAM_INVALID, message: `want is undefined` });
    }
    let wantParams: Record<string, object> = this.intentParams.want.parameters ?? {};
    if (wantParams['bundleName'] === undefined || wantParams['appUid'] === undefined) {
      return Promise.reject({ code: DialogErrorCode.DIALOG_ERROR_PARAM_INVALID, message: `wantParams is undefined` });
    }
    return new Promise<RequestAuthModel>(async (resolve, reject) => {
      try {
        /**
         * 获取参数
         */
        await this.model.parseParams(wantParams);
        /**
         * 加载证书
         */
        await this.model.loadCredential();
        resolve(this.model);
      } catch (err) {
        this.logger.error(`process load creds error, code: ${err?.code}, message: ${err?.message}`);
        return reject(err);
      }
    });
  }
}