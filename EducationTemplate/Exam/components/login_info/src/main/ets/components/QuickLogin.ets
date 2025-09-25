/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { util } from '@kit.ArkTS';
import { authentication, loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ErrorCode } from '../model/ErrorCode';
import { AgreementDialog } from './AgreementDialog';

@ComponentV2
export struct QuickLogin {
  logTag: string = 'QuickLoginButtonComponent';
  domainId: number = 0x0000;
  // 是否显示半屏模态页面
  @Param isBindContentCover: boolean = false;
  // 是否勾选协议
  @Local isSelected: boolean = false;
  // 参考华为账号开发指南获取匿名手机号
  @Local quickLoginAnonymousPhone: string = '';
  //传入的图标按钮
  @Param @Require icon: ResourceStr
  //自定义登录颜色
  @Param @Require loginBtnBgColor: string | ResourceStr
  //app名字
  @Param @Require appName: string = ''
  // 展示用户服务协议、隐私协议和华为账号用户认证协议
  privacyText: loginComponentManager.PrivacyText[] = [{
    text: '已阅读并同意',
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: '《用户服务协议》',
    tag: '用户服务协议',
    type: loginComponentManager.TextType.RICH_TEXT
  }, {
    text: '《' + this.appName + '隐私协议》',
    tag: '隐私协议',
    type: loginComponentManager.TextType.RICH_TEXT
  }, {
    text: '和',
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: '《华为账号用户认证协议》',
    tag: '华为账号用户认证协议',
    type: loginComponentManager.TextType.RICH_TEXT
  }];
  /*
* 华为一键登录点击事件
* */
  @Event onLoginWithHuaweiID: (flag: boolean, phone?: string) => void = () => {
  }
  /*
   * 隐私协议点击事件
   * */
  @Event onPrivacyPolicy: () => void = () => {
  }
  /*
   * 服务协议点击事件
   * */
  @Event onServicePolicy: () => void = () => {
  }
  /*
   * 华为用户账号认证点击事件
   * */
  @Event onHYAccountRouter: () => void = () => {
  }
  /*
  * 模态弹窗消失事件
  * */
  @Event shouldDismiss: () => void = () => {
  }
  private static USER_AUTHENTICATION_TAG = '华为账号用户认证协议';
  private static USER_SERVICE_TAG = '用户服务协议';
  private static USER_PRIVACY_TAG = '隐私协议';
  // 构造LoginWithHuaweiIDButton组件的控制器
  controller: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
      /**
       * 当应用使用自定义的登录页时，如果用户未同意协议，需要设置协议状态为NOT_ACCEPTED，当用户同意协议后再设置
       * 协议状态为ACCEPTED，才可以使用华为账号一键登录功能
       */
      .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
      .onClickLoginWithHuaweiIDButton((error: BusinessError, response: loginComponentManager.HuaweiIDCredential) => {
        this.handleLoginWithHuaweiIDButton(error, response);
      })
      .onClickEvent((error: BusinessError) => {
        if (error) {
          this.dealAllError(error);
          return;
        }
      });
  agreementDialog: CustomDialogController = new CustomDialogController({
    builder: AgreementDialog({
      privacyText: this.privacyText,
      cancel: () => {
        this.agreementDialog.close();
        this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
      },
      confirm: () => {
        this.agreementDialog.close();
        this.isSelected = true;
        // 设置协议状态为ACCEPTED
        this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
        this.controller.continueLogin((error: BusinessError) => {
        })
      },
      clickHyperlinkText: (tag) => {
        this.agreementDialog.close();
        if (tag === QuickLogin.USER_AUTHENTICATION_TAG) {
          this.onHYAccountRouter();
        } else if (tag === QuickLogin.USER_SERVICE_TAG) {
          this.onServicePolicy()
        } else if (tag === QuickLogin.USER_PRIVACY_TAG) {
          this.onPrivacyPolicy()
        }
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
  });

  // 错误处理
  dealAllError(_error: BusinessError): void {
  }

  // Toast提示
  showToast(resource: string) {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: resource,
        duration: 2000
      });
    } catch (error) {
      //在此处进行异常处理
    }
  }

