import { Constants } from 'lib_account';
import { CommonConstants, WindowModel } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingViewModel } from '../viewmodels/SettingVM';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function ConfirmCancellationBuilder() {
  ConfirmCancellation()
}

@ComponentV2
struct ConfirmCancellation {
  @Local vm: SettingViewModel = new SettingViewModel();
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;

  aboutToAppear(): void {
    this.vm.getLoginPhoneNumber();
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '注销账号',
      })
      Column({ space: 16 }) {

        // 旧手机号输入
        Row() {
          Text('+86')
            .fontSize(16)
            .margin({ right: 12 })
          TextInput({
            text: this.vm.oldPhone,
            placeholder: '请输入手机号'
          })
            .layoutWeight(1)
            .backgroundColor('#ffffff')
            .selectedBackgroundColor('#ffffff') // 设置白色背景（可根据需要修改颜色值）
            .borderRadius(16)
            .placeholderColor($r('sys.color.font_secondary'))
            .maxLength(11)
            .onChange((value) => {
              this.vm.oldPhone = value;
            })
        }
        .backgroundColor('#ffffff')
        .width('100%')
        .borderRadius(8)
        .padding({
          left: 12,
          right: 12,
          bottom: 6,
          top: 6
        })

        // 验证码输入 + 获取验证码按钮
        Row() {
          TextInput({
            text: this.vm.verifyCode,
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
              this.vm.verifyCode = value;
            })
          Button(this.vm.codeBtnText)
            .width('30%')
            .height(Constants.INPUT_HEIGHT)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_emphasize'))
            .backgroundColor('#ffffff')
            .enabled(!this.vm.codeBtnDisabled)
            .onClick(() => {
              // 模拟获取验证码逻辑
              this.vm.codeBtnDisabled = true;
              this.vm.startCountdown('cancelUser', false, true)
            })
        }
        .width('100%')
        .backgroundColor('#ffffff')
        .borderRadius(8)

      }
      .width(CommonConstants.FULL_PERCENT)
      .flexGrow(1) // 【关键】让内容区域填充剩余空间
      .backgroundColor('#f2f4f5')
      .padding({ left: 16, right: 16, bottom: 16 })

      Row() {
        Button('确定')
          .width('100%')
          .height(40)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor($r('sys.color.warning'))
          .opacity(this.vm.isConfirmComplete() ? 1 : 0.4)
          .margin({ top: CommonConstants.PADDING_S, bottom: CommonConstants.PADDING_S })
          .onClick(() => {
            this.vm.confirmPhone(this.vm.oldPhone, this.vm.verifyCode);
          })
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({ left: 16, right: 16, bottom: this.windowModel.windowBottomPadding })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
