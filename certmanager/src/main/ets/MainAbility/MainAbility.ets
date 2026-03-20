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

import type Want from '@ohos.app.ability.Want';
import type Window from '@ohos.window';
import { GlobalContext, PwdStore } from '../common/GlobalContext';
import { AbilityConstant, ConfigurationConstant, UIAbility } from '@kit.AbilityKit';
import Logger from '../common/util/Logger';

const logger: Logger = new Logger('');

export default class MainAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    logger.info('MainAbility onCreate');

    if (want === null || want === undefined) {
      logger.error('invalid want param');
      return;
    }
    let pwdStore = new PwdStore();
    GlobalContext.getContext().setCmContext(this.context);
    GlobalContext.getContext().setPwdStore(pwdStore);
    GlobalContext.getContext().setAbilityWant(want);
    GlobalContext.getContext().setFlag(false);
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
  }

  onDestroy(): void {
    logger.info('MainAbility onDestroy');
  }

  onWindowStageCreate(windowStage: Window.WindowStage): void {
    // Main window is created, set main page for this ability
    logger.info('MainAbility onWindowStageCreate');
    windowStage.loadContent('pages/certManagerFa', (err, data) => {
      if (err.code) {
        logger.error('onWindowStageCreate failed, cause:' + JSON.stringify(err));
        return;
      }
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    logger.info('MainAbility onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    logger.info('MainAbility onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    logger.info('MainAbility onBackground');
  }

  onNewWant(want: Want): void {
    logger.info('MainAbility onNewWant');

    if (want === null || want === undefined) {
      logger.error('invalid want param');
      return;
    }
    GlobalContext.getContext().setAbilityWant(want);
  }
};
