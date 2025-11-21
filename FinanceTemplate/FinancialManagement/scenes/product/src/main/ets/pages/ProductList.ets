import { FormatUtil, RouterMap } from 'module_base'
import { ModuleProductList } from 'module_product_list'
import { ProductListVM } from '../viewModels/ProductListVM'

@Builder
export function ProductListBuilder() {
  ProductList()
}

@ComponentV2
struct ProductList {
  vm: ProductListVM = ProductListVM.instance
  private searchController: SearchController = new SearchController()

  build() {
    NavDestination() {
      Column() {
        Search({ value: this.vm.searchText, placeholder: '请输入产品名称/代码', controller: this.searchController })
          .width('100%')
          .placeholderColor($r('sys.color.font_secondary'))
          .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
          .textFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
          .focusable(false)
          .onClick(() => {
            FormatUtil.jumpToNext(RouterMap.PRODUCT_SEARCH)
          })

        ModuleProductList({
          productType: this.vm.productType, selectedIndex: this.vm.currentIndex
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title('理财产品选择')
    .onShown(() => {
      this.vm.init()
    })
  }
}