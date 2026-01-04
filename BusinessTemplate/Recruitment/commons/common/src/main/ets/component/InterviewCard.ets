import { PositionInfo } from '../model/PositionModel'
import { getInterviewTime } from '../util/DateUtil'

@ComponentV2
export struct InterviewCard {
  @Param @Require positionInfoData: PositionInfo

  build() {
    Row() {
      Row() {
        Text('logo')
          .fontSize(14)
          .fontColor('#999999')
      }
      .width(64)
      .height(64)
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)

      Column() {
        Text(this.positionInfoData.companyName)
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(`${this.positionInfoData.jobTitle}`)
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 8 })
          Text(getInterviewTime())
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 8 })
        }.width('100%').justifyContent(FlexAlign.SpaceBetween)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }
}
