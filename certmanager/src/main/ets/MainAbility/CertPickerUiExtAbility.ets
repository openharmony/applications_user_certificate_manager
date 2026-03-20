/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import Want from '@ohos.app.ability.Want';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { GlobalContext, PwdStore } from '../common/GlobalContext';
import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import { BusinessError } from '@ohos.base';
import Logger from '../common/util/Logger';

const logger: Logger = new Logger('CertPickerUiExtAbility');
const PAGE_CA_INSTALL = 5;
const PAGE_REQUEST_AUTHORIZE = 6;
const PAGE_UKEY_AUTH = 7;

export default class CertPickerUiExtAbility extends UIExtensionAbility {
  onCreate(): void {
    logger.info('CertPickerUiExtAbility onCreate');
  }

  onDestroy(): void {
    logger.info('CertPickerUiExtAbility onDestroy');
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    logger.info('CertPickerUiExtAbility onSessionCreate');

    if (want === null || want === undefined) {
      logger.error('invalid want param');
      return;
    }
    let param: Record<string, Object> = {
      'session': session,
      'want': want
    }
    let storage: LocalStorage = new LocalStorage(param);
    try {
      if (this.isStartToInstall(want.parameters)) {
        session.loadContent('pages/CertificateInstallPage', storage);
      } else if (this.isStartToAuthorize(want.parameters)) {
        session.loadContent('pages/RequestAuthSheet', storage);
      } else if (this.isStartToUkeyAuth(want.parameters)) {
        session.loadContent('pages/UKeyAuthSheet', storage);
      } else {
        session.loadContent('pages/picker/CertManagerSheetFa', storage);
        let pwdStore = new PwdStore();
        GlobalContext.getContext().setPwdStore(pwdStore);
        GlobalContext.getContext().setAbilityWant(want);
      }
    } catch (err) {
      let error = err as BusinessError;
      logger.error(`onSessionCreat load content failed: ${error?.code}, msg:${error?.message}`);
      session.terminateSelf();
      return;
    }

    try {
      session.setWindowBackgroundColor('#00000000');
    } catch (err) {
      logger.error('CertPickerUiExtAbility setWindowBackgroundColor');
    }
  }

  private isStartToInstall(parameters: Record<string, Object> | undefined): boolean {
    if (parameters === undefined) {
      return false;
    }
    return parameters['pageType'] === PAGE_CA_INSTALL;
  }

  private isStartToAuthorize(parameters: Record<string, Object> | undefined): boolean {
    if (parameters === undefined) {
      return false;
    }
    return parameters['pageType'] === PAGE_REQUEST_AUTHORIZE;
  }

  private isStartToUkeyAuth(parameters: Record<string, Object> | undefined): boolean {
    if (parameters === undefined) {
      return false;
    }
    return parameters['pageType'] === PAGE_UKEY_AUTH;
  }

  onSessionDestroy(): void {
    // Main window is destroyed, release UI related resources
    GlobalContext.getContext().clearSession();
    logger.info('CertPickerUiExtAbility onSessionDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    logger.info('CertPickerUiExtAbility onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    logger.info('CertPickerUiExtAbility onBackground');
  }
}
