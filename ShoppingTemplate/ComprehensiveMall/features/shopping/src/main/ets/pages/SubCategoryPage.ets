import { RouterMap, routerStack, Style } from 'lib_foundation';
import { ProductSummaryItem } from 'lib_network';
import { ProductWaterFlow, RequestType } from 'module_product_waterflow';

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

  build() {
    NavDestination() {
      Column() {
        ProductWaterFlow({
          bgColor: Style.BACKGROUND_COLOR_GREY,
          requestType: RequestType.BY_CATEGORY,
          categoryId: this.curCategoryId,
          showInitLoading: true,
          handleProductClick: (id: string) => {
            routerStack.pushPath({ name: RouterMap.PRODUCT_INFO_NEW, param: id });
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