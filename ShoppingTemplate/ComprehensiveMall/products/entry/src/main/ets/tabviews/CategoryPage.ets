import { routerStack, RouterMap } from 'lib_foundation';
import { NavTitleBar } from 'lib_widget';
import { CategoryItem, HomeApis, ProductSummaryItem } from 'lib_network';
import { ProductCategory } from 'module_product_category';

@ComponentV2
export struct CategoryPageContent {
  @Param
  public pageName: string | undefined = '';
  @Param
  public initId: string = '';
  @Local
  isLoading: boolean = false;
  @Local
  categoryTabs: CategoryItem[] = [];
  @Local
  curIndex: number = 0;
  @Local
  productList: ProductSummaryItem[] = []

  private readonly SEARCH_ID = 'category_search'

  async getCategoryProductData(id: string) {
    this.isLoading = true;
    const res = await HomeApis.getCategoryProductList(id)
    if (res.code === 0) {
      this.productList = res.productList;
    }
    this.isLoading = false;
  }

  public aboutToAppear(): void {
    this.isLoading = true;
    HomeApis.getHomeConfig().then((res) => {
      if (res.code === 0) {
        this.categoryTabs = res.categoryList;
        const index = this.categoryTabs.findIndex((item) => item.id === this.initId);
        if (index >= 0) {
          this.curIndex = index;
          if (this.categoryTabs[0].subCategory?.length) {
            this.getCategoryProductData(this.categoryTabs[0].subCategory[0].id)
          }
        }
      }
    })
      .finally(() => {
        this.isLoading = false;
      })
  }

  build() {
    NavDestination() {
      Column() {
        NavTitleBar({
          title: '分类',
        }) {
          Row() {
            Image($r('app.media.ic_search_filled'))
              .width(40)
              .height(40)
              .id(this.SEARCH_ID)
              .onClick(() => {
                routerStack.pushPath({name: RouterMap.PRODUCT_SEARCH});
              })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.End)
        }
        ProductCategory({
          initIndex: this.curIndex,
          categoryTabs: this.categoryTabs,
          productList: this.productList,
          isLoading: this.isLoading,
          handleSubCategoryChange: (id) => {
            this.getCategoryProductData(id)
          },
          handleClickCard: (item) => {
            routerStack.pushPath({ name: RouterMap.PRODUCT_SUBCATEGORY, param: item })
          },
        })
      }
      .width('100%')
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background_color_grey'))
  }
}

@Builder
export function buildCategoryPage(pageName?: string, initId?: string) {
  CategoryPageContent({ pageName: pageName, initId: initId })
}
