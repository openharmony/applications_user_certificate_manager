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
import { WidthPercent } from '../common/util/ConfigData';
import { UIExtensionContentSession } from '@kit.AbilityKit';
import { DialogErrorCode } from '../model/CertMangerModel';
import { CredentialAbstractVo } from '../model/CertManagerVo/CredentialAbstractVo';
import { LengthMetrics, LengthUnit, SubHeader } from '@kit.ArkUI';
import certMgrDialog from '@ohos.security.certManagerDialog';
import Logger from '../common/util/Logger';
import RequestAuthViewModel from '../feature/requestAuth/viewModel/RequestAuthViewModel';
import { AuthIntent } from '../feature/requestAuth/intent/AuthIntent';
import { StringUtil } from '../common/util/StringUtil';

let storage = LocalStorage.getShared();

@Entry(storage)
@Component
struct RequestAuthSheet {
  private logger: Logger = new Logger('RequestAuthSheet');
  private session: UIExtensionContentSession =
    storage?.get<UIExtensionContentSession>('session') as UIExtensionContentSession;
  private want: Want = storage?.get<Want>('want') as Want;
  private resultCode: number = DialogErrorCode.DIALOG_OPERATION_CANCELS;
  certTypes: certMgrDialog.CertificateType[] = [certMgrDialog.CertificateType.CREDENTIAL_USER];

  @State viewModel: RequestAuthViewModel = new RequestAuthViewModel();

  async aboutToAppear() {
    try {
      await this.viewModel.dispatch(AuthIntent.LOAD_CREDENTIALS, {
        session: this.session,
        want: this.want
      });
      this.viewModel.isDisplaySheet = true;
    } catch (err) {
      this.logger.error(`process intent LOAD_CREDENTIALS failed, code: ${err?.code}, message: ${err?.message}`);
      this.session.terminateSelfWithResult({ resultCode: err?.code ?? DialogErrorCode.DIALOG_ERROR_INTERNAL });
    }
  }

