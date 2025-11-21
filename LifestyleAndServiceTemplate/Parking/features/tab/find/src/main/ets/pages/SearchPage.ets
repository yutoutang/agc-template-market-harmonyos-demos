import { CommonHeader, IAddressInfo, WindowUtil } from 'common';
import { SearchPageVM } from '../viewmodels/SearchPageVM';
import { AddressSearch } from 'module_address_search';

@ComponentV2
export struct SearchPage {
  vm: SearchPageVM = SearchPageVM.instance;

  aboutToAppear() {
    this.vm.init();
  }

  build() {
    NavDestination() {
      /** 标题栏 **/
      CommonHeader({ title: '搜索列表' })

      AddressSearch({
        textInit: this.vm.text,
        click: (address) => {
          this.vm.clickCardNextDo(address as IAddressInfo);
        },
      }).width('calc(100% - 32vp)').layoutWeight(1)
    }
    .backgroundColor($r('app.color.system_color_background_gray'))
    .padding({ bottom: WindowUtil.getAvoidArea().bottom })
    .hideTitleBar(true)
  }
}

@Builder
export function searchPageBuilder() {
  SearchPage()
}