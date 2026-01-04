import { CarGoodsInfo, OrderItem } from 'lib_takeaway_api';
import { NavHeaderBar } from 'lib_widget';
import { CommentListView } from 'module_store_comments';
import { AppStorageV2 } from '@kit.ArkUI';
import { WindowModel } from 'lib_common';

@Builder
export function buildOrderStoreCommentsPage() {
  OrderStoreCommentsPage()
}

@ComponentV2
struct OrderStoreCommentsPage {
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local
  carGoodsInfo: CarGoodsInfo[] = []
  @Local
  order?: OrderItem = undefined

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '店铺评价',
        bgColor: $r('app.color.background_color_grey')
      })
      CommentListView()

    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background_color_grey'))
    .padding({ bottom: this.windowModel.windowBottomPadding })
    .onReady((context) => {
      const param = context.pathInfo.param as OrderItem | undefined
      if (param) {
        this.order = param
        this.carGoodsInfo = param.carGoodsInfo
      }
    })

  }
}