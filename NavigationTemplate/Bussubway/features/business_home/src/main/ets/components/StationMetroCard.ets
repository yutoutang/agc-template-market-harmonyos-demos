import { geoLocationManager } from '@kit.LocationKit';
import { LocationUtils, MapCommonConstants, RouterMap, RouterUtils } from 'lib_common';
import { LineDetailModel, SubwayLineInfo } from 'module_station_line_detail';

// 站点地铁卡片
@ComponentV2
export struct StationMetroCard {
  // 地铁站名称
  @Param metroTitle: string = ''
  // 步行公里
  @Param walkingText: string = ''
  // 多条地铁线路信息
  @Param subwayLines: SubwayLineInfo[] = []
  // 点击线路区域
  @Param @Require onLineClick?: (busline: LineDetailModel) => void
  // 点击站点区域
  @Param @Require onStationClick?: () => void

  build() {
    Column() {
      // 上方区域：站点信息
      Row() {
        Row() {
          Image($r('app.media.near_metro')).aspectRatio(1).width(21)
          Text(`${this.metroTitle}`).fontSize(16).margin({ left: 6 })
          Image($r('app.media.walk')).height(18).width(18).margin({ right: 4, left: 10 })
          Text(this.walkingText).fontSize(16)
        }

        Image($r('app.media.ic_right')).width(12).height(24)
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
                  top: 4,
                  right: 5,
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
            }.margin({ top: 10 }).width('100%')

            ForEach(subwayLine.directions, (direction: LineDetailModel, index: number) => {
              Row() {
                Row() {
                  Text('开往').margin({ right: 8 }).fontColor('#777777').fontSize(15)
                  Text(direction.endStop).fontColor('#777777').fontSize(15)
                }

                Text(direction.startTime && direction.endTime ?
                  `首 ${direction.startTime} ${'|'} 末 ${direction.endTime}` : '')
                  .fontColor('#777777')
                  .fontSize(15)
              }
              .width('100%')
              .border({ width: { top: index > 0 ? 1 : 0 }, color: '#f2f2f2' })
              .padding({ bottom: 15, top: 15 })
              .justifyContent(FlexAlign.SpaceBetween)
              .onClick(() => {
                if (this.onLineClick) {
                  this.onLineClick(direction)
                }
              })
            }, (v: LineDetailModel) => v.id)

          }
        }, (v: SubwayLineInfo) => v.lineName)
      }
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .margin({ bottom: 17 })
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding({
      right: 10,
      top: 15,
      left: 10
    })
  }
}