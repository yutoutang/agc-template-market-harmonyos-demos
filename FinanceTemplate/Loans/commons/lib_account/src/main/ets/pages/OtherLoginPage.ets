import { CommonConstants } from 'lib_common';
import { AgreePrivacyBox } from '../components/AgreePrivacyBox';
import { Constants } from '../constants/Constants';
import { LoginVM } from '../viewmodels/LoginVM'
import { promptAction } from '@kit.ArkUI';

@Builder
export function OtherLoginPageBuilder() {
  OtherLoginPage()
}

@ComponentV2
struct OtherLoginPage {
  @Local vm: LoginVM = LoginVM.getInstance(false);
  @Local isButtonEnabled: boolean = true;
  @Local countdownSeconds: number = 60;
  private timerId: number = -1;

  aboutToAppear(): void {
    this.vm.resetInput();
    this.vm.registerOnWXRespCallback();
  }

  aboutToDisappear(): void {
    this.vm.unregisterOnWXRespCallback();
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }
  }

  // 点击“获取验证码”的逻辑
  getVerificationCode() {
    if (this.vm.accountInput) {
      if (this.isButtonEnabled) {
        // 模拟请求验证码（实际开发中替换为接口请求）
        this.getUIContext().getPromptAction().showToast({ message: '验证码已发送' })
        // 开始倒计时
        this.isButtonEnabled = false;
        this.startCountdown();
      }
    } else {
      this.getUIContext().getPromptAction().showToast({ message: '请输入手机号' })
    }

  }

  // 启动倒计时
  startCountdown() {
    // 每次启动前先清除旧定时器（防止重复启动）
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }

    this.countdownSeconds = 60; // 重置为60秒
    this.timerId = setInterval(() => {
      this.countdownSeconds--;
      if (this.countdownSeconds <= 0) {
        clearInterval(this.timerId);
        this.isButtonEnabled = true;
        this.timerId = -1; // 重置定时器ID
      }
    }, 1000);
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            Image($r('app.media.start_icon'))
              .width(Constants.START_ICON_WIDTH)
              .aspectRatio(1)
              .draggable(false)
              .borderRadius($r('app.float.large_radius'))
              .margin({
                top: this.vm.iconMarginTop(),
                bottom: Constants.PADDING_40,
              })
            TextInput({ text: $$this.vm.accountInput, placeholder: '请输入手机号' })
              .width(CommonConstants.FULL_PERCENT)
              .height(Constants.INPUT_HEIGHT)
              .type(InputType.PhoneNumber)
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_primary'))
              .backgroundColor('#FFFFFF')
              .borderRadius($r('app.float.large_radius'))
              .placeholderFont({ size: $r('sys.float.Body_L') })
              .placeholderColor($r('sys.color.font_secondary'))
              .padding({
                top: CommonConstants.PADDING_S,
                bottom: CommonConstants.PADDING_S,
                left: CommonConstants.PADDING_L,
                right: CommonConstants.PADDING_L
              })
            // 验证码输入 + 获取验证码按钮
            Row() {
              TextInput({
                text: $$this.vm.passwordInput,
                placeholder: '请输入验证码'
              })
                .backgroundColor('#ffffff')
                .width('70%')
                .height(Constants.INPUT_HEIGHT)
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_primary'))
                .placeholderFont({ size: $r('sys.float.Body_L') })
                .placeholderColor($r('sys.color.font_secondary'))
                .onChange((value) => {
                  this.vm.passwordInput = value;
                })
              Text(this.isButtonEnabled ? '获取验证码' : `重新获取(${this.countdownSeconds}s)`)
                .height(Constants.INPUT_HEIGHT)
                .fontSize(14)
                .fontColor('#FF317AF7')
                .backgroundColor('#ffffff')
                .onClick(() => {
                  // 模拟获取验证码逻辑
                  this.getVerificationCode();
                })

            }
            .width('100%')
            .backgroundColor('#ffffff')
            .justifyContent(FlexAlign.SpaceBetween)
            .borderRadius($r('app.float.large_radius'))
            .margin({
              top: CommonConstants.PADDING_L,
            })
            .padding({
              right: CommonConstants.PADDING_L,
            })

            Button('登录')
              .width(CommonConstants.FULL_PERCENT)
              .backgroundColor($r('app.color.app_theme'))
              .margin({
                top: Constants.PADDING_40 + CommonConstants.PADDING_S,
                bottom: CommonConstants.PADDING_S,
              })
              .onClick(() => {
                this.vm.accountPasswordLogin();
              })

            Column({ space: CommonConstants.SPACE_M }) {
              Text('其他方式登录')
                .fontSize($r('sys.float.Caption_L'))
                .fontColor($r('sys.color.font_tertiary'))

              Row({ space: 48 }) {
                Column({ space: CommonConstants.SPACE_S }) {
                  Image($r('app.media.ic_huawei'))
                    .width(Constants.WAY_ICON_WIDTH)
                    .draggable(false)
                  Text('华为账号一键登录')
                    .fontSize($r('sys.float.Caption_L'))
                    .fontColor($r('sys.color.font_tertiary'))
                }
                .width(Constants.WAY_WIDTH)
                .onClick(() => {
                  this.vm.jumpHuaweiLogin();
                })

                Column({ space: CommonConstants.SPACE_S }) {
                  Image($r('app.media.ic_wechat'))
                    .width(Constants.WAY_ICON_WIDTH)
                    .draggable(false)
                  Text('微信')
                    .fontSize($r('sys.float.Caption_L'))
                    .fontColor($r('sys.color.font_tertiary'))
                }
                .width(Constants.WAY_WIDTH)
                .onClick(() => {
                  this.vm.jumpWX();
                })
              }
            }
            .margin({
              top: this.vm.otherWayMarginTop(),
            })
          }
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring,{alwaysEnabled:true})
        AgreePrivacyBox()
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .padding({
        left: CommonConstants.PADDING_PAGE,
        right: CommonConstants.PADDING_PAGE,
        bottom: this.vm.windowModel.windowBottomPadding,
      })
    }
    .hideTitleBar(true)
    .backgroundColor(this.vm.pageBgColor())
    .onBackPressed(() => {
      this.vm.handleClose();
      return true;
    })
  }
}