  @Builder
  private buildSheetTitle() {
    Row() {
      Text($r('app.string.pickCredToAuth'))
        .fontWeight(FontWeight.Bold)
        .fontSize($r('sys.float.ohos_id_text_size_headline8'))
        .fontColor($r('sys.color.font_primary'))
        .textOverflow({ overflow: TextOverflow.Ellipsis})
        .maxLines(1)
        .maxFontScale(1)
    }
    .width(WidthPercent.WH_100_100)
    .constraintSize({
      minHeight: $r('app.float.wh_value_56')
    })
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  private buildOptBtn() {
    Column() {
      Button() {
        Text($r('app.string.requestAuthFinish'))
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_emphasize'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis})
      }
      .buttonStyle(ButtonStyleMode.NORMAL)
      .type(ButtonType.ROUNDED_RECTANGLE)
      .width('100%')
      .constraintSize({
        minHeight: $r('app.float.wh_value_40')
      })
      .onClick(async () => {
        try {
          await this.viewModel.dispatch(AuthIntent.REQUEST_AUTH, {});
          this.session.sendData({
            'certType': this.viewModel.selectCertType,
            'uri': this.viewModel.authedUri
          })
        } catch (err) {
          this.logger.error(`click confirm error, code: ${err?.code}, message: ${err?.message}`);
        }
      })
    }
    .width('100%')
    .margin({
      top: $r('app.float.wh_value_16'),
      bottom: $r('app.float.wh_value_16'),
    })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  private buildCredListComp(credList: CredentialAbstractVo[], subTitle: ResourceStr) {
    Column() {
      SubHeader({
        secondaryTitle: subTitle,
        contentMargin: { start: LengthMetrics.vp(0), end: LengthMetrics.vp(0) },
        contentPadding: { start: LengthMetrics.vp(12), end: LengthMetrics.vp(12) },
      })
      List() {
        ForEach(credList, (item: CredentialAbstractVo) => {
          ListItem() {
            Column() {
              Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                Column() {
                  Text(item.alias)
                    .fontSize($r('app.float.font_18'))
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .fontWeight(FontWeight.Medium)
                    .textAlign(TextAlign.Start);
                }
                .alignItems(HorizontalAlign.Start)
                .padding({ top: this.viewModel.listPadding, bottom: this.viewModel.listPadding })

                Row() {
                  Blank().width(8)
                  Radio({ value: item.alias, group: 'appCredGroup' })
                    .checked(this.viewModel.selectUri === item.keyUri)
                    .onChange(async (value: boolean) => {
                      if (!value) {
                        return;
                      }
                      try {
                        await this.viewModel.dispatch(AuthIntent.CHANGE_SELECTED_CRED, {
                          selectUri: item.keyUri,
                          selectType: item.certType
                        });
                      } catch (err) {
                        this.logger.error(`process intent CHANGE_SELECTED_CRED failed.`)
                      }
                    })
                }
              }
              .width(WidthPercent.WH_100_100)
            }
          }
          .constraintSize({
            minHeight: 48
          })
          .onClick(async () => {
            try {
              await this.viewModel.dispatch(AuthIntent.CHANGE_SELECTED_CRED, {
                selectUri: item.keyUri,
                selectType: item.certType
              });
            } catch (err) {
              this.logger.error(`process intent CHANGE_SELECTED_CRED failed.`)
            }
          })
          .padding({ left: 8, right: 8 })
          .borderRadius(16)
          .stateStyles({
            normal: {
              .backgroundColor(this.viewModel.hoverItemUri === item.keyUri ? $r('sys.color.interactive_hover') :
              Color.Transparent)
            },
            pressed: {
              .backgroundColor($r('sys.color.interactive_pressed'))
            }
          })
          .onHover((isHover: boolean) => {
            if (isHover) {
              this.viewModel.hoverItemUri = item.keyUri;
            } else {
              this.viewModel.hoverItemUri = '';
            }
          })
          .focusBox({
            margin: {
              value: -2,
              unit: LengthUnit.VP
            }
          })
        }, (item: CredentialAbstractVo) => JSON.stringify(item) )
      }
      .divider({
        strokeWidth: '1px',
        color: $r('sys.color.ohos_id_color_list_separator'),
        startMargin: 8,
        endMargin: 8
      })
      .padding({
        top: 4,
        bottom: 4,
        left: 4,
        right: 4
      })
      .borderRadius(10)
      .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
      .scrollBar(BarState.Off)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST,
      })
    }          
  }

  getRequestAuthMsg(): ResourceStr {
    if (StringUtil.isNotEmpty(this.viewModel.serverUrl)) {
      return $r('app.string.requestAuthMsgWithUrl', this.viewModel.appName, this.viewModel.serverUrl);
    }
    return $r('app.string.requestAuthMsg', this.viewModel.appName);
  }

  @Builder
  private buildSheetContentComp() {
    Column() {
      Scroll() {
        Column() {
          Column() {
            Text(this.getRequestAuthMsg())
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontWeight(FontWeight.Regular)
              .alignSelf(ItemAlign.Start)
          }
          .width('100%')
          .padding({ left: 12, right: 12 })
          .margin({ top: 8, bottom: 8 })

          if (this.viewModel.installCredList.length > 0) {
            this.buildCredListComp(this.viewModel.installCredList, $r('app.string.installed_certs'))
          }
          if (this.viewModel.ukeyCredList.length > 0) {
            this.buildCredListComp(this.viewModel.ukeyCredList, $r('app.string.ukey_certs'))
          }
        }
        .width('100%')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .align(Alignment.Top)
      .width('100%')
      .height(`calc(100% - ${this.viewModel.buttonHeight}vp)`)

      Column() {
        this.buildOptBtn()
      }
      .width('100%')
      .onAreaChange((oldValue: Area, newValue: Area) => {
        this.viewModel.buttonHeight = newValue.height;
      })
    }
    .padding({ left: 16, right: 16, bottom: this.viewModel.bottomRectHeight })
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    Column() {
      Column() {
      }
      .bindSheet(this.viewModel.isDisplaySheet, this.buildSheetContentComp, {
        height: '100%',
        title: this.buildSheetTitle,
        showClose: true,
        onDisappear: () => {
          this.session.terminateSelfWithResult({resultCode: this.resultCode});
        }
      })
    }
  }
}