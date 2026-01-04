import { RouterUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { HomeViewModel } from '../viewmodels/HomeViewModel';
import { MyAddressSearch } from '../viewmodels/MyAddressSearch';

@Builder
export function MyAddressSearchPageBuilder() {
  MyAddressSearchPage()
}

@ComponentV2
export struct MyAddressSearchPage {
  @Local vm: HomeViewModel = new HomeViewModel();

  build() {
    NavDestination() {

      NavHeaderBar({
        title: '收货地址',
        bgColor: $r('app.color.background_color_white'),
        onBack: () => {
          RouterUtils.pop(1)
        },
      })
      Column() {
        MyAddressSearch({
          textInit: this.vm.settingInfo.address,
          homeVm: this.vm,
          click: (address) => {
            this.vm.settingInfo.address = address.province + address.city + address.area + address.detailAddress
            RouterUtils.pop(1)
          },
        })
      }
      .padding(16)
      .backgroundColor($r('sys.color.icon_on_primary'))

    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background_color_grey'))
    .width('100%')
    .height('90%')
    .padding({ bottom: this.vm.windowModel.windowBottomPadding })
  }
}