  handleLoginWithHuaweiIDButton(error: BusinessError | undefined,
    response: loginComponentManager.HuaweiIDCredential) {
    if (error) {
      if (error.code === ErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
        // 未同意协议，弹出协议弹框，推荐使用该回调方式
        this.agreementDialog.open();
      } else {
        // 模拟登录成功后回调
        this.onLoginWithHuaweiID(false)
      }
      return;
    }
    if (this.isSelected) {
      // 配置好可用的调试证书和client_id后需要处理response
      if (response.idToken && response.idToken.length > 0) {
        // 登录成功后回调
        this.onLoginWithHuaweiID(true, this.quickLoginAnonymousPhone)
        return
      }
      // 模拟登录成功后回调
      this.onLoginWithHuaweiID(false)
    } else {
      this.agreementDialog.open();
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
        const anonymousPhone = response.data?.extraInfo?.quickLoginAnonymousPhone as string;
        if (anonymousPhone) {
          this.quickLoginAnonymousPhone = anonymousPhone;
          return;
        }
      }).catch((error: BusinessError) => {
        // 以下内容配置好可用的调试证书和client_id后删除，当前为模拟数据
        this.quickLoginAnonymousPhone = '177******96';
      });
    } catch (error) {
    }
  }

  aboutToAppear(): void {
    this.getQuickLoginAnonymousPhone()
  }

  @Builder
  CoverLogin() {
    Column() {
      Column() {
        Column() {
          Image(this.icon)
            .width(48)
            .height(48)
            .draggable(false)
            .copyOption(CopyOptions.None)
            .onComplete(() => {
            })
            .onError(() => {
            })
          Column() {
            Text(this.quickLoginAnonymousPhone)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
              .fontSize(36)
              .lineHeight(48)
              .fontWeight(FontWeight.Bold)
              .maxLines(1)
              .constraintSize({ maxWidth: '100%', minHeight: 48 })
              .textAlign(TextAlign.Center)
            Text('华为账号绑定号码')
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
              .fontWeight(FontWeight.Regular)
              .lineHeight(19)
              .textAlign(TextAlign.Center)
              .maxLines(1)
              .constraintSize({ maxWidth: '100%' })
              .margin({
                top: 8
              })
          }.margin({
            top: 64
          })

          Column() {
            LoginWithHuaweiIDButton({
              params: {
                // LoginWithHuaweiIDButton支持的样式
                style: loginComponentManager.Style.BUTTON_CUSTOM,
                customButtonParams: {
                  backgroundColor: this.loginBtnBgColor
                },
                // 账号登录按钮在登录过程中展示加载态
                extraStyle: {
                  buttonStyle: new loginComponentManager.ButtonStyle().loadingStyle({
                    show: true
                  })
                },
                // LoginWithHuaweiIDButton的边框圆角半径
                borderRadius: 24,
                // LoginWithHuaweiIDButton支持的登录类型
                loginType: loginComponentManager.LoginType.QUICK_LOGIN,
                // LoginWithHuaweiIDButton支持按钮的样式跟随系统深浅色模式切换
                supportDarkMode: true,
                // verifyPhoneNumber：如果华为账号用户在过去90天内未进行短信验证，是否拉起Account Kit提供的短信验证码页面
                verifyPhoneNumber: true
              },
              controller: this.controller
            })
          }
          .height(40)
          .width('100%')
          .margin({
            top: 56
          })
        }.width('100%')

        Row() {
          Row() {
            Checkbox({ name: 'privacyCheckbox', group: 'privacyCheckboxGroup' })
              .width(24)
              .height(24)
              .focusable(true)
              .focusOnTouch(true)
              .margin({ top: 0 })
              .onChange((value: boolean) => {
                if (value) {
                  this.isSelected = true;
                  this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
                } else {
                  this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
                  this.isSelected = false;
                }
              })
          }

          Row() {
            Text() {
              ForEach(this.privacyText, (item: loginComponentManager.PrivacyText) => {
                if (item?.type === loginComponentManager.TextType.PLAIN_TEXT && item?.text) {
                  Span(item?.text)
                    .fontColor($r('sys.color.font_secondary'))
                    .fontWeight(FontWeight.Regular)
                    .fontSize($r('sys.float.Body_S'))
                } else if (item?.type === loginComponentManager.TextType.RICH_TEXT && item?.text) {
                  Span(item?.text)
                    .fontColor($r('sys.color.font_primary'))
                    .fontWeight(FontWeight.Medium)
                    .fontSize($r('sys.float.Body_S'))
                    .focusable(true)
                    .focusOnTouch(true)
                    .onClick(() => {
                      // 应用需要根据item.tag实现协议页面的跳转逻辑
                      if (item.tag === QuickLogin.USER_SERVICE_TAG) {
                        this.onServicePolicy()
                      }
                      if (item.tag === QuickLogin.USER_PRIVACY_TAG) {
                        this.onPrivacyPolicy()
                      }
                      if (item.tag === QuickLogin.USER_AUTHENTICATION_TAG) {
                        this.onHYAccountRouter()
                      }
                    })
                }
              }, (item: loginComponentManager.PrivacyText) => item.text.toString())
            }
            .width('100%')
          }
          .margin({ left: 12 })
          .layoutWeight(1)
          .constraintSize({ minHeight: 24 })
        }
        .alignItems(VerticalAlign.Top)
        .margin({
          top: 16,
          bottom: 16
        })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .constraintSize({ minHeight: '100%' })
      .margin({
        left: 16,
        right: 16
      })
    }
    .backgroundColor(Color.White)
    .width('100%')
    .height('100%')
    .padding({ top: '154vp' })
  }

  @Builder
  DefaultLogin() {
    Column() {
      Column() {
        Column() {
          Image(this.icon)
            .width(48)
            .height(48)
            .draggable(false)
            .copyOption(CopyOptions.None)
            .onComplete(() => {
            })
            .onError(() => {
            })
          Column() {
            Text(this.quickLoginAnonymousPhone)
              .fontSize(36)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
              .constraintSize({ maxWidth: '100%', minHeight: 48 })
              .lineHeight(48)
              .fontWeight(FontWeight.Bold)
              .maxLines(1)
              .textAlign(TextAlign.Center)
            Text('华为账号绑定号码')
              .fontWeight(FontWeight.Regular)
              .maxLines(1)
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
              .lineHeight(19)
              .constraintSize({ maxWidth: '100%' })
              .textAlign(TextAlign.Center)
              .margin({
                top: 8
              })
          }.margin({ top: 48 });
        }.width('100%')

        Column().layoutWeight(1)
        Column() {
          LoginWithHuaweiIDButton({
            params: {
              // LoginWithHuaweiIDButton支持的样式
              style: loginComponentManager.Style.BUTTON_CUSTOM,
              customButtonParams: {
                backgroundColor: this.loginBtnBgColor
              },
              // 账号登录按钮在登录过程中展示加载态
              extraStyle: {
                buttonStyle: new loginComponentManager.ButtonStyle().loadingStyle({
                  show: true
                })
              },
              // LoginWithHuaweiIDButton的边框圆角半径
              borderRadius: 24,
              // LoginWithHuaweiIDButton支持的登录类型
              loginType: loginComponentManager.LoginType.QUICK_LOGIN,
              // LoginWithHuaweiIDButton支持按钮的样式跟随系统深浅色模式切换
              supportDarkMode: true,
              // verifyPhoneNumber：如果华为账号用户在过去90天内未进行短信验证，是否拉起Account Kit提供的短信验证码页面
              verifyPhoneNumber: true
            },
            controller: this.controller
          })
            .height(40)
            .width('100%')
          Row() {
            Row() {
              Checkbox({ name: 'privacyCheckbox', group: 'privacyCheckboxGroup' })
                .width(24)
                .height(24)
                .focusable(true)
                .focusOnTouch(true)
                .margin({ top: 0 })
                .onChange((value: boolean) => {
                  if (value) {
                    this.isSelected = true;
                    this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
                  } else {
                    this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
                    this.isSelected = false;
                  }
                })
            }

            Row() {
              Text() {
                ForEach(this.privacyText, (item: loginComponentManager.PrivacyText) => {
                  if (item?.type === loginComponentManager.TextType.PLAIN_TEXT && item?.text) {
                    Span(item?.text)
                      .fontColor($r('sys.color.font_secondary'))
                      .fontWeight(FontWeight.Regular)
                      .fontSize($r('sys.float.Body_S'))
                  } else if (item?.type === loginComponentManager.TextType.RICH_TEXT && item?.text) {
                    Span(item?.text)
                      .fontColor($r('sys.color.font_primary'))
                      .fontWeight(FontWeight.Medium)
                      .fontSize($r('sys.float.Body_S'))
                      .focusable(true)
                      .focusOnTouch(true)
                      .onClick(() => {
                        // 应用需要根据item.tag实现协议页面的跳转逻辑
                        if (item.tag === QuickLogin.USER_SERVICE_TAG) {
                          this.onServicePolicy()
                        }
                        if (item.tag === QuickLogin.USER_PRIVACY_TAG) {
                          this.onPrivacyPolicy()
                        }
                        if (item.tag === QuickLogin.USER_AUTHENTICATION_TAG) {
                          this.onHYAccountRouter()
                        }
                      })
                  }
                }, (item: loginComponentManager.PrivacyText) => item.text.toString())
              }
              .width('100%')
            }
            .margin({ left: 12 })
            .layoutWeight(1)
            .constraintSize({ minHeight: 24 })
          }
          .alignItems(VerticalAlign.Top)
          .margin({ top: 20, bottom: 16 })
        }
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({
        top: 80,
        bottom: 20,
        left: 16,
        right: 16
      });
    }
    .width('100%')
    .height(500)
  }

  build() {
    Column() {
      if (this.isBindContentCover) {
        Text()
          .bindContentCover(true, this.CoverLogin(), {
            backgroundColor: Color.White,
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
            backgroundColor: Color.White,
            showClose: true, // 是否显示关闭图标
            shouldDismiss: ((sheetDismiss: SheetDismiss) => { // 半模态页面交互式关闭回调函数
              this.shouldDismiss();
              sheetDismiss.dismiss();
            })
          })
      }
    }
    .width('100%')
    .height('100%')
  }
}
