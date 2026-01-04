import { SubwayDirection, SubwayLineInfo } from '../models/StopDetailModel'
import { StopCommonConstants } from '../common/StopCommonConstants'
import { LineDetailModel } from '../line/models/LineDetailModel'

@ComponentV2
export struct SubwayLineItem {
  @Param @Require subwayLine: SubwayLineInfo
  @Event routeLineDetailPage: (lineDetailModel: LineDetailModel) => void

  build() {
    Column() {
      // 线路名称和颜色标识
      Text(this.subwayLine.lineName || '')
        .fontSize(16)
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Medium)
        .padding({
          left: 5,
          right: 5,
          top: 4,
          bottom: 4
        })
        .backgroundColor(this.subwayLine.lineColor || '#C20039')
        .borderRadius(8)
        .margin({ bottom: 10 })

      // 双向信息
      if (this.subwayLine.directions && this.subwayLine.directions.length > 0) {
        ForEach(this.subwayLine.directions, (direction: LineDetailModel, index: number) => {
          this.directionInfo(direction, index)
        }, (v: LineDetailModel) => v.id)
      }
    }
    .width(StopCommonConstants.FULL_PERCENT)
    .padding({
      top: 12,
      left: 12,
      right: 12,
      bottom: 10
    })
    .backgroundColor('#ffffff')
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  directionInfo(direction: LineDetailModel, index: number) {
    Column() {
      Row() {
        Text(`开往 ${direction.endStop || ''}`)
          .fontColor('#777777')
          .fontSize(15)

        Text(`首 ${direction.startTime || ''}｜末 ${direction.endTime || ''}`)
          .fontColor('#777777')
          .fontSize(15)
      }
      .padding({ bottom: 10, top: 10 })
      .width(StopCommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .border({ width: { bottom: index < (this.subwayLine.directions?.length || 0) - 1 ? 1 : 0 }, color: '#f2f2f2' })
      .onClick(() => {
        this.routeLineDetailPage(direction)
      })
    }
    .width(StopCommonConstants.FULL_PERCENT)
  }
}


