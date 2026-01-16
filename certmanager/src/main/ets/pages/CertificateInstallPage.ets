/**
 * Copyright (c) 2024-2024 Huawei Device Co., Ltd.
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

import { CustomContentDialog, AlertDialog } from '@ohos.arkui.advanced.Dialog';
import { CMModelErrorCode, CMModelOptType, DialogErrorCode, CmDialogOperationType } from '../model/CertMangerModel';
import checkUserAuthModel from '../model/CheckUserAuthModel';
import { BusinessError } from '@ohos.base';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import certManagerModel from '../model/CertMangerModel';
import util from '@ohos.util';
import certMgrDialog from '@ohos.security.certManagerDialog';
import { Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { deviceInfo } from '@kit.BasicServicesKit';

/* instrument ignore file */

const TAG = 'CertificateInstallPage';
const DOMAIN = 0x0000;
function hilogInfo(message: string): void {
  hilog.info(DOMAIN, TAG, message);
}
function hilogError(message: string): void {
  hilog.error(DOMAIN, TAG, message);
}

let storage = LocalStorage.getShared();

@Entry(storage)
@Component
struct CertificateInstallPage {
  @State installFailedDialogMessage: ResourceStr = '';
  @State callerName: string = '';
  @State resultCode: number = CMModelErrorCode.CM_MODEL_ERROR_FAILED;
  @State successUri: string = '';
  operationType: number = 0;
  certType: number = 0;
  private session: UIExtensionContentSession =
    storage?.get<UIExtensionContentSession>('session') as UIExtensionContentSession;
  private want: Want = storage?.get<Want>('want') as Want;
  private params: Record<string, object> = {};

  private context: Context = getContext(this);

  installFailedDialog: CustomDialogController = new CustomDialogController({
    alignment: DialogAlignment.Center,
    showInSubWindow: false,
    cancel: () => {
      this.session?.terminateSelfWithResult({
        resultCode: this.resultCode
      });
    },
    builder: AlertDialog({
      primaryTitle: $r('app.string.cert_install_failed'),
      content: this.installFailedDialogMessage,
      primaryButton: {
        value: $r('app.string.OK'),
        action: () => {
          this.session?.terminateSelfWithResult({
            resultCode: this.resultCode
          });
        }
      }
    })
  });

  installSuccessDialog: CustomDialogController = new CustomDialogController({
    alignment: DialogAlignment.Center,
    showInSubWindow: true,
    cancel: () => {
      this.session?.sendData({'uri': this.successUri});
    },
    builder: AlertDialog({
      primaryTitle: $r('app.string.cert_install_success'),
      content: $r('app.string.cert_install_success_tip'),
      primaryButton: {
        value: $r('app.string.OK'),
        action: () => {
          this.session?.sendData({'uri': this.successUri});
        }
      }
    })
  });

  rootCertificateDialog: CustomDialogController = new CustomDialogController({
    alignment: DialogAlignment.Center,
    showInSubWindow: false,
    cancel: () => {
      this.session?.terminateSelf();
    },
    builder: AlertDialog({
      primaryTitle: $r('app.string.cert_install_tip', this.callerName),
      content: $r('app.string.cert_install_warning'),
      primaryButton: {
        value: $r('app.string.root_certificate_cancel'),
        action: () => {
          hilogInfo('USER_CA_STATUS_CONFIRM cancel');
          this.session?.terminateSelf();
        }
      },
      secondaryButton: {
        value: $r('app.string.root_certificate_continue'),
        action: () => {
          hilogInfo('USER_CA_STATUS_CONFIRM confirm');
          this.checkUserAuth();
        }
      }
    }),
  })

  aboutToAppear(): void {
    if (this.want === undefined || this.want === null) {
      hilogError('initData, want is undefined');
      this.session?.terminateSelf();
      return;
    }
    this.params = this.want.parameters ?? {};
    let isGranted = this.getCallerName();
    if (!isGranted) {
      this.session?.terminateSelf();
      return;
    }
    if (this.params === undefined) {
      hilogError('check parameters undefined');
      this.session.terminateSelfWithResult({resultCode: DialogErrorCode.DIALOG_ERROR_PARAM_INVALID});
      return;
    }
    this.operationType = Number(this.params['operationType']);
    this.certType = Number(this.params['certType']);
    if (this.operationType !== CmDialogOperationType.INSTALL) {
      hilogError('check operation type unsupport');
      this.session.terminateSelfWithResult({resultCode: DialogErrorCode.DIALOG_ERROR_NOT_ENTERPRISE_DEVICE});
      return;
    }
    if (this.certType === certMgrDialog.CertificateType.CA_CERT) {
      this.rootCertificateDialog.open();
    } else if (this.certType === certMgrDialog.CertificateType.CREDENTIAL_USER ||
      this.certType === certMgrDialog.CertificateType.CREDENTIAL_SYSTEM) {
      this.inputPwdDialog.open();
    } else {
      hilogError('check cert type invalid');
      this.session.terminateSelfWithResult({resultCode: DialogErrorCode.DIALOG_ERROR_PARAM_INVALID});
      return;
    }
  }

