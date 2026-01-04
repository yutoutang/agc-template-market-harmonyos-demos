import { CommonConstants, WindowModel } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingViewModel } from '../viewmodels/SettingVM';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function SettingPhoneBuilder() {
  SettingPhone()
}

@ComponentV2
struct SettingPhone {
  @Local vm: SettingViewModel = new SettingViewModel();
  @Local password: string = ''
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;

  build() {
    NavDestination() {
      // 根布局，使用 Column 并撑满整个屏幕
      Column({ space: 0 }) {
        // 1. 顶部导航栏
        NavHeaderBar({
          title: '更换登录手机号',
        })

        // 2. 中间内容区域 - 使用 flexGrow 填充空间，将底部按钮推下去
        Column({ space: 16 }) {
          // 页面说明
          Column({ space: 8 }) {
            Text('安全校验手机不用于登录，仅用于安全校验')
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          // 旧手机号输入
          Row() {
            Text('+86')
              .fontSize(16)
              .margin({ right: 12 })
            TextInput({
              text: `${this.vm.oldPhone.slice(0, 3)}****${this.vm.oldPhone.slice(-4)}`,
              placeholder: '请输入旧手机号',

            })
              .maxLength(11)
              .layoutWeight(1)
              .backgroundColor($r('sys.color.comp_background_primary'))
              .selectedBackgroundColor($r('sys.color.comp_background_primary'))
              .enabled(false)
              .borderRadius(16)
          }
          .backgroundColor('#ffffff')
          .width('100%')
          .borderRadius(8)
          .padding(16)

          // 新手机号输入
          Row() {
            Text('+86')
              .fontSize(16)
              .margin({ right: 12 })

            TextInput({
              text: this.vm.newPhone,
            })
              .maxLength(11)
              .type(InputType.Number)
              .backgroundColor($r('sys.color.comp_background_primary'))
              .selectedBackgroundColor($r('sys.color.comp_background_primary'))
              .layoutWeight(1)
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_primary'))
              .placeholderFont({ size: $r('sys.float.Body_L') })
              .placeholderColor($r('sys.color.font_secondary'))
              .onChange((value) => {
                this.vm.newPhone = value;
              })
          }
          .width('100%')
          .backgroundColor('#ffffff')
          .borderRadius(8)
          .padding(16)

          // 验证码输入 + 获取验证码按钮
          Row() {
            TextInput({
              text: this.vm.verifyCode,
              placeholder: '请输入验证码'
            })
              .backgroundColor($r('sys.color.comp_background_primary'))
              .width('60%')
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_primary'))
              .placeholderFont({ size: $r('sys.float.Body_L') })
              .placeholderColor($r('sys.color.font_secondary'))
              .onChange((value) => {
                this.vm.verifyCode = value;
              })
            Button(this.vm.codeBtnText)
              .width('40%')
              .fontColor($r('sys.color.font_emphasize'))
              .backgroundColor($r('sys.color.font_on_primary'))
              .enabled(!this.vm.codeBtnDisabled)
              .onClick(() => {
                // 模拟获取验证码逻辑
                this.vm.codeBtnDisabled = true;
                this.vm.codeBtnText = '60s后重新获取';
                setTimeout(() => {
                  this.vm.codeBtnDisabled = false;
                  this.vm.codeBtnText = '获取验证码';
                }, 60000);
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#ffffff')
          .borderRadius(8)

        }

        .width(CommonConstants.FULL_PERCENT)
        .flexGrow(1) // 【关键】让内容区域填充剩余空间
        .backgroundColor('#f2f4f5')
        .padding(16)

        Row() {
          Button('确定')
            .width('100%')
            .height(40)
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              this.vm.changeLoginPhone(this.vm.oldPhone, this.vm.newPhone, this.vm.verifyCode);
            })
        }
        .width(CommonConstants.FULL_PERCENT)
        .padding(16)
      }
      .backgroundColor('#f2f4f5')
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT) // 【关键】确保根布局占满屏幕

    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({
      bottom: this.windowModel.windowBottomPadding
    })
  }
}