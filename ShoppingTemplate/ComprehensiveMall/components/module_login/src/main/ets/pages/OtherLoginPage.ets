import { loginComponentManager } from '@kit.AccountKit';
import { promptAction } from '@kit.ArkUI';
import { iData, RouterMap, routerStack, SimpleDialog } from 'lib_foundation';
import { IPrivacyText } from '../models/IPrivacyText';
import { IColor } from '../commons/CommonConst';

@ComponentV2
export struct OtherLoginPage {
  @Event
  public onFinish: () => void = () => {
  };
  @Local
  private isAccepted: boolean = false;
  @Local
  private isFinish: boolean = false;
  @Local
  private verifyCodeTime: number = 0;
  @Local
  private phone: string = '';
  @Local
  private smsCode: string = '';
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
      text: '和',
      type: loginComponentManager.TextType.PLAIN_TEXT,
    },
    {
      text: '《隐私政策》',
      type: loginComponentManager.TextType.RICH_TEXT,
      extraParams: {
        'label': '隐私政策',
        'url': 'resource://rawfile/static/html/privacy-policy.html',
      },
    },
  ];

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
            Column() {
              Image($r('app.media.login_logo'))
                .width(72)
                .height(72)
                .draggable(false)
                .objectFit(ImageFit.Cover)
                .margin({ top: 62 })
              TextInput({ text: this.phone, placeholder: '请输入手机号' })
                .height(40)
                .width('100%')
                .type(InputType.Number)
                .placeholderColor(IColor.BLACK_TRANSPARENT_40)
                .caretColor(IColor.THEME_PRIMARY)
                .maxLength(11)
                .fontColor(IColor.BLACK_TRANSPARENT_90)
                .borderRadius($r('sys.float.corner_radius_level10'))
                .borderWidth(1)
                .borderColor(IColor.BLACK_TRANSPARENT_20)
                .padding({
                  top: 0,
                  bottom: 0,
                  left: 20,
                  right: 20,
                })
                .maxLines(1)
                .backgroundColor(IColor.WHITE)
                .onChange((value: string) => this.phone = value)
                .margin({ top: 62 })
              Row() {
                TextInput({ text: this.smsCode, placeholder: '请输入验证码' })
                  .layoutWeight(1)
                  .type(InputType.Number)
                  .placeholderColor(IColor.BLACK_TRANSPARENT_40)
                  .caretColor(IColor.THEME_PRIMARY)
                  .maxLength(6)
                  .borderRadius(0)
                  .fontColor(IColor.BLACK_TRANSPARENT_90)
                  .fontSize(16)
                  .placeholderFont({ size: 16 })
                  .padding(0)
                  .maxLines(1)
                  .backgroundColor(IColor.WHITE)
                  .onChange((value: string) => this.smsCode = value)
                if (this.verifyCodeTime === 0) {
                  Text('获取验证码')
                    .fontSize(16)
                    .fontColor(IColor.THEME_PRIMARY)
                    .onClick(() => this.getVerifyCode())
                } else {
                  Text(this.verifyCodeTime + '秒后重新获取')
                    .fontSize(16)
                    .fontColor(IColor.BLACK_TRANSPARENT_40)
                }
              }
              .width('100%')
              .height(40)
              .alignItems(VerticalAlign.Center)
              .borderRadius(20)
              .borderWidth(1)
              .borderColor(IColor.BLACK_TRANSPARENT_20)
              .padding({ left: 20, right: 20 })
              .margin({ top: 12 })

              Button('点击登录')
              .width('100%')
              .height(40)
              .backgroundColor(IColor.THEME_PRIMARY)
              .margin({ top: 36 })
              .onClick(() => this.onMockLogin())

              Text('其他方式登录')
                .fontSize(14)
                .fontColor(IColor.BLACK_TRANSPARENT_40)
                .margin({ top: 36 })
              Image($r('app.media.huawei_logo'))
                .width(40)
                .height(40)
                .draggable(false)
                .borderRadius(40)
                .objectFit(ImageFit.Cover)
                .margin({ top: 24 })
                .onClick(() => {
                  this.isFinish = true;
                  routerStack.replacePathByName(RouterMap.USER_LOGIN, this.onFinish);
                })
              Text('华为账号一键登录')
                .fontSize(14)
                .fontColor(IColor.BLACK_TRANSPARENT_40)
                .margin({ top: 12 })
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
                .onChange((value: boolean) => this.isAccepted = value)
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
                          routerStack.pushPathByName(RouterMap.AGREEMENT, text.extraParams);
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
          .width('100%')
          .constraintSize({ minHeight: '100%' })
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 16, right: 16 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .backgroundColor(Color.White)
    }
    .onReady((ctx: NavDestinationContext) => {
      if (ctx.pathInfo.param) {
        this.onFinish = ctx.pathInfo.param as () => void;
      }
    })
  }

  private getVerifyCode(): void {
    if (this.verifyCodeTime > 0) {
      return;
    }
    const dialog: SimpleDialog = new SimpleDialog(this.getUIContext())
      .setMessage('获取验证码为模拟场景，真实获取验证码以业务实现为准')
      .onConfirm(() => {
        this.verifyCodeTime = 60;
        const timerId: number = setInterval(() => {
          this.verifyCodeTime--;
          if (this.verifyCodeTime <= 0) {
            clearInterval(timerId);
          }
        }, 1000);
      });
    dialog.open();
  }

  private onMockLogin(): void {
    if (!this.verify()) {
      return;
    }
    iData.local.userToken = 'mock_token';
    iData.global.isLogin = true;
    iData.global.userInfo.reset();
    iData.global.userInfo.nickname = '华为用户';
    iData.global.userInfo.anonymousPhone = '123******00';
    iData.global.userInfo.phone = '12345678900';
    iData.global.userInfo.avatar = '';
    promptAction.showToast({ message: 'Mock登录成功' });
    this.onFinish();
    this.isFinish = true;
    routerStack.pop();
  }

  private verify(): boolean {
    if (!this.isAccepted) {
      promptAction.showToast({ message: '请先阅读并同意相关协议' });
      return false;
    }
    if (!this.phone || !this.smsCode) {
      promptAction.showToast({ message: '手机号或验证码不能为空' });
      return false;
    }
    if (!/^\d{6}$/.test(this.smsCode)) {
      promptAction.showToast({ message: '验证码不正确' });
      return false;
    }
    if (!/^1[3-9]\d{9}$/.test(this.phone)) {
      promptAction.showToast({ message: '手机号码不正确' });
      return false;
    }
    return true;
  }
}

@Builder
export function buildOtherLoginPage() {
  OtherLoginPage()
}
