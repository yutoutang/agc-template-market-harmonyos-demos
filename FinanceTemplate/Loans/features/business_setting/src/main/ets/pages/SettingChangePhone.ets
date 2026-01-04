import { AppStorageV2 } from '@kit.ArkUI';
import { Constants } from 'lib_account';
import { CommonConstants, WindowModel } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingViewModel } from '../viewmodels/SettingVM';

@Builder
export function SettingChangePhoneBuilder() {
  SettingChangePhone()
}

@ComponentV2
struct SettingChangePhone {
  @Local vm: SettingViewModel = new SettingViewModel();
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;

  aboutToAppear(): void {
    this.vm.getLoginPhoneNumber();
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '换绑手机号',
      })
      Column({ space: 16 }) {
        Text('请验证旧手机')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
          .padding({ top:16})
        // 旧手机号输入
        Row() {
          Text('+86')
            .fontSize(16)
            .margin({ right: 12 })
          TextInput({
            text: this.vm.oldPhone,
            placeholder: '请输入旧手机号'
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
              this.vm.startCountdown('changePhone')
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
      .alignItems(HorizontalAlign.Start)

      Row() {
        Button('下一步')
          .width('100%')
          .height(40)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.vm.isFormComplete() ? '#FF317AF7' : '#a5c3f6')
          .margin({ top: CommonConstants.PADDING_S, bottom: CommonConstants.PADDING_S })
          .onClick(() => {
            this.vm.changeLoginPhone(this.vm.oldPhone, this.vm.verifyCode);
          })
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({ left: 16, right: 16, bottom: this.windowModel.windowBottomPadding })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
