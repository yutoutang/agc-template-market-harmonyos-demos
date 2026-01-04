import { promptAction } from '@kit.ArkUI';
import { CommonConstants } from 'lib_common';
import { AgreePrivacyBox } from '../components/AgreePrivacyBox';
import { IColor } from '../constants/CommonConst';
import { Constants } from '../constants/Constants';
import { LoginVM } from '../viewmodels/LoginVM';
import { SimpleDialog } from '../viewmodels/SimpleDialog';

@Builder
export function OtherLoginPageBuilder() {
  OtherLoginPage()
}

@ComponentV2
struct OtherLoginPage {
  @Local vm: LoginVM = LoginVM.getInstance(false);
  @Local
  private verifyCodeTime: number = 0;

  aboutToAppear(): void {
    this.vm.resetInput();
    this.vm.registerOnWXRespCallback();
  }

  aboutToDisappear(): void {
    this.vm.unregisterOnWXRespCallback();
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            Image($r('app.media.startIcon'))
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
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_primary'))
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .borderRadius($r('app.float.radius_20'))
              .placeholderFont({ size: $r('sys.float.Body_L') })
              .placeholderColor($r('sys.color.font_secondary'))
              .padding({
                top: CommonConstants.PADDING_S,
                bottom: CommonConstants.PADDING_S,
                left: CommonConstants.PADDING_L,
                right: CommonConstants.PADDING_L,
              })
            Stack({ alignContent: Alignment.End }) {
              TextInput({ text: this.vm.smsCodeInput, placeholder: '请输入验证码' })
                .width('100%')
                .height(Constants.INPUT_HEIGHT)
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_primary'))
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .borderRadius($r('app.float.radius_20'))
                .maxLength(6)
                .maxLines(1)
                .placeholderFont({ size: $r('sys.float.Body_L') })
                .placeholderColor($r('sys.color.font_secondary'))
                .onChange((value: string) => this.vm.smsCodeInput = value)
              if (this.verifyCodeTime === 0) {
                Button('获取验证码')
                  .fontSize($r('sys.float.Body_L'))
                  .fontColor($r('sys.color.font_on_primary'))
                  .backgroundColor($r('app.color.app_yellow'))
                  .onClick(() => this.getVerifyCode())
                  .padding({ right: CommonConstants.PADDING_L, left: CommonConstants.PADDING_L })
                  .margin({ right: CommonConstants.PADDING_S })
              } else {
                Text(this.verifyCodeTime + '秒后重新获取')
                  .fontSize(16)
                  .fontColor(IColor.BLACK_TRANSPARENT_40)
                  .padding({ right: CommonConstants.PADDING_L, left: CommonConstants.PADDING_L })
              }
            }
            .width('100%')
            .borderRadius($r('app.float.radius_20'))
            .margin({
              top: CommonConstants.PADDING_L,
            })

            Button('登录')
              .width(CommonConstants.FULL_PERCENT)
              .backgroundColor($r('app.color.app_theme'))
              .margin({
                top: Constants.PADDING_40 + CommonConstants.PADDING_S,
                bottom: CommonConstants.PADDING_S,
              })
              .onClick(() => {
                this.vm.phoneLogin();
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
                  if (this.vm.isAgreePrivacy) {
                    this.vm.jumpHuaweiLogin();
                  } else {
                    promptAction.showToast({ message: '请先勾选同意协议' });
                  }
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
                  if (this.vm.isAgreePrivacy) {
                    this.vm.jumpWX();
                  } else {
                    promptAction.showToast({ message: '请先勾选同意协议' });
                  }
                })

                Column({ space: CommonConstants.SPACE_S }) {
                  Image($r('app.media.ic_af'))
                    .width(Constants.WAY_ICON_WIDTH)
                    .draggable(false)
                  Text('支付宝登录')
                    .fontSize($r('sys.float.Caption_L'))
                    .fontColor($r('sys.color.font_tertiary'))
                }
                .width(Constants.WAY_WIDTH)
                .onClick(() => {
                  if (this.vm.isAgreePrivacy) {
                    this.vm.jumpAF();
                  } else {
                    promptAction.showToast({ message: '请先勾选同意协议' });
                  }
                })
              }
              .justifyContent(FlexAlign.SpaceAround)
            }
            .margin({
              top: this.vm.otherWayMarginTop(),
            })
          }
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)

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
}