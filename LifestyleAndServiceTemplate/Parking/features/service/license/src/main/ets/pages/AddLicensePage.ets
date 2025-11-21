import { CommonButton, CommonConstants, CommonHeader, RouterMap, RouterModule, WindowUtil } from 'common';
import { CommonKeyboard } from 'module_license_keyboard';
import { LicensePageVM } from '../viewmodels/LicensePageVM';

@ComponentV2
export struct AddLicensePage {
  vm: LicensePageVM = LicensePageVM.instance;
  formMy: boolean = RouterModule.getPrePage() === RouterMap.MY_LICENSE;

  aboutToAppear() {
    this.vm.resetParams();
  }

  build() {
    NavDestination() {
      /** 标题栏 **/
      CommonHeader({ title: '添加车牌', backAnimation: !this.formMy })

      Column() {
        /** 车牌显示 **/
        CommonKeyboard({
          onChange: (numbers, full) => {
            this.vm.license = numbers.join('');
            this.vm.isFull = full;
          },
        })
          .margin({ top: $r('app.string.margin_12'), bottom: $r('app.string.margin_10') })
          .width('calc(100% - 24vp)')

        /** 设置默认 **/
        Row({ space: 10 }) {
          Toggle({ type: ToggleType.Checkbox, isOn: $$this.vm.isDefault })
          Text('设为默认').fontSize($r('sys.float.Subtitle_M')).fontColor($r('sys.color.font_primary'))
        }
        .justifyContent(FlexAlign.Start)
        .width('calc(100% - 32vp)')

      }.layoutWeight(1)

      /** 添加按钮 **/
      CommonButton({
        title: '确定添加',
        handleClick: async () => {
          await this.vm.addNewLicense(!this.formMy);
        },
      })
    }
    .onBackPressed(() => {
      RouterModule.pop(!this.formMy);
      return true;
    })
    .hideTitleBar(true)
    .height(CommonConstants.FULL_HEIGHT)
    .padding({ bottom: WindowUtil.getAvoidArea().bottom })
    .backgroundColor($r('app.color.system_color_background_gray'))
  }
}

@Builder
export function addLicensePageBuilder() {
  AddLicensePage()
}