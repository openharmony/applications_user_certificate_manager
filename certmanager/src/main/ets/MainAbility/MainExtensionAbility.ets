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
import Logger from '../common/util/Logger';

const logger: Logger = new Logger('MainExtensionAbility');

export default class MainExtensionAbility extends UIExtensionAbility {
  onCreate(): void {
    logger.info('MainExtensionAbility onCreate');
  }

  onDestroy(): void {
    logger.info('MainExtensionAbility onDestroy');
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    logger.info('MainExtensionAbility onSessionCreate');

    if (want === null || want === undefined) {
      logger.error('invalid want param');
      return;
    }
    let param: Record<string, Object> = {
      'session': session,
      'want': want
    };
    let storage: LocalStorage = new LocalStorage(param);
    let pullType: string = want.parameters?.pullType?.toString() ?? '';

    if (pullType === 'systemCredInstall' || pullType === 'specifyInstall') {
      session.loadContent('pages/certInstallFromStorage', storage);
    } else {
      session.loadContent('pages/certManagerFa', storage);
    }
    GlobalContext.getContext().setAbilityWant(want);
    GlobalContext.getContext().setSession(session);
    let pwdStore = new PwdStore();
    GlobalContext.getContext().setPwdStore(pwdStore);
    GlobalContext.getContext().setFlag(true);
  }

  onSessionDestroy(): void {
    // Main window is destroyed, release UI related resources
    GlobalContext.getContext().clearSession();
    logger.info('MainExtensionAbility onSessionDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    logger.info('MainExtensionAbility onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    logger.info('MainExtensionAbility onBackground');
  }
}
