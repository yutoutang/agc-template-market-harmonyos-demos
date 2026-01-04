import { LineCommonConstants } from '../common/LineCommonConstants';
import { BusCrowdStateMap, LineCongestionStateMap } from '../common/Enums';
import { SettingEnum } from '../common/SettingEnum';
import { BusSubwaySetting } from '../models/BusSubwaySetting';
import { ComingBus, CurrentBusstop, LineDetailBusstop } from '../models/LineDetailModel';

@ComponentV2
export struct BuslineStation {
  // 途径站
  @Param @Require busstops: LineDetailBusstop[]
  // 最近站点
  @Param @Require setting: BusSubwaySetting
  @Param @Require currentStop: CurrentBusstop
  @Local arrivalReminderStations: number = 0
  scroller: Scroller = new Scroller();
  // 轨道半格的宽度
  private halfScalesWidth: number = 28

  @Monitor('currentStop.comingBusList.0.stations')
  onStrChange(monitor: IMonitor) {
    this.currentStop.comingBusList.forEach((comingBus: ComingBus) => {
      let busOffsetIndex = this.currentStop.stopOffsetIndex! - comingBus.stations!
      comingBus.offsetX = busOffsetIndex * this.halfScalesWidth * 2
      comingBus.distance = comingBus.stations! * LineCommonConstants.HALF_DISTANCE_BETWEEN_STOP * 2
    })
  }

  aboutToAppear() {
    // 计算还省多少站警告
    if (this.setting.warnType === SettingEnum.TIME) {
      const warnValue = this.setting.warnValue
      this.arrivalReminderStations = warnValue / (LineCommonConstants.HALF_TIME_BETWEEN_STOP * 2)
    } else {
      this.arrivalReminderStations = this.setting.warnValue
    }

    this.currentStop.comingBusList.forEach((comingBus: ComingBus) => {
      let stations = comingBus.stations!
      if (comingBus.stations! > this.currentStop.stopOffsetIndex!) {
        comingBus.stations = this.currentStop.stopOffsetIndex!
      }
      let busOffsetIndex = this.currentStop.stopOffsetIndex! - stations
      comingBus.offsetX = busOffsetIndex * this.halfScalesWidth * 2
      comingBus.distance = comingBus.stations! * LineCommonConstants.HALF_DISTANCE_BETWEEN_STOP * 2
    })
  }

  onDidBuild(): void {
    this.scroller.scrollTo({ xOffset: (this.currentStop.stopOffsetIndex! - 3) * 56 + 12, yOffset: 0 })
  }

  @Builder
  buslineCome() {
    Row() {
      Column() {
        if (this.setting.isArrivalReminder &&
          this.currentStop.comingBusList[0].stations! <= this.arrivalReminderStations) {
          Image($r('app.media.arrival_notice')).width(10).height(10)
            .offset({ x: 15 })
          Text(this.currentStop.comingBusList[0].stations + '站').lineHeight(16).fontSize(14).fontColor('#E84026')
        } else {
          Image($r('app.media.arrival')).width(10).height(10)
            .offset({ x: 15 })
          Text(this.currentStop.comingBusList[0].stations + '站').lineHeight(16).fontSize(14)
        }
        Text(this.currentStop.comingBusList[0].time + '分钟·' + this.currentStop.comingBusList[0].distance + 'km')
          .fontSize(12)
          .lineHeight(14)
          .margin({ top: 6 })
          .opacity(0.6)
        Text(this.currentStop.comingBusList[0].numberplate).lineHeight(11).fontSize(10)
          .margin({ top: 4 })
          .opacity(0.6)
      }
      .width('33.3%')

      // 设置为垂直方向
      Divider()
        .strokeWidth(1)
        .vertical(true)
        .opacity(0.1)
        .color('#0A59F7')
        .height('12')

      Column() {
        if (this.setting.isArrivalReminder &&
          this.currentStop.comingBusList[1].stations! <= this.arrivalReminderStations) {
          Image($r('app.media.arrival_notice')).width(10).height(10)
            .offset({ x: 15 })
          Text(this.currentStop.comingBusList[1].stations + '站').lineHeight(16).fontSize(14).fontColor('#E84026')
        } else {
          Image($r('app.media.arrival')).width(10).height(10)
            .offset({ x: 15 })
          Text(this.currentStop.comingBusList[1].stations + '站').lineHeight(16).fontSize(14)
        }
        Text(this.currentStop.comingBusList[1].time + '分钟·' + this.currentStop.comingBusList[1].distance + 'km')
          .fontSize(12)
          .lineHeight(14)
          .margin({ top: 6 })
          .opacity(0.6)
        Text(this.currentStop.comingBusList[1].numberplate).lineHeight(11).fontSize(10)
          .margin({ top: 4 })
          .opacity(0.6)
      }
      .width('33.3%')

      // 设置为垂直方向
      Divider()
        .strokeWidth(1)
        .vertical(true)
        .opacity(0.1)
        .color('#0A59F7')
        .height('12')

      Column() {
        if (this.setting.isArrivalReminder &&
          this.currentStop.comingBusList[2].stations! <= this.arrivalReminderStations) {
          Image($r('app.media.arrival_notice')).height(10).width(10)
            .offset({ x: 15 })
          Text(this.currentStop.comingBusList[2].stations + '站').fontSize(14).lineHeight(16).fontColor('#E84026')
        } else {
          Image($r('app.media.arrival')).height(10).width(10)
            .offset({ x: 15 })
          Text(this.currentStop.comingBusList[2].stations + '站').fontSize(14).lineHeight(16)
        }
        Text(this.currentStop.comingBusList[2].time + '分钟·' + this.currentStop.comingBusList[2].distance + 'km')
          .lineHeight(14)
          .fontSize(12)
          .opacity(0.6)
          .margin({ top: 6 })
        Text(this.currentStop.comingBusList[2].numberplate).fontSize(10).lineHeight(11)
          .opacity(0.6)
          .margin({ top: 4 })
      }
      .width('33.3%')
    }
    .backgroundColor('#0d000000')
    .borderRadius(8)
    .margin({ left: 12, right: 12 })
    .padding({ top: 10, bottom: 10 })
  }

