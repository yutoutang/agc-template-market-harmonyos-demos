import { LazyDataSource, ObservedArray } from 'module_ui_base'
import { Constants } from '../commons/Constants';
import { ProductReviewItem } from '../commons/Types'
import { ProductReviewCard } from '../components/ProductReviewCard'
import { ProductDetailApis } from '../https/Apis';

@Builder
export function buildProductReview() {
  ProductReviewList()
}

@ComponentV2
export struct ProductReviewList {
  @Local
  reviewList: LazyDataSource<ProductReviewItem> = new LazyDataSource()
  @Local
  productId: string = 'product_10001'
  @Local
  isLoading: boolean = false;
  @Local
  isRefreshing: boolean = false;
  @Local
  curPage: number = 1
  @Local
  totalNum: number = 0
  @Local
  reachEnd: boolean = false;

  build() {
    NavDestination() {
      List({ space: 32 }) {
        LazyForEach(this.reviewList, (reviewItem: ProductReviewItem) => {
          ListItem() {
            ProductReviewCard({ reviewItem })
          }
        }, (item: ProductReviewItem, index: number) => index + '__' + item.content)
        if (this.isLoading) {
          ListItem() {
            Row() {
              LoadingProgress()
                .width(20)
                .margin({ right: $r('app.string.space_s') })
              Text('加载中')
                .fontSize($r('app.string.font_size_14'))
                .fontColor(Constants.FONT_COLOR_LEVEL2)
            }
            .width($r('app.string.size_percent_full'))
            .justifyContent(FlexAlign.Center)
            .height(60)
          }
        }

        if (this.reachEnd) {
          ListItem() {
            Text('已经到达底部')
              .fontSize($r('app.string.font_size_12'))
              .fontColor($r('app.color.font_color_level3'))
              .width($r('app.string.size_percent_full'))
              .textAlign(TextAlign.Center)
              .height(36)
          }
        }
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .scrollBar(BarState.Off)
      .onReachEnd(async () => {
        await this.getReviewList()
      })
      .padding({
        left: $r('app.string.space_l'),
        right: $r('app.string.space_l'),
        top: $r('app.string.space_m'),
      })
      .divider({ strokeWidth: 1, color: $r('sys.color.comp_divider') })

    }
    .title('全部评价')
    .onReady((context) => {
      const param = context.pathInfo.param as string
      if (param) {
        this.productId = param;
        this.refreshCommentList()
      }
    })
  }

  async refreshCommentList() {
    this.reachEnd = false
    this.curPage = 1
    this.totalNum = 0
    this.reviewList.clear()
    this.getReviewList(true)
  }

  async getReviewList(isRefresh: boolean = false) {
    if (this.reachEnd || this.isRefreshing || this.isLoading) {
      return;
    }
    if (isRefresh) {
      this.isRefreshing = true
    } else {
      this.isLoading = true
    }
    const res = await ProductDetailApis.getProductReviewList(this.productId, this.curPage)
    if (res) {
      this.totalNum = res.total
      const newList = new ObservedArray(res.reviewList)
      if (isRefresh) {
        this.reviewList.clear()
      }
      this.reviewList.appendArrayData(newList)
      if (res.isFinal) {
        this.reachEnd = true
      }
      this.curPage++
    }
    this.isRefreshing = false;
    this.isLoading = false;
  }
}