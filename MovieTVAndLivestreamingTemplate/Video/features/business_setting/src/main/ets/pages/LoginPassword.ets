import { CommonConstants, RouterMap, RouterUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingViewModel } from '../viewmodels/SettingVM';
import { promptAction } from '@kit.ArkUI';

@Builder
export function LoginPasswordBuilder() {
  LoginPassword()
}

@ComponentV2
struct LoginPassword {
  @Local vm: SettingViewModel = new SettingViewModel();

  aboutToAppear(): void {
    this.vm.getCache();
    this.vm.newPassword = '';
    this.vm.surePassword = '';
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '修改密码',
        })
        Column() {
          // 新密码输入框
          Column() {
            Row() {
              Text('新密码')
                .fontSize(16)
                .fontColor('#FF000000')
                .lineHeight(19)
            }
            .width('100%')

            TextInput({
              text: this.vm.newPassword,
              placeholder: '请输入新密码',
            })
              .padding(17)
              .width('100%')
              .margin(20)
              .backgroundColor($r('sys.color.comp_background_primary'))
              .selectedBackgroundColor($r('sys.color.comp_background_primary'))// 设置白色背景（可根据需要修改颜色值）
              .type(InputType.Password)
              .maxLength(9)
              .borderRadius(16)
              .showPasswordIcon(false)
              .onChange((value) => {
                this.vm.newPassword = value;
              })
          }

          // 确认密码输入框
          Column() {
            Row() {
              Text('确认密码')
                .fontSize(16)
                .fontColor('#FF000000')
                .lineHeight(19)
            }
            .width('100%')

            TextInput({ placeholder: '请再次输入密码', text: this.vm.surePassword })
              .width('100%')
              .padding(17)
              .margin(20)
              .backgroundColor($r('sys.color.comp_background_primary'))
              .selectedBackgroundColor($r('sys.color.comp_background_primary'))
              .type(InputType.Password)
              .maxLength(9)
              .borderRadius(16)
              .showPasswordIcon(false)
              .onChange((value) => {
                this.vm.surePassword = value;
              })

          }
        }
        .padding(20)
        .width(CommonConstants.FULL_PERCENT)
        .flexGrow(1) // 关键：让内容区域填充剩余空间

        // 确认按钮 - 固定在底部
        Row() {
          Button('确定')
            .width(CommonConstants.FULL_PERCENT)
            .height(40)
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              if (!this.vm.newPassword.trim() || !this.vm.surePassword.trim()) {
                promptAction.showToast({ message: '请输入完整的密码' });
                return
              }
              if (this.vm.newPassword === this.vm.surePassword) {
                promptAction.showToast({ message: '修改密码成功' });
                RouterUtils.popToName(RouterMap.SETTING_PAGE);
              } else {
                promptAction.showToast({ message: '密码不一致，请重新输入' });
                this.vm.newPassword = '';
                this.vm.surePassword = '';
              }
            })
        }
        .width(CommonConstants.FULL_PERCENT)
        .padding(24)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor('#f2f4f5')
    }
    .hideTitleBar(true)
  }
}
