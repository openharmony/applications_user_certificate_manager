/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
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

import { window } from '@kit.ArkUI';
import { BusinessError } from '@ohos.base';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { GlobalContext } from '../GlobalContext';
import Logger from './Logger';

const logger: Logger = new Logger('StatusBarPaddingUtil');

/**
 * Determines whether manual status bar padding is required when opening a page:
 * UIExtension uses host position; UIAbility uses isLayoutFullScreen.
 */
export function updateStatusBarPaddingByImmersive(context: Context,
  onResult: (topPadding: number) => void): void {
  try {
    const session = GlobalContext.getContext().getSession();
    if (session !== undefined && session !== null) {
      onResult(resolveUiExtensionStatusBarPadding(session));
      return;
    }
    resolveUiAbilityStatusBarPadding(context, onResult);
  } catch (error) {
    const err: BusinessError = error as BusinessError;
    logger.error('updateStatusBarPaddingByImmersive error: ' + err.code + ', ' + err.message);
    const cached: number | undefined = AppStorage.get('STATUS_BAR_HEIGHT') as number | undefined;
    onResult(cached !== undefined ? cached : 0);
  }
}

/**
 * UIExtension scenario: determine whether manual status bar padding is required based on host position.
 */
function resolveUiExtensionStatusBarPadding(session: UIExtensionContentSession): number {
  const extensionWindow = session.getUIExtensionWindowProxy();
  const area: window.AvoidArea =
    extensionWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
  const barHeight: number = px2vp(area.topRect.height);
  let needPadding: boolean = true;

  const hostRect: window.Rect = extensionWindow.properties.uiExtensionHostWindowProxyRect;
  if (hostRect !== undefined && hostRect !== null) {
    const hostTop: number = px2vp(hostRect.top);
    needPadding = hostTop < barHeight - 2;
    logger.info('hostTop=' + hostTop + ', barHeight=' + barHeight + ', needPadding=' + needPadding);
  } else {
    logger.info('hostRect unavailable, barHeight=' + barHeight);
  }

  const topPadding: number = needPadding ? barHeight : 0;
  AppStorage.setOrCreate('STATUS_BAR_HEIGHT', topPadding);
  return topPadding;
}

/**
 * UIAbility scenario: determine whether manual status bar padding is required based on isLayoutFullScreen.
 */
function resolveUiAbilityStatusBarPadding(context: Context,
  onResult: (topPadding: number) => void): void {
  window.getLastWindow(context).then((win: window.Window) => {
    const isLayoutFullScreen: boolean = win.getWindowProperties().isLayoutFullScreen;
    const barHeight: number =
      px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height);
    const topPadding: number = isLayoutFullScreen ? barHeight : 0;
    AppStorage.setOrCreate('STATUS_BAR_HEIGHT', topPadding);
    logger.info('isLayoutFullScreen=' + isLayoutFullScreen + ', statusBarHeight=' + topPadding);
    onResult(topPadding);
  }).catch((err: BusinessError) => {
    logger.error('getLastWindow failed: ' + err.code + ', ' + err.message);
    const cached: number | undefined = AppStorage.get('STATUS_BAR_HEIGHT') as number | undefined;
    onResult(cached !== undefined ? cached : 0);
  });
}