  textInputController: TextInputController = new TextInputController()
  @State isPasswordError: boolean = false;
  certPwd: string = '';

  cancelInstallCred(): void {
    hilogInfo('install cred cancel');
    this.inputPwdDialog.close();
    this.session.terminateSelfWithResult({resultCode: DialogErrorCode.DIALOG_OPERATION_CANCELS});
    return;
  }

  private handleCredInstallResult(resultCode: CMModelErrorCode, uri: string) {
    if (resultCode === CMModelErrorCode.CM_MODEL_ERROR_SUCCESS) {
      this.session?.sendData({'uri': uri});
      this.inputPwdDialog.close();
    } else if (resultCode === CMModelErrorCode.CM_MODEL_ERROR_INCORRECT_FORMAT) {
      hilogError('install cred data incorrect format');
      this.inputPwdDialog.close();
      this.resultCode = DialogErrorCode.DIALOG_ERROR_INCORRECT_FORMAT;
      this.installFailedDialogMessage = $r('app.string.Install_ERROR_INCORRECT_FORMAT');
      this.installFailedDialog.open();
    } else if (resultCode === CMModelErrorCode.CM_MODEL_ERROR_MAX_QUANTITY_REACHED) {
      hilogError('install cred max quantity reached');
      this.inputPwdDialog.close();
      this.resultCode = DialogErrorCode.DIALOG_ERROR_MAX_QUANTITY_REACHED;
      this.installFailedDialogMessage = $r('app.string.Install_Error_MAX_QUANTITY_REACHED');
      this.installFailedDialog.open();
    } else if (resultCode === CMModelErrorCode.CM_MODEL_ERROR_PASSWORD_ERR) {
      hilogInfo('install cred pwd incorrect');
      this.isPasswordError = true;
      this.textInputController.setTextSelection(0, this.certPwd.length, { menuPolicy: MenuPolicy.HIDE })
    }else {
      this.inputPwdDialog.close();
      hilogError(`result code ${resultCode}, need not show result`);
      this.session?.terminateSelfWithResult({
        resultCode: resultCode
      });
    }
  }

  installCred() {
    let optType: CMModelOptType = CMModelOptType.CM_MODEL_OPT_UNKNOWN;
    if (this.certType === certMgrDialog.CertificateType.CREDENTIAL_USER) {
      optType = CMModelOptType.CM_MODEL_OPT_APP_CRED;
    } else if (this.certType === certMgrDialog.CertificateType.CREDENTIAL_USER) {
      optType = CMModelOptType.CM_MODEL_OPT_SYSTEM_CRED;
    } else {
      hilogError('check cert type unsupport');
      this.session.terminateSelfWithResult({resultCode: DialogErrorCode.DIALOG_ERROR_PARAM_INVALID});
      return;
    }
    let credString: string = this.params['cert']?.toString() ?? '';
    let credData: Uint8Array = new util.Base64Helper().decodeSync(credString);

    certManagerModel.installCertOrCred(optType, '', credData,
      this.certPwd, (errCode: CMModelErrorCode, uri: string) => {
        this.handleCredInstallResult(errCode, uri ?? '');
      });
  }

  @Builder
  buildInputPwdComp() {
    Column() {
      Row() {
        TextInput({ controller: this.textInputController })
          .type(InputType.Password)
          .fontColor($r('sys.color.font_primary'))
          .focusable(true)
          .defaultFocus(true)
          .border({
            width: 1,
            color: this.isPasswordError ? $r('sys.color.warning') : Color.Transparent
          })
          .onChange((value: string) => {
            this.certPwd = value;
          })
          .onSubmit((eventKey: EnterKeyType, event: SubmitEvent) => {
            this.installCred();
            event.keepEditableState();
          })
      }

      Row() {
        Text(this.isPasswordError ? $r('app.string.Password_Message') : ' ')
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontColor($r('sys.color.warning'))
          .margin({
            top: 8
          })
      }

      Row() {
        GridRow({columns: 2, gutter: {x: 16}}) {
          GridCol({span: 1}) {
            Button($r('app.string.warning_cancel'))
              .buttonStyle(ButtonStyleMode.NORMAL)
              .type(ButtonType.ROUNDED_RECTANGLE)
              .labelStyle({
                maxLines: 1
              })
              .width('100%')
              .onClick(() => {
                this.cancelInstallCred();
              })
          }
          GridCol({span: 1}) {
            Button($r('app.string.inputConfirm'))
              .buttonStyle(ButtonStyleMode.NORMAL)
              .type(ButtonType.ROUNDED_RECTANGLE)
              .labelStyle({
                maxLines: 1
              })
              .width('100%')
              .onClick(() => {
                this.installCred();
              })
          }
        }
      }
      .padding({
        top: 16
      })
    }
  }

