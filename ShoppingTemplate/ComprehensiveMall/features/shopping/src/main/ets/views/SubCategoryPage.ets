import { RouterMap, routerStack, Style } from 'lib_foundation';
import { FilterSelectionItem, ProductSummaryItem } from 'lib_network';
import { ProductWaterFlow } from 'product';
import { SortTypeMap } from '../commons/Enums';
import { SortBar } from '../components/SortBar';

@Builder
export function buildSubCategoryPage() {
  SubCategoryPage()
}

@ComponentV2
export struct SubCategoryPage {
  @Local
  title: string = ''
  @Local
  curCategoryId: string = ''
  @Local
  vertical: boolean = false
  @Local
  sortType: SortTypeMap = SortTypeMap.DEFAULT
  @Local
  filterList: FilterSelectionItem[] = []

  build() {
    NavDestination() {
      Row() {
        SortBar({
          handleSortTypeChange: (type) => {
            this.sortType = type
          },
        })
      }
      .width($r('app.string.size_percent_full'))
      .padding($r('app.float.space_m'))
      .backgroundColor($r('app.color.background_color_white'))

      Column() {
        ProductWaterFlow({
          bgColor: Style.BACKGROUND_COLOR_GREY,
          categoryId: this.curCategoryId,
          sortType: this.sortType,
          filterList: this.filterList,
          showInitLoading: true,
          isVertical: this.vertical,
          handleProductClick: (id: string) => {
            routerStack.pushPath({ name: RouterMap.PRODUCT_INFO, param: id });
          },
        })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      }
      .padding({
        left: $r('app.float.space_l'),
        right: $r('app.float.space_l'),
        top: $r('app.float.space_l'),
      })
      .backgroundColor(Style.BACKGROUND_COLOR_GREY)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .title(this.title)
    .onReady((context) => {
      const param = context.pathInfo.param as ProductSummaryItem | undefined
      if (param) {
        this.title = param.title
        this.curCategoryId = param.id
      }
    })
  }
}