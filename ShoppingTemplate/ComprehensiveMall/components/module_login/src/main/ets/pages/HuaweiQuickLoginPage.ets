import { authentication, loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';
import { iData, RouterMap, routerStack } from 'lib_foundation';
import { LoginParams } from '../models/LoginParams';
import { IPrivacyText } from '../models/IPrivacyText';
import { IColor } from '../commons/CommonConst';
import { ErrorCode } from '../commons/ErrorCode';

const IS_DEV_MODE: boolean = true;

@ComponentV2
export struct HuaweiQuickLoginPage {
  @Event
  public onFinish: () => void = () => {
  };
  @Local
  private isAccepted: boolean = false;
  @Local
  private anonymousPhone: string = '';
  @Local
  private isFinish: boolean = false;
  private privacyTexts: IPrivacyText[] = [
    {
      text: '已阅读并同意',
      type: loginComponentManager.TextType.PLAIN_TEXT,
    },
    {
      text: '《用户协议》',
      type: loginComponentManager.TextType.RICH_TEXT,
      extraParams: {
        'label': '用户协议',
        'url': 'resource://rawfile/static/html/user-agreement.html',
      },
    },
    {
      text: '《隐私政策》',
      type: loginComponentManager.TextType.RICH_TEXT,
      extraParams: {
        'label': '隐私政策',
        'url': 'resource://rawfile/static/html/privacy-policy.html',
      },
    },
    {
      text: '和',
      type: loginComponentManager.TextType.PLAIN_TEXT,
    },
    {
      text: '《华为账号用户认证协议》',
      type: loginComponentManager.TextType.RICH_TEXT,
      extraParams: {
        'label': '华为账号用户认证协议',
        'url': 'resource://rawfile/static/html/authentication-terms.html',
      },
    },
  ];
  private handleHuaweiQuickLogin = (error: BusinessError<void> | undefined,
    credential: loginComponentManager.HuaweiIDCredential) => {
    if (error) {
      this.dealHuaweiQuickLoginError(error);
      return;
    }
    if (IS_DEV_MODE) {
      this.onMockLogin(false);
      return;
    }
    if (this.isAccepted && credential) {
      this.onLogin(credential);
    }
  };
  private loginButtonController: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
      .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
      .onClickLoginWithHuaweiIDButton(this.handleHuaweiQuickLogin);

  public aboutToAppear(): void {
    this.handleAuthenticationRequest();
  }

  public aboutToDisappear(): void {
    if (!this.isFinish) {
      this.onFinish();
    }
  }

  public build(): void {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            if (this.anonymousPhone) {
              Column() {
                Image($r('app.media.login_logo'))
                  .width(72)
                  .height(72)
                  .draggable(false)
                  .objectFit(ImageFit.Cover)
                  .margin({ top: 62 })
                Column() {
                  Text(this.anonymousPhone)
                    .height(40)
                    .fontSize(30)
                    .fontColor(IColor.BLACK_TRANSPARENT_90)
                    .fontWeight(FontWeight.Bold)
                  Text('华为账号绑定号码')
                    .fontSize(12)
                    .fontColor(IColor.BLACK_TRANSPARENT_60)
                    .fontWeight(FontWeight.Regular)
                    .lineHeight(16)
                    .margin({ top: 4 })
                }
                .margin({ top: 48 })
                .alignItems(HorizontalAlign.Center)

                Column() {
                  LoginWithHuaweiIDButton({
                    params: {
                      style: loginComponentManager.Style.BUTTON_CUSTOM,
                      borderRadius: 20,
                      supportDarkMode: false,
                      loginType: loginComponentManager.LoginType.QUICK_LOGIN,
                      customButtonParams: {
                        fontColor: loginComponentManager.FontColor.WHITE,
                        backgroundColor: IColor.THEME_PRIMARY,
                      },
                      verifyPhoneNumber: true,
                      extraStyle: {
                        buttonStyle: new loginComponentManager.ButtonStyle()
                          .buttonSize({ width: '100%', height: 40 })
                          .fontSize(16)
                          .fontWeight(600)
                          .fontColor(IColor.WHITE)
                          .backgroundColor(IColor.THEME_PRIMARY)
                          .border({ radius: 20 })
                          .loadingStyle({ show: true }),
                      },
                      loginButtonTextType: loginComponentManager.LoginButtonTextType.QUICK_LOGIN,
                    },
                    controller: this.loginButtonController,
                  })
                    .margin({ top: 48 })
                  Button('其他方式登录')
                    .fontColor($r('sys.color.font_primary'))
                    .width('100%')
                    .height(40)
                    .backgroundColor(IColor.BLACK_TRANSPARENT_5)
                    .margin({ top: 12 })
                    .onClick(() => {
                      this.isFinish = true;
                      routerStack.replacePathByName(RouterMap.USER_OTHER_LOGIN, this.onFinish);
                    })
                }
                .width('100%')
                .constraintSize({ maxWidth: 480 })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.Start)

              Row() {
                Checkbox()
                  .width(20)
                  .height(20)
                  .shape(CheckBoxShape.CIRCLE)
                  .select(this.isAccepted)
                  .selectedColor(IColor.THEME_PRIMARY)
                  .margin({
                    left: 0,
                    right: 14,
                    top: 0,
                    bottom: 0,
                  })
                  .onChange((value: boolean) => {
                    if (value) {
                      this.isAccepted = true;
                      this.loginButtonController.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
                    } else {
                      this.isAccepted = false;
                      this.loginButtonController.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
                    }
                  })
                Text() {
                  ForEach(this.privacyTexts, (text: IPrivacyText) => {
                    if (text.type === loginComponentManager.TextType.PLAIN_TEXT && text.text) {
                      Span(text.text)
                        .fontColor(IColor.BLACK_TRANSPARENT_60)
                    } else if (text?.type === loginComponentManager.TextType.RICH_TEXT && text.text) {
                      Span(text.text)
                        .fontColor(IColor.LINK)
                        .fontWeight(600)
                        .onClick(() => {
                          if (text.extraParams) {
                            routerStack.pushPathByName(RouterMap.SETTING_AGREEMENT, text.extraParams);
                          }
                        })
                    }
                  }, (item: IPrivacyText, index: number) => index + '__' + JSON.stringify(item))
                }
                .layoutWeight(1)
                .fontSize(12)
              }
              .alignItems(VerticalAlign.Center)
              .constraintSize({ minHeight: 56 })
            }
          }
          .width('100%')
          .constraintSize({ minHeight: '100%', maxWidth: 480 })
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 16, right: 16 })
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    }
    .onReady((ctx: NavDestinationContext) => {
      if (ctx.pathInfo.param) {
        this.onFinish = ctx.pathInfo.param as () => void;
      }
    })
  }

  private onLogin(credential: loginComponentManager.HuaweiIDCredential): void {
    const loginParams: LoginParams = {
      anonymousPhone: this.anonymousPhone,
      unionID: credential.unionID,
      openID: credential.openID,
      authorizationCode: credential.authorizationCode,
      idToken: credential.idToken,
    };
    if (loginParams) {
      // 根据 loginParams 实现自身业务逻辑登录
      this.onFinish();
      this.isFinish = true;
      routerStack.pop();
    }
  }

  private onMockLogin(isShowToast: boolean = true): void {
    iData.global.isLogin = true;
    iData.global.userInfo.reset();
    iData.global.userInfo.nickname = '华为用户';
    iData.global.userInfo.anonymousPhone = '123******00';
    iData.global.userInfo.phone = '12345678900';
    iData.global.userInfo.avatar = '';
    if (isShowToast) {
      promptAction.showToast({ message: 'Mock登录成功' });
    }
    this.onFinish();
    this.isFinish = true;
    routerStack.pop();
  }

  private handleAuthenticationRequest(): void {
    const req = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    req.scopes = ['quickLoginAnonymousPhone'];
    req.permissions = ['serviceauthcode'];
    req.forceAuthorization = false;
    req.state = util.generateRandomUUID(false);
    try {
      const controller = new authentication.AuthenticationController(this.getUIContext().getHostContext());
      controller.executeRequest(req)
        .then((res: authentication.AuthorizationWithHuaweiIDResponse) => {
          if (res.state !== req.state || !res.data) {
            return;
          }
          const credential: authentication.AuthorizationWithHuaweiIDCredential = res.data;
          this.anonymousPhone = credential.extraInfo?.quickLoginAnonymousPhone as string ?? '';
        })
        .catch((error: BusinessError<Object>) => {
          this.dealAuthenticationRequestError(error);
        });
    } catch (error) {
      this.dealAuthenticationRequestError(error);
    }
  }

  private dealAuthenticationRequestError(error: BusinessError<Object>): void {
    if (IS_DEV_MODE && error) {
      // 当前为开发模式，使用 Mock 匿名手机号
      this.anonymousPhone = '123******00';
    }
  }

  private dealHuaweiQuickLoginError(error: BusinessError<void>): void {
    if (error.code === ErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
      // 用户未同意协议
      promptAction.showToast({ message: '请先阅读并同意相关协议' });
    } else if (IS_DEV_MODE) {
      // 当前为开发模式，执行 Mock 登录
      this.onMockLogin();
    }
  }
}

@Builder
export function buildHuaweiQuickLoginPage() {
  HuaweiQuickLoginPage()
}
