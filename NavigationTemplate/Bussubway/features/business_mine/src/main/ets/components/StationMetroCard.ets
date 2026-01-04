import { geoLocationManager } from '@kit.LocationKit';
import { LineDetailModel, SubwayLineInfo } from 'module_station_line_detail';
import { LocationUtils, MapCommonConstants, RouterMap, RouterUtils } from 'lib_common';

// 站点地铁卡片
@ComponentV2
export struct StationMetroCard {
  @Param metroTitle: string = '' // 地铁站
  @Param @Require subwayLines: SubwayLineInfo[] // 多条地铁线路信息
  @Param walkingText: string = '' // 步行公里
  @Param firstTime: string = '' // 首 时间
  @Param lastTime: string = '' // 末 时间
  @Param @Require onStationClick?: () => void // 点击站点区域
  @Event routeLineDetailPage: (lineDetailModel: LineDetailModel) => void

  build() {
    Column() {
      // 上方区域：站点信息
      Row() {
        Row() {
          Image($r('app.media.near_metro')).width(21).aspectRatio(1)
          Text(`${this.metroTitle}`).margin({ left: 6 }).fontSize(16)
          Image($r('app.media.walk')).width(18).height(18).margin({ right: 4, left: 10 })
          Text(this.walkingText).fontSize(16)
        }

        Image($r('app.media.ic_right')).width(20).height(20)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .border({ width: { bottom: 1 }, color: '#f2f2f2' })
      .padding({ bottom: 15 })
      .onClick(() => {
        if (this.onStationClick) {
          this.onStationClick()
        }
      })

      // 下方区域：多条地铁线路信息
      Column() {
        ForEach(this.subwayLines, (subwayLine: SubwayLineInfo, index: number) => {
          Column() {
            // 线路标签和图标（每个新线路都显示）
            Row() {
              Text(subwayLine.lineName)
                .fontSize(16)
                .fontColor(Color.Black)
                .backgroundColor(subwayLine.lineColor)
                .padding({
                  left: 5,
                  right: 5,
                  top: 4,
                  bottom: 4
                })
                .borderRadius(8)
              Image($r('app.media.ditietu'))
                .width(27)
                .aspectRatio(1)
                .margin({ left: 12 })
                .onClick(async () => {
                  let request: geoLocationManager.SingleLocationRequest = {
                    locatingPriority: MapCommonConstants.PRIORITY_LOCATING_SPEED,
                    locatingTimeoutMs: MapCommonConstants.LOCATING_TIMEOUT_MS
                  };
                  const location = await LocationUtils.getGCJ02CurrentLocation()
                  RouterUtils.pushPathByName(RouterMap.SUBWAY_PAGE, location.longitude + ',' + location.latitude)
                })
            }.width('100%').margin({ top: 10 })

            ForEach(subwayLine.directions, (lineDetailModel: LineDetailModel, index: number) => {
              Row() {
                Row() {
                  Text('开往').margin({ right: 8 }).fontColor('#777777').fontSize(15)
                  Text(lineDetailModel.endStop).fontColor('#777777').fontSize(15)
                }

                Text(lineDetailModel.startTime && lineDetailModel.endTime ?
                  `首 ${lineDetailModel.startTime} ${'|'} 末 ${lineDetailModel.endTime}` : '')
                  .fontColor('#777777')
                  .fontSize(15)
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .border({ width: { top: index > 0 ? 1 : 0 }, color: '#f2f2f2' })
              .padding({ bottom: 15, top: 15 })
              .onClick(() => {
                this.routeLineDetailPage(lineDetailModel)
              })
            }, (v: LineDetailModel) => v.id)
          }
        }, (v: SubwayLineInfo) => v.lineName)
      }

    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
    .margin({ bottom: 17 })
    .borderRadius(16)
    .padding({
      top: 15,
      left: 10,
      right: 10
    })
  }
}