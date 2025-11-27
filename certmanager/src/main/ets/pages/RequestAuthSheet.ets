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
import CmAppCredAuthPresenter from '../presenter/CmAppCredAuthPresenter';
import { common, UIExtensionContentSession } from '@kit.AbilityKit';
import certMangerModel, { CMModelErrorCode, DialogErrorCode } from '../model/CertMangerModel';
import { CredentialAbstractVo } from '../model/CertManagerVo/CredentialAbstractVo';
import { LengthMetrics, LengthUnit, SubHeader } from '@kit.ArkUI';
import hilog from '@ohos.hilog';
import certMgrDialog from '@ohos.security.certManagerDialog';
import { BusinessError } from '@ohos.base';
import certMgr from '@ohos.security.certManager'

const DOMAIN = 0x0000;
const TAG = 'RequestAuthSheet';

function hilogInfo(message: string): void {
  hilog.info(DOMAIN, TAG, message);
}
function hilogError(message: string): void {
  hilog.error(DOMAIN, TAG, message);
}

let storage = LocalStorage.getShared();

enum RequestAuthPageVersion {
  VERSION_DEFAULT = 0,
  VERSION_WITH_CERT_TYPES = 1,
}

@Entry(storage)
@Component
struct RequestAuthSheet {
  private version: RequestAuthPageVersion = RequestAuthPageVersion.VERSION_DEFAULT;
  private session: UIExtensionContentSession =
    storage?.get<UIExtensionContentSession>('session') as UIExtensionContentSession;
  private want: Want = storage?.get<Want>('want') as Want;
  private resultCode: number = DialogErrorCode.DIALOG_OPERATION_CANCELS;
  private appUid: string = '';
  certTypes: certMgrDialog.CertificateType[] = [certMgrDialog.CertificateType.CREDENTIAL_USER];
  certPurpose: certMgr.CertificatePurpose = certMgr.CertificatePurpose.PURPOSE_DEFAULT;
  @State private selectUri: string = ''
  @State private mAppCredAuthPresenter: CmAppCredAuthPresenter = CmAppCredAuthPresenter.getInstance();
  @State private isDisplaySheet: boolean = false;
  @State private bottomRectHeight: Length = 0;
  @State private buttonHeight: Length = 40;
  @State private isExtraLargeFontMode: boolean = false;
  @State private isAuthBtnOverflow: boolean = false;
  @State private hoverItemUri: string = '';
  @State private listPadding: Resource = $r('sys.float.padding_level4');
  @State private installCredList: CredentialAbstractVo[] = [];
  @State private ukeyCredList: CredentialAbstractVo[] = [];
  @State private selectCertType: certMgrDialog.CertificateType = certMgrDialog.CertificateType.CREDENTIAL_USER;

  pubCredListErrorCode: number = CMModelErrorCode.CM_MODEL_ERROR_SUCCESS;
  appCredListErrorCode: number = CMModelErrorCode.CM_MODEL_ERROR_SUCCESS;
  ukeyListErrorCode: number = CMModelErrorCode.CM_MODEL_ERROR_SUCCESS;

