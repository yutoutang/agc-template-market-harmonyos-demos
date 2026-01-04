import { PersistenceV2 } from '@kit.ArkUI'
import { LineDetailModel } from 'module_station_line_detail'
import { ArrivalReminderEnum, CommonConstants, SettingModel } from 'lib_common'

// 站点公交卡片
@ComponentV2
export struct StationBusCard {
  @Param metroTitle: string = ''
  @Param buslines: LineDetailModel[] = [] // 多条线路信息
  @Param walkingText: string = '' // 步行公里
  @Param @Require onStationClick?: () => void // 点击站点区域
  @Param @Require onLineClick?: (busline: LineDetailModel) => void // 点击线路区域
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
          Image($r('app.media.walk')).width(18).height(18).margin({ right: 4, left: 10 })
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
                  .fontSize(15)
                  .width('40%')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }.margin({ top: 15 })
            }.alignItems(HorizontalAlign.Start)

            if (busline.currentStop?.comingBusList[0].stations! <= this.arrivalReminderStations &&
            this.settingInfo.isArrivalReminder) {
              if (busline.currentStop?.comingBusList[0].stations! <= 1) {
                Row() {
                  Text('即将进站').fontColor('#E84026').fontSize(16)
                  Text('·').fontColor('#E84026').margin({ left: 1, right: 1 })
                  Text(busline.currentStop?.comingBusList[0].time + '分钟').fontColor('#E84026').fontSize(16)
                  Image($r('app.media.arrival_notice')).width(10).height(10)
                    .offset({ y: -15 })
                }
              } else {
                Row() {
                  Text(`${busline.currentStop?.comingBusList[0].stations}站`).fontColor('#E84026').fontSize(16)
                  Text('·').fontColor('#E84026').margin({ left: 1, right: 1 })
                  Text(busline.currentStop?.comingBusList[0].time + '分钟').fontColor('#E84026').fontSize(16)
                  Image($r('app.media.arrival_notice')).width(10).height(10)
                    .offset({ y: -15 })
                }
              }

            } else {
              if (busline.currentStop?.comingBusList[0].stations! <= 1) {
                Row() {
                  Text('即将进站').fontColor('#0A59F7').fontSize(16)
                  Text('·').fontColor('#0A59F7').margin({ left: 1, right: 1 })
                  Text(busline.currentStop?.comingBusList[0].time + '分钟').fontColor('#0A59F7').fontSize(16)
                  Image($r('app.media.arrival')).width(10).height(10)
                    .offset({ y: -15 })
                }
              } else {
                Row() {
                  Text(`${busline.currentStop?.comingBusList[0].stations}站`).fontColor('#0A59F7').fontSize(16)
                  Text('·').fontColor('#0A59F7').margin({ left: 1, right: 1 })
                  Text(busline.currentStop?.comingBusList[0].time + '分钟').fontColor('#0A59F7').fontSize(16)
                  Image($r('app.media.arrival')).width(10).height(10)
                    .offset({ y: -15 })
                }
              }

            }
          }
          .width('100%')
          .border({ width: { top: 1 }, color: '#f2f2f2' })
          .padding({ bottom: 15, top: 15 })
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            if (this.onLineClick) {
              this.onLineClick(busline)
            }
          })
        }, (v: LineDetailModel) => v.id)
      }
      .margin({ top: 15 })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
    .margin({ bottom: 17 })
    .borderRadius(16)
    .padding({
      top: 15,
      left: 12,
      right: 10
    })
  }
}