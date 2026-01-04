import { PersistenceV2 } from '@kit.ArkUI';
import { ArrivalReminderEnum, CommonConstants, SettingModel } from 'lib_common';
import { LineDetailModel } from 'module_station_line_detail';

// 站点公交卡片
@ComponentV2
export struct StationBusCard {
  @Param metroTitle: string = ''
  @Param @Require buslines: LineDetailModel[] // 多条线路信息
  @Param walkingText: string = '' // 步行公里
  // 当需要展示状态文案（如"即将进站"、"等待发车"）时，填充下两个参数
  // 若 statusPrefix 为空字符串，则默认展示 stopCount · stopTime
  @Param statusPrefix: string = '' // ：即将进站 / 等待发车
  @Param statusSubTime: string = '' //  预计18:23到站
  @Param @Require onStationClick?: () => void // 点击站点区域
  @Event routeLineDetailPage: (lineDetailModel: LineDetailModel) => void
  settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;

  @Computed
  get arrivalReminderStations() {
    // 计算还省多少站警告
    if (this.settingInfo.warnType === ArrivalReminderEnum.TIME) {
      const warnValue = this.settingInfo.warnValue
      return warnValue / (CommonConstants.HALF_TIME_BETWEEN_STOP * 2)
    } else {
      return this.settingInfo.warnValue
    }
  }

  build() {
    Column() {
      // 上方区域：站点信息
      Row() {
        Row() {
          Image($r('app.media.near_bus')).width(21).aspectRatio(1)
          Text(this.metroTitle).margin({ left: 6 }).fontSize(16)
          Image($r('app.media.walk')).height(18).margin({ right: 4, left: 10 }).width(18)
          Text(this.walkingText).fontSize(16)
        }

        Image($r('app.media.ic_right')).width(12).height(24)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        if (this.onStationClick) {
          this.onStationClick()
        }
      })

      // 下方区域：多条线路信息
      Column() {
        ForEach(this.buslines, (busline: LineDetailModel, index: number) => {
          Row() {
            Column() {
              Text(busline.name)
                .fontColor(Color.Black)
                .fontSize(15)
              Row() {
                Text('开往').margin({ right: 8 }).fontColor('#777777')
                Text(busline.endStop)
                  .fontColor('#777777')
                  .width('40%')
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
                  .fontSize(15)
              }.margin({ top: 15 })
            }.alignItems(HorizontalAlign.Start)

            // Row() {
            if (busline.currentStop?.comingBusList[0].stations! <= this.arrivalReminderStations &&
            this.settingInfo.isArrivalReminder) {
              if (busline.currentStop?.comingBusList[0].stations! <= 1) {
                Row() {
                  Text('即将进站').fontColor('#E84026').fontSize(16)
                  Text('·').fontColor('#E84026').margin({ left: 1, right: 1 })
                  Text(busline.currentStop?.comingBusList[0].time + '分钟').fontSize(16).fontColor('#E84026')
                  Image($r('app.media.arrival_notice')).height(10).width(10)
                    .offset({ y: -15 })
                }
              } else {
                Row() {
                  Text(`${busline.currentStop?.comingBusList[0].stations}站`).fontSize(16).fontColor('#E84026')
                  Text('·').fontColor('#E84026').margin({ left: 1, right: 1 })
                  Text(busline.currentStop?.comingBusList[0].time + '分钟').fontSize(16).fontColor('#E84026')
                  Image($r('app.media.arrival_notice')).width(10).height(10)
                    .offset({ y: -15 })
                }
              }
            } else {
              if (busline.currentStop?.comingBusList[0].stations! <= 1) {
                Row() {
                  Text('即将进站').fontColor('#0A59F7').fontSize(16)
                  Text('·').fontColor('#0A59F7').margin({ left: 1, right: 1 })
                  Text(busline.currentStop?.comingBusList[0].time + '分钟').fontSize(16).fontColor('#0A59F7')
                  Image($r('app.media.arrival')).width(10).height(10)
                    .offset({ y: -15 })
                }
              } else {
                Row() {
                  Text(`${busline.currentStop?.comingBusList[0].stations}站`).fontColor('#0A59F7').fontSize(16)
                  Text('·').fontColor('#0A59F7').margin({ left: 1, right: 1 })
                  Text(busline.currentStop?.comingBusList[0].time + '分钟').fontSize(16).fontColor('#0A59F7')
                  Image($r('app.media.arrival')).width(10).height(10)
                    .offset({ y: -15 })
                }
              }
            }
            // }
          }
          .onClick(() => {
            this.routeLineDetailPage(busline)
          })
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ bottom: 15, top: 15 })
          .border({ width: { top: 1 }, color: '#f2f2f2' })
        })
      }
      .margin({ top: 15 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius(16)
    .margin({ bottom: 17 })
    .padding({
      left: 12,
      top: 15,
      right: 10
    })
  }
}