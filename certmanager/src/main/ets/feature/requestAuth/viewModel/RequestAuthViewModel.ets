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
import RequestAuthModel from '../model/RequestAuthModel';
import certMgrDialog from '@ohos.security.certManagerDialog';
import { AuthIntent, AuthIntentParams } from '../intent/AuthIntent';
import AuthIntentProcessor from '../processor/AuthIntentProcessor';

@Observed
export default class RequestAuthViewModel {
  private model: RequestAuthModel = new RequestAuthModel();
  public isDisplaySheet: boolean = false;
  public bottomRectHeight: Length = 56;
  public buttonHeight: Length = 40;
  public hoverItemUri: string = '';
  public listPadding: Resource = $r('sys.float.padding_level4');

  public get bundleName(): string {
    return this.model.bundleName;
  }

  public get appUid(): number {
    return this.model.appUid;
  }

  public get appName(): string {
    return this.model.appName;
  }

  public get selectUri(): string {
    return this.model.selectUri;
  }

  public get serverUrl(): string {
    return this.model.serverUrl;
  }

  public get authedUri(): string {
    return this.model.authedUri;
  }

  public get installCredList(): Array<CredentialAbstractVo> {
    return this.model.appPublicCredList.concat(this.model.appPrivateCredList);
  }

  public get ukeyCredList(): Array<CredentialAbstractVo> {
    return this.model.ukeyCredList;
  }

  public get selectCertType(): certMgrDialog.CertificateType {
    return this.model.selectCertType;
  }

  public async dispatch(intent: AuthIntent, intentParams: AuthIntentParams): Promise<void> {
    let processor = new AuthIntentProcessor();
    this.model = await processor.process(this.model, intent, intentParams);
    return Promise.resolve();
  }
}