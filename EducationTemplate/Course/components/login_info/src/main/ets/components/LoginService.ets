/*
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

import { display, window } from '@kit.ArkUI';
import { authentication, loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { AgreementDialog } from './AgreementDialog';
import { LoginVM } from '../viewmodel/LoginVM';
import { ExtraInfo } from '../model/Index';

const TAG: string = 'QuickLoginButtonComponent';

@ComponentV2
export struct QuickLogin {
  // app名字
  @Param @Require appName: string = ''
  @Param extraInfo: ExtraInfo = new ExtraInfo();
  // 是否显示半屏模态页面
  @Param isBindContentCover: boolean = false;
  /**
   * 应用icon
   */
  @Param @Require icon: ResourceStr = $r('app.media.ic_launch');
  /**
   * 一键登录按钮背景色
   */
  @Param loginBtnBgColor: ResourceStr = $r('sys.color.multi_color_01');
  /*
 * 模态弹窗消失事件
 * */
  @Param shouldDismiss: () => void = () => {
  }
  /**
   * 登录成功回调
   */
  @Param loginFinished: (flag: boolean, unionId?: string) => void = () => {
  };
  /**
   * 隐私政策
   */
  @Param privacyPolicy: () => void = () => {
  };
  /**
   * 用户服务协议
   */
  @Param userService: () => void = () => {
  };
  /*
  * 华为用户账号认证点击事件
  * */
  @Param onAuthentication: () => void = () => {
  }
  @Local unionID: string = '';
  @Local openID: string = '';
  @Local phoneNum: string = '';
  @Local inputPhoneNum: string = '177******96';
  @Local passWord: string = '';
  // 是否勾选协议
  @Local isSelected: boolean = false;
  @Local isShow: boolean = false;
  // 窗口状态
  @Local windowStatusType: number = 0;
  // 高度
  @Local contentHeight: number = 0;
  @Local loginType: number = LoginType.HUAWEI;
  uiContext: UIContext = this.getUIContext()
  loginData: Record<string, Object> = {
    'isLogin': false,
    'show': '',
    'hint': '',
  };
  error?: BusinessError;
  controller: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
    // 需要用户同意协议才能完成华为账号登录，请先设置协议状态为NOT_ACCEPTED，当用户同意协议后设置协议状态为ACCEPTED，才可以完成华为账号登录
      .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
      .onClickLoginWithHuaweiIDButton((error: BusinessError, response: loginComponentManager.HuaweiIDCredential) => {
        // 处理用户点击一键登录按钮逻辑，灰度传入undefined模拟流程，应用申请权限后，传入error
        this.handleLoginWithHuaweiIDButton(error, response);
      });
  privacyText: loginComponentManager.PrivacyText[] = [
    {
      text: '已阅读并同意',
      type: loginComponentManager.TextType.PLAIN_TEXT
    }, {
    text: '《用户服务协议》',
    tag: '用户服务协议',
    type: loginComponentManager.TextType.RICH_TEXT
  }, {
    text: '《' + this.appName + '隐私协议》',
    tag: '《' + this.appName + '隐私协议》',
    type: loginComponentManager.TextType.RICH_TEXT
  }, {
    text: '和',
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: '《华为账号用户认证协议》',
    tag: '华为账号用户认证协议',
    type: loginComponentManager.TextType.RICH_TEXT
  }];
  agreementDialog: CustomDialogController = new CustomDialogController({
    builder: AgreementDialog({
      privacyText: this.privacyText,
      cancel: () => {
        this.agreementDialog.close();
        this.customerDiaLogOpen = false;
        // 设置协议状态为NOT_ACCEPTED
        this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
      },
      confirm: () => {
        this.isSelected = true;
        this.agreementDialog.close();
        this.customerDiaLogOpen = false;
        if (this.loginType === LoginType.HUAWEI) {
          // 设置协议状态为ACCEPTED
          this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
          this.controller.continueLogin((error: BusinessError) => {
          })
        } else if (this.loginType === LoginType.PHONE) {
          if (this.inputPhoneNum.trim() === '') {
            this.showToast('请输入手机号');
            return
          }
          if (this.passWord.trim() === '') {
            this.showToast('请输入密码');
            return
          }
          this.loginFinished(false)
        } else if (this.loginType === LoginType.WECHAT) {
          this.vm.loginFinished = () => {
            // 模拟登录成功后回调
            this.loginFinished(false)
          }
          this.vm.wxLogin(this.extraInfo);
        } else {
          this.loginFinished(false)
        }
      },
      clickHyperlinkText: (tag) => {
        this.agreementDialog.close();
        if (tag === '华为账号用户认证协议') {
          this.onAuthentication();
        } else if (tag === '用户服务协议') {
          this.userService()
        } else if (tag === '《课堂隐私协议》') {
          this.privacyPolicy()
        }
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
  });
  response: loginComponentManager.HuaweiIDCredential = {} as loginComponentManager.HuaweiIDCredential;
  // 弹窗是否已开启
  customerDiaLogOpen: boolean = false;
  inputController: TextInputController = new TextInputController();
  vm: LoginVM = LoginVM.instance;

  @Builder
  CoverLogin() {
    Scroll() {
      Column() {
        this.AppIcon()
        if (this.loginType === LoginType.HUAWEI) {
          this.AnonymousPhone()
        } else {
          this.UserPhone()
        }
        Blank()
          .layoutWeight(1)
        this.privacyCheckbox()
      }
      .width('100%')
      .height(this.contentHeight)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceAround)
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .scrollBar(BarState.Off)
    .scrollable(ScrollDirection.Vertical)
    .edgeEffect(this.windowStatusType === 5 ? EdgeEffect.Spring : EdgeEffect.None)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  DefaultLogin() {
    Column() {
      this.AppIcon()
      if (this.loginType === LoginType.HUAWEI) {
        this.AnonymousPhone()
      } else {
        this.UserPhone()
      }
      this.privacyCheckbox()
    }
    .width('100%')
    .height(550)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceAround)
  }

  @Builder
  AppIcon() {
    Column() {
      Image(this.icon)
        .width(72)
        .height(72)
        .draggable(false)
        .copyOption(CopyOptions.None)
        .borderRadius(16)
        .margin({ top: this.isBindContentCover ? 118 : 48 })
        .onComplete(() => {
        })
        .onError(() => {
        });
    }
  }

  @Builder
  AnonymousPhone() {
    Column() {
      Text(this.phoneNum)
        .fontSize($r('sys.float.Title_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)

      Text('华为账号绑定号码')
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Center)
        .margin({ top: 4 });

      LoginWithHuaweiIDButton({
        params: {
          style: loginComponentManager.Style.BUTTON_CUSTOM,
          loginType: loginComponentManager.LoginType.QUICK_LOGIN,
          supportDarkMode: true,
          customButtonParams: {
            fontColor: loginComponentManager.FontColor.WHITE,
            backgroundColor: this.loginBtnBgColor,
          },
        },
        controller: this.controller,
      })
        .height(48)
        .width('100%')
        .margin({ top: 48, bottom: 12 })

      Button({
        type: ButtonType.Capsule,
        stateEffect: true,
      }) {
        Text('其他方式登录')
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
      }
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .height(48)
      .width('100%')
      .onClick(() => {
        this.isShow = true;
        this.loginType = LoginType.PHONE
      })
    }
    .margin({ top: 40 })
  }

  @Builder
  UserPhone() {
    Column() {
      TextInput({ text: '177******96', placeholder: '请输入手机号', controller: this.inputController })
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .type(InputType.PhoneNumber)
        .width('100%')
        .height(48)
        .backgroundColor(Color.White)
        .maxLength(11)
        .onChange((text) => {
          this.inputPhoneNum = text;
        })

      TextInput({ text: '******', placeholder: '请输入密码', controller: this.inputController })
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .type(InputType.Password)
        .width('100%')
        .height(48)
        .backgroundColor(Color.White)
        .margin({ top: 16 })
        .onChange((text) => {
          this.passWord = text;
        })
      Button({
        type: ButtonType.Capsule,
        stateEffect: true,
      }) {
        Text('登录')
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Medium)
      }
      .backgroundColor($r('sys.color.multi_color_01'))
      .height(48)
      .width('100%')
      .margin({ top: this.isBindContentCover ? 48 : 20 })
      .onClick(() => {
        this.loginType = LoginType.PHONE
        if (this.inputPhoneNum.trim() === '') {
          this.showToast('请输入手机号');
          return
        }
        if (this.passWord.trim() === '') {
          this.showToast('请输入密码');
          return
        }
        if (this.isSelected) {
          this.loginFinished(true)
        } else {
          this.agreementDialog.open();
          this.customerDiaLogOpen = true;
        }
      })

      Column() {
        Text('其他方式登录')
          .fontSize($r('sys.float.Caption_L'))
          .fontColor($r('sys.color.font_tertiary'))
          .fontWeight(FontWeight.Regular)

        Row() {
          Column() {
            Image($r('app.media.icon_login_huawei'))
              .margin({ bottom: 8 })
              .width(48)
              .height(48)
              .borderRadius(24)

            Text('华为账号一键登录')
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_tertiary'))
              .fontWeight(FontWeight.Regular)
          }
          .width(80)
          .height(70)
          .onClick(() => {
            this.loginType = LoginType.HUAWEI
          })

          Column() {
          }
          .width(48)
          .height(70)

          Column() {
            Image($r('app.media.icon_login_wechat'))
              .backgroundColor(Color.Red)
              .margin({ bottom: 8 })
              .width(48)
              .height(48)
              .borderRadius(24)

            Text('微信')
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_tertiary'))
              .fontWeight(FontWeight.Regular)
          }
          .width(80)
          .height(70)
          .onClick(() => {
            this.loginType = LoginType.WECHAT
            if (this.isSelected) {
              this.vm.loginFinished = () => {
                // 模拟登录成功后回调
                this.loginFinished(false)
              }
              this.vm.wxLogin(this.extraInfo);
            } else {
              this.agreementDialog.open();
              this.customerDiaLogOpen = true;
            }
          })
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .height(100)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({ top: this.isBindContentCover ? 48 : 20 })
    }
    .margin({ top: 40 })
  }

  @Builder
  privacyCheckbox() {
    Row() {
      Checkbox({ name: 'privacyCheckbox', group: 'privacyCheckboxGroup' })
        .width(20)
        .height(20)
        .focusable(true)
        .focusOnTouch(true)
        .selectedColor($r('sys.color.comp_background_emphasize'))
        .select(this.isSelected)
        .onChange((value: boolean) => {
          if (value) {
            this.isSelected = true;
            // 设置协议状态为ACCEPTED
            this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
          } else {
            this.isSelected = false;
            // 设置协议状态为NOT_ACCEPTED
            this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
          }
        })

      Text() {
        this.BuildSpan(this.privacyText[0].text, $r('sys.color.font_secondary'), FontWeight.Regular, 0);

        this.BuildSpan(this.privacyText[1].text, $r('sys.color.font_primary'), FontWeight.Medium, 1,);

        this.BuildSpan(this.privacyText[2].text, $r('sys.color.font_primary'), FontWeight.Medium, 2);

        this.BuildSpan(this.privacyText[3].text, $r('sys.color.font_secondary'), FontWeight.Regular, 3);

        this.BuildSpan(this.privacyText[4].text, $r('sys.color.font_primary'), FontWeight.Medium, 4);
      }
      .layoutWeight(1)
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height(40)
    .margin({ bottom: 16 })
  }

  @Builder
  BuildSpan(content: ResourceStr, fontColor: ResourceStr, fontWight: number, textIndex: number) {
    Span(content)
      .fontSize($r('sys.float.ohos_id_text_size_body3'))
      .fontColor(fontColor)
      .fontWeight(fontWight)
      .onClick(() => {
        switch (textIndex) {
          case 1:
            this.userService();
            break;
          case 2:
            this.privacyPolicy();
            break;
          case 4:
            this.onAuthentication();
            break;
          default:
            break;
        }
      });
  }

  // 处理点击一键登录后的方法
  handleLoginWithHuaweiIDButton(error: BusinessError | undefined,
    response: loginComponentManager.HuaweiIDCredential) {
    console.info('login', JSON.stringify(response))
    if (error) {
      this.error = error;
      if (error.code === LoginErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
        // 未同意协议，弹出协议弹框，推荐使用该回调方式
        this.customerDiaLogOpen = true;
        this.agreementDialog.open();
      } else {
        // 模拟登录成功后回调
        this.loginFinished(false)
      }
      return;
    }
    if (this.isSelected) {
      // 配置好可用的调试证书和client_id后需要处理response
      if (response.idToken && response.idToken.length > 0) {
        // 登录成功后回调
        this.loginFinished(true, this.unionID)
        return
      }
      // 模拟登录成功后回调
      this.loginFinished(false)
    } else {
      this.agreementDialog.open();
      this.customerDiaLogOpen = true;
    }
  }

  getQuickLoginAnonymousPhone() {
    // 创建授权请求，并设置参数
    const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    // 获取匿名手机号需传quickLoginAnonymousPhone这个scope，传参之前需要先申请“华为账号一键登录”权限
    authRequest.scopes = ['quickLoginAnonymousPhone'];
    // 用于防跨站点请求伪造
    authRequest.state = util.generateRandomUUID();
    // 一键登录场景该参数必须设置为false
    authRequest.forceAuthorization = false;
    const controller = new authentication.AuthenticationController();
    try {
      controller.executeRequest(authRequest).then((response: authentication.AuthorizationWithHuaweiIDResponse) => {
        // 获取到UnionID、OpenID、匿名手机号
        this.unionID = response.data?.unionID ?? '';
        this.openID = response.data?.openID ?? '';
        const anonymousPhone = response.data?.extraInfo?.quickLoginAnonymousPhone as string;
        if (anonymousPhone) {
          this.phoneNum = anonymousPhone;
          return;
        }
      }).catch((error: BusinessError) => {
        // 以下内容配置好可用的调试证书和client_id后删除，当前为模拟数据
        this.unionID = util.generateRandomUUID();
        this.openID = util.generateRandomUUID();
        this.phoneNum = '177******96';
      });
    } catch (error) {
    }
  }

  showToast(message: string) {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: message,
        duration: 2000,
      });
    } catch (error) {
      let message = (error as BusinessError).message;
      let code = (error as BusinessError).code;
    }
  }

  aboutToAppear(): void {
    this.getQuickLoginAnonymousPhone()
    window.getLastWindow(getContext(), (_err, data: window.Window) => {
      data.setWindowPrivacyMode(true);
      // 获取窗口属性
      let properties = data.getWindowProperties();
      let rect = properties.windowRect;
      if (this.uiContext.px2vp(rect.height) <= 680) {
        this.windowStatusType = 5
      }
      let topHeight = data.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height;
      this.contentHeight = this.uiContext.px2vp(display.getDefaultDisplaySync().height - topHeight -
        0);
      data.on('windowStatusChange', (windowStatusType) => {
        this.windowStatusType = windowStatusType
      });
    })
  }

  aboutToDisappear(): void {
    window.getLastWindow(getContext(this)).then((windowStage: window.Window) => {
      windowStage.setWindowPrivacyMode(false);
    });
  }

  build() {
    Column() {
      if (this.isBindContentCover) {
        Text()
          .bindContentCover(true, this.CoverLogin(), {
            backgroundColor: $r('sys.color.background_secondary'),
            onWillDisappear: () => {
              this.shouldDismiss();
            }
          })
      } else {
        Text()
          .bindSheet(true, this.DefaultLogin(), {
            // Text绑定半模态转场
            height: SheetSize.FIT_CONTENT, // 半模态高度
            dragBar: true, // 是否显示控制条
            backgroundColor: $r('sys.color.background_secondary'),
            showClose: true, // 是否显示关闭图标
            preferType:SheetType.CENTER,
            shouldDismiss: ((sheetDismiss: SheetDismiss) => { // 半模态页面交互式关闭回调函数
              this.shouldDismiss();
              sheetDismiss.dismiss();
            })
          })
      }
    }
  }
}

export enum LoginType {
  HUAWEI = 0,
  WECHAT = 1,
  PHONE = 2
}

export enum LoginErrorCode {
  ERROR_CODE_NETWORK_ERROR = 1001502005,
  ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED = 1005300001,
  ERROR_CODE_LOGIN_OUT = 1001502001,
  ERROR_CODE_NOT_SUPPORTED = 1001500003,
  ERROR_CODE_NOT_REQUIRED_SCOPE_OR_PERMISSION = 1001502014
}
