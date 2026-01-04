import { RouterMap, RouterUtils } from 'lib_common'
import { BaseMineCustomerServiceQA } from 'lib_takeaway_api/src/main/ets/database/MineCustomerServiceQAType'
import { MineCustomerServiceViewModel } from '../viewmodels/MineCustomerServiceVM'

@Builder
export function BaseQAComponent(item: BaseMineCustomerServiceQA, vm: MineCustomerServiceViewModel) {

  Row({ space: 8 }) {
    Column() {
      Text(item.question)
        .fontSize(16)
        .fontColor($r('sys.color.font_primary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontWeight('medium')
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)

    Image($r('app.media.ic_right'))
      .width($r('app.float.arrow_right_w'))
      .draggable(false)
  }
  .onClick(() => {
    // 跳转到详情页面
    RouterUtils.pushPathByName(RouterMap.MINE_CUSTOMER_SERVICE_DETAIL, item)
  })
  .width('100%')
}