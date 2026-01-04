import { LineDetailModel } from '../line/models/LineDetailModel'
import { BusSubwaySetting } from '../line/models/BusSubwaySetting'
import { StopCommonConstants } from '../common/StopCommonConstants'

@ComponentV2
export struct BusLineItem {
  @Param @Require busLine: LineDetailModel
  // 还有多少站台需要提醒
  @Param arrivalReminderStations: number = 0
  @Event routeLineDetailPage: (lineDetailModel: LineDetailModel) => void
  @Param setting: BusSubwaySetting = new BusSubwaySetting();

  build() {
    Row() {
      Column() {
        // 线路名称
        Text(this.busLine.name || '')
          .fontSize(16)
          .fontColor('#000000')
        // 开往方向
        Text(`开往 ${this.busLine.endStop || ''}`)
          .fontSize(14)
          .fontColor('#777777')
          .margin({ top: 10 })
          .width('45%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }.alignItems(HorizontalAlign.Start)

      // 实时状态和到站信息
      Row() {
        // 运行中状态 - 如果有实时数据就显示，没有就显示基本信息
        if (this.busLine.currentStop &&
        this.busLine.currentStop.comingBusList && this.busLine.currentStop.comingBusList[0] &&
          this.busLine.currentStop?.comingBusList[0].stations !== undefined) {
          if (this.busLine.currentStop?.comingBusList[0].stations! <= this.arrivalReminderStations &&
          this.setting.isArrivalReminder) {
            if (this.busLine.currentStop?.comingBusList[0].stations! <= 1) {
              Row() {
                Text('即将进站').fontColor('#E84026').fontSize(16)
                Text('·').fontColor('#E84026').margin({ left: 1, right: 1 })
                Text(this.busLine.currentStop?.comingBusList[0].time + '分钟').fontColor('#E84026').fontSize(16)
                Image($r('app.media.arrival_notice')).width(10).height(10)
                  .offset({ y: -15 })
              }
            } else {
              Row() {
                Text(`${this.busLine.currentStop?.comingBusList[0].stations}站`).fontColor('#E84026').fontSize(16)
                Text('·').fontColor('#E84026').margin({ left: 1, right: 1 })
                Text(this.busLine.currentStop?.comingBusList[0].time + '分钟').fontColor('#E84026').fontSize(16)
                Image($r('app.media.arrival_notice')).width(10).height(10)
                  .offset({ y: -15 })
              }
            }
          } else {
            if (this.busLine.currentStop?.comingBusList[0].stations! <= 1) {
              Row() {
                Text('即将进站').fontColor('#0A59F7').fontSize(16)
                Text('·').fontColor('#0A59F7').margin({ left: 1, right: 1 })
                Text(this.busLine.currentStop?.comingBusList[0].time + '分钟').fontColor('#0A59F7').fontSize(16)
                Image($r('app.media.arrival')).width(10).height(10)
                  .offset({ y: -15 })
              }
            } else {
              Row() {
                Text(`${this.busLine.currentStop?.comingBusList[0].stations}站`).fontColor('#0A59F7').fontSize(16)
                Text('·').fontColor('#0A59F7').margin({ left: 1, right: 1 })
                Text(this.busLine.currentStop?.comingBusList[0].time + '分钟').fontColor('#0A59F7').fontSize(16)
                Image($r('app.media.arrival')).width(10).height(10)
                  .offset({ y: -15 })
              }
            }
          }
        }
      }

    }
    .onClick(() => {
      this.routeLineDetailPage(this.busLine)
    })
    .width(StopCommonConstants.FULL_PERCENT)
    .padding({
      top: 12,
      left: 12,
      right: 12,
      bottom: 10
    })
    .backgroundColor('#ffffff')
    .borderRadius(16)
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: 16 })
  }
}