import { RouterMap, RouterUtils } from 'lib_common'

@ComponentV2
export struct UnderReviewCard {
  @Event ToRecordPage: () => void = () => {
  }


  build() {
    Column({ space: 24 }) {
      Image($r('app.media.under_review'))
        .width(64)
        .aspectRatio(1)
      Text('资料审核中')
        .fontSize(20)
        .lineHeight(28)
        .fontColor('rgba(0, 0, 0, 0.90)')
        .fontWeight(600)

      Text('资料正在审核中，请耐心等待，后续可在“贷款记录”内查看审核进度')
        .fontSize(12)
        .fontColor('rgba(0, 0, 0, 0.60)')
        .lineHeight(17)
        .textAlign(TextAlign.Center)

      Text('查看贷款记录')
        .backgroundColor('rgba(0, 0, 0, 0.05)')
        .fontColor('#317AF7')
        .fontSize(16)
        .lineHeight(22)
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Medium)
        .borderRadius(20)
        .padding({ top: 10, bottom: 10 })
        .onClick(() => {
          RouterUtils.replacePathByName(RouterMap.LOAN_RECORD_PAGE);
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({ left: 16, right: 16 })
    .layoutWeight(1)
  }
}