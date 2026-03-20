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

import { StringUtil } from '../common/util/StringUtil';
import { UIExtensionContentSession } from '@kit.AbilityKit';
import { DialogErrorCode } from '../model/CertMangerModel';
import { SYSCAP_HUKS_CRYPTO_EXTENTION } from '../common/constants/CertManagerConstants';
import Logger from '../common/util/Logger';

const logger: Logger = new Logger('UKeyAuthSheet');

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
      logger.error(`parameters is undefinde`);
      this.session.terminateSelfWithResult({resultCode: DialogErrorCode.DIALOG_ERROR_PARAM_INVALID});
      return;
    }

    if (!canIUse(SYSCAP_HUKS_CRYPTO_EXTENTION)) {
      this.session.terminateSelfWithResult({resultCode: DialogErrorCode.DIALOG_ERROR_CAPACITY_NOT_SUPPORT});
      return;
    }

    this.keyUri = (parameters['keyUri'] ?? '') as string;
    this.appUid = (parameters['appUid'] ?? CM_GETAPPUID_ERR_DEFAULT) as number;

    if (StringUtil.isEmpty(this.keyUri)) {
      logger.error(`check keyUri isEmpty`);
      this.session.terminateSelfWithResult({resultCode: DialogErrorCode.DIALOG_ERROR_PARAM_INVALID});
      return;
    }
    this.session.terminateSelfWithResult({resultCode: DialogErrorCode.DIALOG_ERROR_SA_INTERNAL_ERROR});
  }

  build() {
    
  }
}