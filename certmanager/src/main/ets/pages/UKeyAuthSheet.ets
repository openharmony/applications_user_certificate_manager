/**
 * Copyright (c) 2025-2025 Huawei Device Co., Ltd.
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

import hilog from '@ohos.hilog';
import { StringUtil } from '../common/util/StringUtil';
import { UIExtensionContentSession } from '@kit.AbilityKit';
import { DialogErrorCode } from '../model/CertMangerModel';

const DOMAIN = 0x0000;
const TAG = 'UKeyAuthSheet';

function hilogInfo(message: string): void {
  hilog.info(DOMAIN, TAG, message);
}
function hilogError(message: string): void {
  hilog.error(DOMAIN, TAG, message);
}

let storage = LocalStorage.getShared();

const CM_GETAPPUID_ERR_DEFAULT = -1;

@Entry(storage)
@Component
struct UKeyAuthSheet {
  private want: Want = storage?.get<Want>('want') as Want;
  private session: UIExtensionContentSession =
    storage?.get<UIExtensionContentSession>('session') as UIExtensionContentSession;
  private keyUri: string = '';
  private appUid: number = CM_GETAPPUID_ERR_DEFAULT;

  aboutToAppear() {
    let parameters = this.want.parameters;
    if (parameters === undefined || parameters === null) {
      hilogError(`parameters is undefinde`);
      return;
    }

    this.keyUri = (parameters['keyUri'] ?? '') as string;
    this.appUid = (parameters['appUid'] ?? CM_GETAPPUID_ERR_DEFAULT) as number;

    if (StringUtil.isEmpty(this.keyUri)) {
      hilogError(`check keyUri isEmpty`);
      this.session.terminateSelfWithResult({resultCode: DialogErrorCode.DIALOG_ERROR_PARAM_INVALID});
      return;
    }
    this.session.terminateSelfWithResult({resultCode: DialogErrorCode.DIALOG_ERROR_SA_INTERNAL_ERROR});
  }

  build() {
    
  }
}