  @Builder
  lineArrowImage(index: number) {
    if (this.busstops[index - 1].congestion === this.busstops[index].congestion) {
      Image($r('app.media.line_arrow'))
        .width(4)
        .height(8)
        .offset({ x: -2 })
    }
    if (this.busstops[index - 1].congestion === LineCongestionStateMap.COMFORTABLE &&
      this.busstops[index].congestion === LineCongestionStateMap.SLIGHT_CROWD) {
      Image($r('app.media.line_arrow_gy'))
        .width(4)
        .height(8)
        .offset({ x: -2 })
    }
    if (this.busstops[index - 1].congestion === LineCongestionStateMap.SLIGHT_CROWD &&
      this.busstops[index].congestion === LineCongestionStateMap.SEVERE_CROWD) {
      Image($r('app.media.line_arrow_yr'))
        .width(4)
        .height(8)
        .offset({ x: -2 })
    }
    if (this.busstops[index - 1].congestion === LineCongestionStateMap.SEVERE_CROWD &&
      this.busstops[index].congestion === LineCongestionStateMap.COMFORTABLE) {
      Image($r('app.media.line_arrow_rg'))
        .width(4)
        .height(8)
        .offset({ x: -2 })
    }
    if (this.busstops[index - 1].congestion === LineCongestionStateMap.COMFORTABLE &&
      this.busstops[index].congestion === LineCongestionStateMap.SEVERE_CROWD) {
      Image($r('app.media.line_arrow_gr'))
        .width(4)
        .height(8)
        .offset({ x: -2 })
    }
    if (this.busstops[index - 1].congestion === LineCongestionStateMap.SLIGHT_CROWD &&
      this.busstops[index].congestion === LineCongestionStateMap.COMFORTABLE) {
      Image($r('app.media.line_arrow_yg'))
        .width(4)
        .height(8)
        .offset({ x: -2 })
    }
    if (this.busstops[index - 1].congestion === LineCongestionStateMap.SEVERE_CROWD &&
      this.busstops[index].congestion === LineCongestionStateMap.SLIGHT_CROWD) {
      Image($r('app.media.line_arrow_ry'))
        .width(4)
        .height(8)
        .offset({ x: -2 })
    }
  }

  @Builder
  buslineSlider() {
    Column() {
      Scroll(this.scroller) {
        Row() {
          Column() {
            Stack() {
              ForEach(this.currentStop.comingBusList, (comingBus: ComingBus) => {
                this.buildBusImage(comingBus)
              }, (v: ComingBus) => v.numberplate)
            }

            this.buildLineSection()

            this.buildStationNames()
          }
          .alignItems(HorizontalAlign.Start)
        }
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)
    }
    .width(LineCommonConstants.FULL_PERCENT)
    .margin({
      top: 24,
      bottom: 40
    })
  }

  @Builder
  buildBusImage(comingBus: ComingBus) {
    Image(
      comingBus.crowdState === BusCrowdStateMap.COMFORTABLE ? $r('app.media.bus_blue') :
        comingBus.crowdState === BusCrowdStateMap.SLIGHT_CROWD ? $r('app.media.bus_yellow') :
        $r('app.media.bus_red')
    )
      .width(28)
      .height(14)
      .translate({ x: comingBus.offsetX })
      .margin({
        left: 8,
        bottom: 10,
      })
  }

  @Builder
  buildLineSection() {
    Row() {
      ForEach(this.busstops, (busstop: LineDetailBusstop, index) => {
        this.buildLineSegment(busstop, index)
      }, (v: LineDetailBusstop) => v.id)

      this.buildLastLineSegment()
    }
    .margin({
      left: 12,
      right: 12
    })
  }