  private getInstallCredSubtitle(): ResourceStr {
    if (this.certType === certMgrDialog.CertificateType.CREDENTIAL_USER) {
      return $r('app.string.install_user_cred_subtitle', this.callerName);
    } else if (this.certType === certMgrDialog.CertificateType.CREDENTIAL_SYSTEM) {
      return $r('app.string.install_system_cred_subtitle', this.callerName);
    } else {
      return '';
    }
  }

  inputPwdDialog: CustomDialogController = new CustomDialogController({
    alignment: DialogAlignment.Center,
    showInSubWindow: false,
    cancel: () => {
      this.cancelInstallCred();
    },
    builder: CustomContentDialog({
      primaryTitle: $r('app.string.certInputPassword'),
      secondaryTitle: this.getInstallCredSubtitle(),
      contentBuilder: () => { this.buildInputPwdComp() },
    }),
  })

  build() {
  }

  private getCallerName(): boolean {
    if (this.params === undefined || this.params === null) {
      hilogError('initData, parameters is undefined');
      return false;
    }
    let callerName = this.params['bundleName']?.toString();
    if (callerName === undefined || callerName === null) {
      hilogError('getCallerName, callerName is undefined');
      return false;
    }
    this.callerName = String(callerName);
    return true;
  }

  private handleInstallResult(resultCode: CMModelErrorCode, uri: string) {
    if (resultCode === CMModelErrorCode.CM_MODEL_ERROR_SUCCESS) {
      this.successUri = uri;
      this.installSuccessDialog.open();
    } else if (resultCode === CMModelErrorCode.CM_MODEL_ERROR_INCORRECT_FORMAT) {
      this.resultCode = CMModelErrorCode.CM_MODEL_ERROR_INCORRECT_FORMAT;
      this.installFailedDialogMessage = $r('app.string.Install_ERROR_INCORRECT_FORMAT');
      this.installFailedDialog.open();
    } else if (resultCode === CMModelErrorCode.CM_MODEL_ERROR_MAX_QUANTITY_REACHED) {
      this.resultCode = CMModelErrorCode.CM_MODEL_ERROR_MAX_QUANTITY_REACHED;
      this.installFailedDialogMessage = $r('app.string.Install_Error_MAX_QUANTITY_REACHED');
      this.installFailedDialog.open();
    } else {
      hilogInfo(`result code ${resultCode}, need not show result`);
      this.session?.terminateSelfWithResult({
        resultCode: resultCode
      });
    }
  }

  checkUserAuth() {
    let titleStr = this.context?.resourceManager.getStringSync($r('app.string.Identity_Authentication'));
    checkUserAuthModel.auth(titleStr, (authResult: boolean) => {
      if (!authResult) {
        hilogInfo('userAuth cancel!');
        this.session?.terminateSelf();
        return;
      }
      hilogInfo('userAuth success!');
      this.installCaCertificate();
    })
  }

  private async getCertificateData(parameters: Record<string, Object>): Promise<Uint8Array | undefined> {
    return new Promise<Uint8Array | undefined>(resolve => {
      let certificateDataObj = parameters['cert'];
      if (certificateDataObj === undefined || certificateDataObj === null) {
        hilogError('getCertificateData, certificate data is undefined');
        return resolve(undefined);
      }
      new util.Base64Helper().decode(certificateDataObj as string).then((value) => {
        return resolve(value);
      }).catch((error: BusinessError) => {
        hilogError(`decode certificate data err: ${error?.code}, msg: ${error?.message}`);
        return resolve(undefined);
      });
    });
  }

  private installCaCertificate(): void {
    if (this.want === undefined || this.want === null) {
      hilogError('initData, want is undefined');
      return;
    }
    if (this.params === undefined || this.params === null) {
      hilogError('initData, parameters is undefined');
      return;
    }
    this.getCertificateData(this.params).then(data => {
      if (data === undefined) {
        hilogError('installCaCertificate, certificate data is undefined');
        this.session?.terminateSelf();
        return;
      }
      certManagerModel.installCertOrCred(CMModelOptType.CM_MODEL_OPT_USER_CA, '', data,
        '', (resultCode: CMModelErrorCode, uri: string) => {
          hilogInfo(`installCertOrCred result: ${resultCode}`);
          this.handleInstallResult(resultCode, uri);
        });
    })
  }
}