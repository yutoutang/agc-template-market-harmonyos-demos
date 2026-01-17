import { CommonUtils } from '../utils/CommonUtils'
import { SimpleGoodInfo } from '../model/Model'
import { OrderType } from '../constants/AppConstant';

@ComponentV2
export struct UIOrderPart {
  @Param goodInfo: SimpleGoodInfo = new SimpleGoodInfo();

  build() {
    Row({ space: 12 }) {
      Image(CommonUtils.handleImgUrl(this.goodInfo.image)).width(78).aspectRatio(1).borderRadius(8)
      Column() {
        Text(this.goodInfo.title)
          .fontSize(16)
          .fontWeight(500)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        if (this.goodInfo.type === OrderType.GROUP) {
          Text(this.goodInfo.subTitle ?? '随时退·过期自动退')
            .fontSize(12)
            .fontWeight(400)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ top: 2 })
        }
        Blank()
        if (this.goodInfo.type === OrderType.SINGLE_CARD) {
          Text(`项目次数·${this.goodInfo.availableNum}次`)
            .fontSize(12)
            .fontWeight(400)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ bottom: 8 })
        }
        Row({space: 4}) {
          Text('￥' + CommonUtils.handleCash(this.goodInfo.vipPrice)).fontSize(14).fontWeight(500)
          Text('￥' + CommonUtils.handleCash(this.goodInfo.price))
            .fontSize(12)
            .fontColor($r('sys.color.font_tertiary'))
            .fontWeight(400)
            .decoration({ type: TextDecorationType.LineThrough, color: $r('sys.color.font_tertiary') })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .alignSelf(ItemAlign.Stretch)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}
