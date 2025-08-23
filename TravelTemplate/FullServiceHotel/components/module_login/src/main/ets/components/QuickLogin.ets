import { loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from 'module_ui_base';
import { LoginUtil } from '../utils/AccountUtil';
import { LoginUserInfo } from '../model/UserInfo';
import { ErrorCode } from '../model/ErrorCode';

const TAG: string = '[QuickLogin]'

@ComponentV2
export struct QuickLogin {
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
  // 是否为mock数据
  @Local isMock: boolean = true;
  // 展示用户服务协议、隐私协议和华为账号用户认证协议
  privacyText: loginComponentManager.PrivacyText[] = [{
    text: '已阅读并同意',
    type: loginComponentManager.TextType.PLAIN_TEXT,
  }, {
    text: '《用户服务协议》',
    tag: '用户服务协议',
    type: loginComponentManager.TextType.RICH_TEXT,
  }, {
    text: '《' + this.appName + '隐私协议》',
    tag: '隐私协议',
    type: loginComponentManager.TextType.RICH_TEXT,
  }, {
    text: '和',
    type: loginComponentManager.TextType.PLAIN_TEXT,
  }, {
    text: '《华为账号用户认证协议》',
    tag: '华为账号用户认证协议',
    type: loginComponentManager.TextType.RICH_TEXT,
  }];
  /*
* 华为一键登录点击事件
* */
  @Event onLoginWithHuaweiID: () => void = () => {
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
      .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
      .onClickLoginWithHuaweiIDButton((error: BusinessError, response: loginComponentManager.HuaweiIDCredential) => {
        this.handleLoginWithHuaweiIDButton(error, response);
      })
      .onClickEvent((error: BusinessError) => {
        if (error) {
          Logger.error(TAG)
          return;
        }
      });

  // Toast提示
  showToast(resource: string) {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: resource,
        duration: 2000,
      });
    } catch (error) {
      Logger.error(TAG, 'open toast failed. error:' + JSON.stringify(error))
    }
  }

  handleLoginWithHuaweiIDButton(error: BusinessError | undefined,
    response: loginComponentManager.HuaweiIDCredential) {
    if (this.isMock) {
      if (this.isSelected) {
        let prop = AppStorageV2.connect(LoginUserInfo, () => new LoginUserInfo())!
        prop.isLogin = true
        prop.name = '华为用户'
        prop.id = new Date().getTime()
        prop.cellphone = this.quickLoginAnonymousPhone
        this.onLoginWithHuaweiID?.()
      } else {
        this.showToast('请阅读并同意相关协议~')
      }
      return
    }
    if (error) {
      if (error.code === ErrorCode.ERROR_CODE_NETWORK_ERROR) {
        this.showToast('网络异常，请检查网络设置。');
      } else if (error.code === ErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
        // 未同意协议，弹出协议弹框，推荐使用该回调方式
        this.showToast('请阅读并同意相关协议~')
      } else if (error.code === ErrorCode.ERROR_CODE_LOGIN_OUT) {
        // 华为账号未登录提示
        this.showToast('华为账号未登录，请重试');
      } else if (error.code === ErrorCode.ERROR_CODE_NOT_SUPPORTED) {
        // 不支持该scopes或permissions提示
        this.showToast('该scopes或permissions不支持');
      } else if (error.code === ErrorCode.ERROR_CODE_PARAMETER_ERROR) {
        // 参数错误提示
        this.showToast('参数错误');
      } else {
        // 其他提示系统或服务异常
        this.showToast('服务或网络异常，请稍后重试');
      }
      return;
    }
    try {
      if (response) {
        let prop = AppStorageV2.connect(LoginUserInfo, () => new LoginUserInfo())!
        prop.isLogin = true
        prop.name = '华为用户'
        prop.id = new Date().getTime()
        prop.cellphone = this.quickLoginAnonymousPhone;
        this.onLoginWithHuaweiID?.()
      }
    } catch (err) {
      this.showToast('服务或网络异常，请稍后重试')
    }
  }

  async aboutToAppear() {
    const phone = await LoginUtil.getQuickLoginAnonymousPhone()
    if (phone) {
      this.isMock = false
      this.quickLoginAnonymousPhone = phone;
    } else {
      this.quickLoginAnonymousPhone = '123******00'
      this.showToast('当前应用未获取指定scope或permission权限，将使用模拟登录方式')
      this.isMock = true
    }
  }

  build() {
    Scroll() {
      Column() {
        Image(this.icon)
          .width(48)
          .height(48)
          .borderRadius(16)
          .margin({ bottom: 48, top: 48 })

        Text(this.quickLoginAnonymousPhone)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
          .fontSize(28)
          .lineHeight(40)
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .constraintSize({ maxWidth: '100%', minHeight: 48 })
          .textAlign(TextAlign.Center)
        Text('华为账号绑定号码')
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
          .fontWeight(FontWeight.Regular)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .constraintSize({ maxWidth: '100%' })
          .margin({
            top: 8,
            bottom: 32,
          })
        LoginWithHuaweiIDButton({
          params: {
            // LoginWithHuaweiIDButton支持的样式
            style: loginComponentManager.Style.BUTTON_CUSTOM,
            customButtonParams: {
              backgroundColor: this.loginBtnBgColor,
            },
            // 账号登录按钮在登录过程中展示加载态
            extraStyle: {
              buttonStyle: new loginComponentManager.ButtonStyle().loadingStyle({
                show: true,
              }),
            },
            // LoginWithHuaweiIDButton的边框圆角半径
            borderRadius: 24,
            // LoginWithHuaweiIDButton支持的登录类型
            loginType: loginComponentManager.LoginType.QUICK_LOGIN,
            // LoginWithHuaweiIDButton支持按钮的样式跟随系统深浅色模式切换
            supportDarkMode: true,
            // verifyPhoneNumber：如果华为账号用户在过去90天内未进行短信验证，是否拉起Account Kit提供的短信验证码页面
            verifyPhoneNumber: true,
          },
          controller: this.controller,
        })
          .height(40)
          .margin({ bottom: 16 })

        Blank().layoutWeight(1)

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
        .margin({ bottom: $r('app.string.space_l') })
      }
      .constraintSize({ minHeight: '100%' })
    }
    .padding($r('app.string.space_l'))
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off)
    .backgroundColor(Color.White)
    .width('100%')
    .height('100%')
  }
}
