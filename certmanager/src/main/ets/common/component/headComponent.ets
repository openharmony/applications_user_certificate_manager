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
import ComponentConfig from './ComponentConfig';
import Router from '@ohos.router';
import { GlobalContext } from '../GlobalContext';
import Logger from '../util/Logger';

const logger: Logger = new Logger('HeadComponent');

/**
 * head custom component
 */
@Component
export default struct HeadComponent {
  private icBackIsVisibility: boolean = true;
  private headName: string | Resource = '';
  @State isTouch: boolean = false;

  isStartBySheet: boolean = false;
  onBackClicked?: () => void;

  build() {
    Row() {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.ic_back'))
          .fillColor($r('sys.color.ohos_id_color_primary'))
          .objectFit(ImageFit.Contain)
          .height($r('app.float.wh_value_32'))
          .width($r('app.float.wh_value_32'))
          .draggable(false)
      }
      .height($r('app.float.wh_value_34'))
      .width($r('app.float.wh_value_34'))
      .borderRadius($r('app.float.wh_value_17'))
      .backgroundColor(this.isTouch ? $r('sys.color.ohos_id_color_click_effect')
        : $r('app.color.color_D9E2E2E2_grey'))
      .visibility(this.icBackIsVisibility ? Visibility.Visible : Visibility.None)
      .onClick(() => {
        if (this.isStartBySheet) {
          this.onBackClicked?.();
          return;
        }
        let length = Router.getLength();
        logger.info('router length: ' + Number(length));
        if (GlobalContext.getContext().getFlag()) {
          Number(length) == 1 ? GlobalContext.getContext().getSession().sendData({'action': 'exit'}) : Router.back();
        } else {
          Number(length) == 1 ? GlobalContext.getContext().getCmContext().terminateSelf() : Router.back();
        }
      })
      .onTouch((event?: TouchEvent) => {
        if (event?.type === TouchType.Down) {
          this.isTouch = true;
        }
        if (event?.type === TouchType.Up) {
          this.isTouch = false;
        }
      });

      Text(this.headName)
        .align(Alignment.Start)
        .fontSize($r('app.float.head_font_20'))
        .fontFamily('HarmonyHeiTi-Bold')
        .fontWeight(FontWeight.Medium)
        .maxFontScale(1)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .maxLines(ComponentConfig.MAX_LINES_1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center)
        .margin({ left: $r('app.float.wh_value_4') })
    }
    .width(ComponentConfig.WH_100_100)
    .height($r('app.float.wh_value_56'))
    .alignItems(VerticalAlign.Center)
    .align(Alignment.Start)
  }
}
