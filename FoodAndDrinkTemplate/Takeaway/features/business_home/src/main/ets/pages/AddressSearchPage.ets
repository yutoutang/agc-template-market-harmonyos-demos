import { RouterUtils } from 'lib_common'
import { NavHeaderBar } from 'lib_widget'
import { AddressSearch } from 'module_address_search'
import { HomeViewModel } from '../viewmodels/HomeViewModel'

@Builder
export function AddressSearchPageBuilder() {
  AddressSearchPage()
}

@ComponentV2
export struct AddressSearchPage {
  @Local vm: HomeViewModel = new HomeViewModel();
  @Local addressText: string = '';

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '收货地址',
        bgColor: $r('app.color.background_color_white')
      })

      Column() {
        AddressSearch({
          textInit: this.addressText,
          click: (address) => {
            this.vm.settingInfo.address = address.name
            RouterUtils.pop()
          },
        })
      }
      .layoutWeight(1)
      .padding({
        top: 16,
        left: 16,
        right: 16,
      })
      .backgroundColor($r('sys.color.icon_on_primary'))
      .width('100%')
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background_color_grey'))
    .padding({ bottom: this.vm.windowModel.windowBottomPadding })
    .onReady((context) => {
      this.addressText = context.pathInfo.param as string ?? '';
    })
  }
}