  getPublicCredList(): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      this.mAppCredAuthPresenter.updateAppNameFromUid(this.appUid);
      this.mAppCredAuthPresenter.updateAppCredList((code: CMModelErrorCode) => {
        if (code === CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION) {
          return reject({ code: code });
        }
        this.installCredList = this.installCredList.concat(this.mAppCredAuthPresenter.credList);
        return resolve();
      });
    })
  }

  getAppCredLIstByUid(): Promise<void> {
    return new Promise<void>(async (resolve, reject) => {
      try {
        let credList = await certMangerModel.getAllAppPrivateCertificates(Number(this.appUid));
        this.installCredList = this.installCredList.concat(credList);
        return resolve();
      } catch (e) {
        let err = e as BusinessError;
        hilogError(`getAppCredLIstByUid err, message: ${err.message}, code: ${err.code}`);
        return reject(err);
      }
    })
  }

  getUkeyList(): Promise<void> {
    return new Promise<void>(async (resolve, reject) => {
      try {
        let credList = await certMangerModel.getUkeyCertificateList(this.certPurpose);
        this.installCredList = this.installCredList.concat(credList);
        return resolve();
      } catch (e) {
        let err = e as BusinessError;
        hilogError(`getUkeyList err, message: ${err.message}, code: ${err.code}`);
        return reject(err);
      }
    })
  }

  async getCredListByCertType(certType: number) {
    try {
      if (certType === certMgrDialog.CertificateType.CREDENTIAL_USER) {
        await this.getPublicCredList().catch((err: BusinessError) => {
          this.pubCredListErrorCode = err.code;
        })
      } else if (certType === certMgrDialog.CertificateType.CREDENTIAL_APP) {
        await this.getAppCredLIstByUid().catch((err: BusinessError) => {
          this.appCredListErrorCode = err.code;
        })
      } else if (certType === certMgrDialog.CertificateType.CREDENTIAL_UKEY) {
        await this.getUkeyList().catch((err: BusinessError) => {
          this.ukeyListErrorCode = err.code;
        })
      }
    } catch (e) {
      let err = e as BusinessError;
      hilogError(`get certificateList failed, certType: ${certType}, errCode: ${err.code}`);
    }
  }

  async getCredList() {
    this.installCredList = [];
    this.ukeyCredList = [];
    for (let certType of this.certTypes) {
      try {
        await this.getCredListByCertType(certType);
      } catch (e) {
        let err = e as BusinessError;
        hilogError(`getCredList failed, certType: ${certType}, errCode: ${err.code}`);
      }
    }
  }

  async aboutToAppear() {
    let parameters = this.want.parameters;
    if (parameters === undefined || parameters === null) {
      hilogError(`parameters is undefinde`);
      return;
    }
    let callerBundleName: string = parameters['bundleName'] as string;
    if (callerBundleName == null || callerBundleName.length === 0) {
      hilogError(`bundleName is empty`);
      return;
    }
    hilogInfo(`USER_CERD_GRANT_APP ${callerBundleName}`);
    this.appUid = parameters['appUid'].toString();
    if (this.appUid == null || this.appUid.length === 0) {
      hilogError(`request auth appear failed`);
      this.session.terminateSelfWithResult({resultCode: DialogErrorCode.DIALOG_ERROR_PARAM_INVALID});
    }
    try {
      this.version = parameters['certTypes'] ? RequestAuthPageVersion.VERSION_DEFAULT :
        RequestAuthPageVersion.VERSION_WITH_CERT_TYPES;
      this.certTypes = (parameters['certTypes'] ?? [certMgrDialog.CertificateType.CREDENTIAL_USER]) as
        certMgrDialog.CertificateType[];
      this.mAppCredAuthPresenter.updateAppNameFromUid(this.appUid);

      await this.getCredList();
      if ((this.installCredList.length + this.ukeyCredList.length) > 0) {
        this.isDisplaySheet = true;
        return;
      }
      if (this.pubCredListErrorCode | this.appCredListErrorCode | this.ukeyListErrorCode) {
        this.session?.terminateSelfWithResult({ resultCode: DialogErrorCode.DIALOG_ERROR_INTERNAL });
        return;
      }
      if (this.version === RequestAuthPageVersion.VERSION_DEFAULT) {
        this.session?.terminateSelfWithResult({ resultCode: DialogErrorCode.DIALOG_OPERATION_CANCELS });
        return;
      } else {
        this.session?.terminateSelfWithResult({ resultCode: DialogErrorCode.DIALOG_ERROR_NO_CERTS_AVAILIBLE });
        return;
      }
    } catch (e) {
      let err = e as BusinessError;
      hilogError(`getCredList failed, errCode: ${err.code}, message: ${err.message}`);
      this.session?.terminateSelfWithResult({ resultCode: DialogErrorCode.DIALOG_ERROR_INTERNAL });
    }
  }

  private requestAuth() {
    if (this.selectUri == null || this.selectUri.length === 0) {
      return;
    }
    hilogInfo(`USER_CERD_GRANT_APP_SEL_CONFIRM authorize`);
    if (this.selectCertType === certMgrDialog.CertificateType.CREDENTIAL_APP ||
      this.selectCertType === certMgrDialog.CertificateType.CREDENTIAL_UKEY) {
      this.session?.sendData({
        'certType': this.selectCertType,
        'uri': this.selectUri
      })
      return;
    }
    if (this.appUid != null && this.appUid.length > 0) {
      this.mAppCredAuthPresenter.sheetRequestAuthorize(this.selectUri, this.appUid,
        (errCode: CMModelErrorCode, data: string) => {
          if (errCode === CMModelErrorCode.CM_MODEL_ERROR_SUCCESS) {
            this.session?.sendData({
              'certType': this.selectCertType,
              'uri': data
            });
          } else {
            this.resultCode = DialogErrorCode.DIALOG_ERROR_INTERNAL;
            this.isDisplaySheet = false;
          }
        });
    } else {
      this.session.terminateSelfWithResult({resultCode: DialogErrorCode.DIALOG_ERROR_PARAM_INVALID});
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
      .onClick(() => {
        this.requestAuth();
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
        ForEach(this.mAppCredAuthPresenter.credList, (item: CredentialAbstractVo) => {
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
                .padding({ top: this.listPadding, bottom: this.listPadding })

                Row() {
                  Blank().width(8)
                  Radio({ value: item.alias, group: 'appCredGroup' })
                    .checked(this.selectUri === item.keyUri)
                    .onChange((value: boolean) => {
                      if (value && this.selectUri !== item.keyUri) {
                        this.selectUri = item.keyUri;
                        this.selectCertType = item.certType ?? certMgrDialog.CertificateType.CREDENTIAL_UKEY;
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
          .onClick(() => {
            if (this.selectUri !== item.keyUri) {
              this.selectUri = item.keyUri;
              this.selectCertType = item.certType ?? certMgrDialog.CertificateType.CREDENTIAL_UKEY;
            }
          })
          .padding({ left: 8, right: 8 })
          .borderRadius(16)
          .stateStyles({
            normal: {
              .backgroundColor(this.hoverItemUri === item.keyUri ? $r('sys.color.interactive_hover') :
              Color.Transparent)
            },
            pressed: {
              .backgroundColor($r('sys.color.interactive_pressed'))
            }
          })
          .onHover((isHover: boolean) => {
            if (isHover) {
              this.hoverItemUri = item.keyUri;
            } else {
              this.hoverItemUri = '';
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

  @Builder
  private buildSheetContentComp() {
    Column() {
      Scroll() {
        Column() {
          Column() {
            Text($r('app.string.requestAuthMsg', this.mAppCredAuthPresenter.appName))
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontWeight(FontWeight.Regular)
              .alignSelf(ItemAlign.Start)
          }
          .width('100%')
          .padding({ left: 12, right: 12 })
          .margin({ top: 8, bottom: 8 })

          if (this.installCredList.length > 0) {
            this.buildCredListComp(this.installCredList, $r('app.string.installed_certs'))
          }
          if (this.ukeyCredList.length > 0) {
            this.buildCredListComp(this.installCredList, $r('app.string.ukey_certs'))
          }
        }
        .width('100%')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .align(Alignment.Top)
      .width('100%')
      .height(`calc(100% - ${this.buttonHeight}vp)`)

      Column() {
        this.buildOptBtn()
      }
      .width('100%')
      .onAreaChange((oldValue: Area, newValue: Area) => {
        this.buttonHeight = newValue.height;
      })
    }
    .padding({ left: 16, right: 16, bottom: this.bottomRectHeight })
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    Column() {
      Column() {
      }
      .bindSheet(this.isDisplaySheet, this.buildSheetContentComp, {
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