  @Builder
  buildLineSegment(busstop: LineDetailBusstop, index: number) {
    if (index === 0) {
      Stack() {
        Row()
          .backgroundColor(this.getBackgroundColor(busstop.congestion ?? ''))
          .width(66)
          .height(8)
          .borderRadius({ topLeft: 6, bottomLeft: 6 })
        if (index === this.currentStop.stopOffsetIndex!) {
          Image($r('app.media.nearest_stop'))
            .width(20)
            .height(20)
        } else {
          Image($r('app.media.line_start'))
            .width(20)
            .height(20)
        }
      }
      .alignContent(Alignment.Start)
    } else if (index < this.busstops.length - 2) {
      Stack() {
        Row()
          .backgroundColor(this.getBackgroundColor(busstop.congestion ?? ''))
          .width(56)
          .height(8)
        if (index === this.currentStop.stopOffsetIndex!) {
          Image($r('app.media.nearest_stop'))
            .width(20)
            .height(20)
            .offset({ x: -10 })
        } else {
          this.lineArrowImage(index)
        }
      }
      .alignContent(Alignment.Start)
    }
  }

  @Builder
  buildLastLineSegment() {
    Stack() {
      Row()
        .backgroundColor(this.getBackgroundColor(this.busstops[this.busstops.length - 2].congestion ?? ''))
        .width(66)
        .height(8)
        .borderRadius({ topRight: 6, bottomRight: 6 })
      if (this.busstops.length - 2 === this.currentStop.stopOffsetIndex!) {
        Image($r('app.media.nearest_stop'))
          .width(20)
          .height(20)
          .offset({ x: -10 })
      } else {
        this.lineArrowImage(this.busstops.length - 2)
      }
      if (this.busstops.length - 1 === this.currentStop.stopOffsetIndex!) {
        Image($r('app.media.nearest_stop'))
          .width(20)
          .height(20)
          .offset({ x: 46 })
      } else {
        Image($r('app.media.line_end'))
          .width(20)
          .height(20)
          .offset({ x: 46 })
      }
    }
    .alignContent(Alignment.Start)
  }

  @Builder
  buildStationNames() {
    Row() {
      ForEach(this.busstops, (item: LineDetailBusstop, index) => {
        if (index === 0) {
          Column() {
            if (index === this.currentStop.stopOffsetIndex!) {
              Text(item.name)
                .fontColor('#0A59F7')
                .fontSize(16)
                .width(16)
                .offset({ x: 2 })
            } else {
              Text(item.name)
                .fontColor('#cc000000')
                .fontSize(12)
                .width(12)
                .offset({ x: 4 })
            }
          }.width(66)
          .alignItems(HorizontalAlign.Start)
        } else if (index < this.busstops.length - 1) {
          Column() {
            if (index === this.currentStop.stopOffsetIndex!) {
              Text(item.name)
                .fontColor('#0A59F7')
                .fontSize(16)
                .width(16)
                .offset({ x: -8 })
            } else {
              Text(item.name)
                .fontColor('#cc000000')
                .fontSize(12)
                .width(12)
                .offset({ x: -6 })
            }
          }.width(56)
          .alignItems(HorizontalAlign.Start)
        }
      }, (v: LineDetailBusstop) => v.id)

      Row() {
        if (this.busstops.length - 1 === this.currentStop.stopOffsetIndex!) {
          Text(this.busstops[this.busstops.length - 1].name)
            .fontColor('#0A59F7')
            .fontSize(16)
            .width(16)
            .offset({ x: -2 })
        } else {
          Text(this.busstops[this.busstops.length - 1].name)
            .fontColor('#cc000000')
            .fontSize(12)
            .width(12)
            .offset({ x: -4 })
        }
      }
      .width(66)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .margin({
      left: 12,
      right: 12
    })
    .alignItems(VerticalAlign.Top)
  }

  getBackgroundColor(congestion: string): string {
    return congestion === LineCongestionStateMap.COMFORTABLE ? '#02A500' :
      congestion === LineCongestionStateMap.SLIGHT_CROWD ? '#F7CE00' : '#E84026'
  }

  build() {
    Scroll() {
      Column() {
        Row() {
          Text('站点: ')
            .fontSize(16)
            .lineHeight(19)
            .fontColor('#e6000000')
            .fontWeight(FontWeight.Bold)
          Text(this.currentStop.name)
            .fontWeight(FontWeight.Bold)
            .fontSize(16)
            .lineHeight(19)
            .fontColor('#0A59F7')
        }
        .margin({
          bottom: 12,
          top: 12,
          left: 12,
          right: 12
        })
        .height(22)

        this.buslineCome()

        this.buslineSlider()

      }
      .width(LineCommonConstants.FULL_PERCENT)
      .constraintSize({ minHeight: 300 })
      .alignItems(HorizontalAlign.Start)
      .backgroundColor($r('app.color.widget_background'))
      .borderRadius(16)
    }
    .height(300)
    .scrollBar(BarState.Off)
  }
}