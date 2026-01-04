import { LineCommonConstants } from '../common/LineCommonConstants';
import { SubWayCarCrowdStateMap, SubWayCarTempretureStateMap } from '../common/Enums';
import { CurrentBusstop, LineDetailBusstop, SubwayCarState, TransferDetailLine } from '../models/LineDetailModel';

@ComponentV2
export struct SubwaylineStation {
  // 途径站
  @Param @Require busstops: LineDetailBusstop[]
  // 最近站点
  @Param @Require currentStop: CurrentBusstop
  // 车厢提示
  @Local carNoticePopup: boolean = false
  scroller: Scroller = new Scroller();

  onDidBuild(): void {
    this.scroller.scrollTo({ xOffset: (this.currentStop.stopOffsetIndex! - 3) * 56 + 12, yOffset: 0 })
  }

  @Monitor('currentStop.stopOffsetIndex')
  onCurrentStopChange() {
    this.scroller.scrollTo({ xOffset: (this.currentStop.stopOffsetIndex! - 3) * 56 + 12, yOffset: 0 })
  }

  @Builder
  carNoticePopupBuilder() {
    Row() {
      Column() {
        Row() {
          Row()
            .height(2)
            .width(16)
            .margin({ left: 4 })
            .backgroundColor('#02A500')
          Text('轻松舒适')
            .fontSize(14)
            .opacity(0.9)
            .margin({ left: 12 })
        }
        .height(24)
        .justifyContent(FlexAlign.Start)
        .width('100%')

        Row() {
          Row()
            .backgroundColor('#F7CE00')
            .width(16)
            .margin({ left: 4 })
            .height(2)
          Text('轻微拥挤')
            .opacity(0.9)
            .margin({ left: 12 })
            .fontSize(14)
        }
        .height(24)
        .width('100%')
        .margin({ top: 8 })
        .justifyContent(FlexAlign.Start)

        Row() {
          Row()
            .width(16)
            .backgroundColor('#E84026')
            .margin({ left: 4 })
            .height(2)
          Text('严重拥挤')
            .margin({ left: 12 })
            .fontSize(14)
            .opacity(0.9)
        }
        .margin({ top: 8 })
        .width('100%')
        .height(24)
        .justifyContent(FlexAlign.Start)
      }
      .height('100%')
      .width('50%')

      Column() {
        Row() {
          Image($r('app.media.car_weak_cold'))
            .height(20)
            .width(20)
          Text('弱冷车厢')
            .margin({ left: 12 })
            .opacity(0.9)
            .fontSize(14)
        }
        .justifyContent(FlexAlign.Start)
        .width('100%')
        .height(24)

        Row() {
          Image($r('app.media.car_strong_cold'))
            .height(20)
            .width(20)
          Text('强冷车厢')
            .margin({ left: 12 })
            .opacity(0.9)
            .fontSize(14)
        }
        .margin({ top: 8 })
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .height(24)

        Row() {
          Image($r('app.media.car_business'))
            .height(20)
            .width(20)
          Text('商务车厢')
            .margin({ left: 12 })
            .fontSize(14)
            .opacity(0.9)
        }
        .width('100%')
        .margin({ top: 8 })
        .height(24)
        .justifyContent(FlexAlign.Start)
      }
      .height('100%')
      .width('50%')
      .margin({ left: 4 })
    }.width(236).height(112).padding(12)
  }

  @Builder
  subwayCarState() {
    Column() {
      Row() {
        Image($r('app.media.subway_car_notice'))
          .height(25)
          .width(22)
          .padding({ top: 6, right: 6, bottom: 3 })
          .onClick(() => {
            this.carNoticePopup = !this.carNoticePopup
          })
          .bindPopup(this.carNoticePopup, {
            builder: this.carNoticePopupBuilder, // 气泡的内容
            placement: Placement.TopLeft, // 气泡的弹出位置
            onStateChange: (e) => {
              if (!e.isVisible) {
                this.carNoticePopup = false
              }
            }
          })
      }
      .width(LineCommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.End)

      Row() {
        ForEach(this.currentStop.comingSubwayCarList, (subwayCar: SubwayCarState, index) => {
          this.renderSubwayCar(subwayCar, index)
        }, (v: SubwayCarState) => v.crowdState)
      }
      .margin({ left: 10, right: 10 })
    }
    .borderRadius(8)
    .backgroundColor('#0d000000')
    .margin({ left: 12, right: 12 })
    .height(87)
  }

  @Builder
  renderSubwayCar(subwayCar: SubwayCarState, index: number) {
    if (index === 0) {
      this.renderFirstCar(subwayCar, index)
    } else if (index === this.currentStop.comingSubwayCarList.length - 1) {
      this.renderLastCar(subwayCar, index)
    } else {
      this.renderMiddleCar(subwayCar, index)
    }
  }

  @Builder
  renderFirstCar(subwayCar: SubwayCarState, index: number) {
    Column() {
      if (subwayCar.crowdState === SubWayCarCrowdStateMap.COMFORTABLE) {
        this.comingSubwayCarItem1($r('app.media.car_state_bl'), index + 1)
      } else if (subwayCar.crowdState === SubWayCarCrowdStateMap.SLIGHT_CROWD) {
        this.comingSubwayCarItem1($r('app.media.car_state_yl'), index + 1)
      } else {
        this.comingSubwayCarItem1($r('app.media.car_state_rl'), index + 1)
      }

      this.renderCarTemperatureIcon(subwayCar)
    }
    .layoutWeight(1)
  }

  @Builder
  renderLastCar(subwayCar: SubwayCarState, index: number) {
    Column() {
      if (subwayCar.crowdState === SubWayCarCrowdStateMap.COMFORTABLE) {
        this.comingSubwayCarItem2($r('app.media.car_state_br'), index + 1)
      } else if (subwayCar.crowdState === SubWayCarCrowdStateMap.SLIGHT_CROWD) {
        this.comingSubwayCarItem2($r('app.media.car_state_yr'), index + 1)
      } else {
        this.comingSubwayCarItem2($r('app.media.car_state_rr'), index + 1)
      }

      this.renderCarTemperatureIcon(subwayCar)
    }
    .margin({ left: 3 })
    .layoutWeight(1)
  }

  @Builder
  renderMiddleCar(subwayCar: SubwayCarState, index: number) {
    Column() {
      if (subwayCar.crowdState === SubWayCarCrowdStateMap.COMFORTABLE) {
        this.comingSubwayCarItem3('#02A500', index + 1)
      } else if (subwayCar.crowdState === SubWayCarCrowdStateMap.SLIGHT_CROWD) {
        this.comingSubwayCarItem3('#F7CE00', index + 1)
      } else {
        this.comingSubwayCarItem3('#E84026', index + 1)
      }

      this.renderCarTemperatureIcon(subwayCar)
    }
    .layoutWeight(1)
    .margin({ left: 3 })
  }

  @Builder
  renderCarTemperatureIcon(subwayCar: SubwayCarState) {
    if (subwayCar.tempretureState === SubWayCarTempretureStateMap.WEAK_COLD) {
      Image($r('app.media.car_weak_cold'))
        .height(14)
        .width(14)
        .margin({ top: 9 })
    } else if (subwayCar.tempretureState === SubWayCarTempretureStateMap.STRONG_COLD) {
      Image($r('app.media.car_strong_cold'))
        .height(14)
        .width(14)
        .margin({ top: 9 })
    } else {
      Image($r('app.media.car_business'))
        .height(14)
        .width(14)
        .margin({ top: 9 })
    }
  }

  @Builder
  comingSubwayCarItem1(url: ResourceStr, no: number) {
    Stack() {
      Image(url)
        .height(28)
        .width('100%')
        .objectFit(ImageFit.Fill)
      Text(no + '')
        .fontColor('#E6000000')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .margin({ left: 5 })
    }
  }

  @Builder
  comingSubwayCarItem2(url: ResourceStr, no: number) {
    Stack() {
      Image(url)
        .width('100%')
        .height(28)
        .objectFit(ImageFit.Fill)
      Text(no + '')
        .fontSize(16)
        .fontColor('#E6000000')
        .fontWeight(FontWeight.Bold)
        .margin({ right: 5 })
    }
  }

  @Builder
  comingSubwayCarItem3(color: string, no: number) {
    Row() {
      Text(no + '')
        .fontSize(16)
        .fontColor('#E6000000')
        .fontWeight(FontWeight.Bold)
    }
    .justifyContent(FlexAlign.Center)
    .borderWidth(2)
    .height(28)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderColor(color)
  }

  @Builder
  buslineSlider() {
    Column() {
      Scroll(this.scroller) {
        Row() {
          Column() {
            Row() {
              ForEach(this.busstops, (busstop: LineDetailBusstop, index) => {
                this.renderStationIndicator(index);
              }, (v: LineDetailBusstop) => v.id)
              this.renderLastStationIndicator();
            }
            .margin({
              left: 12,
              right: 12
            })

            Row() {
              ForEach(this.busstops, (item: LineDetailBusstop, index) => {
                this.renderStationInfo(item, index);
              }, (v: LineDetailBusstop) => v.id)

              this.renderLastStationInfo();
            }
            .margin({
              top: 10,
              left: 12,
              right: 12
            })
            .alignItems(VerticalAlign.Top)
          }
          .alignItems(HorizontalAlign.Start)
        }
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)
    }
    .width(LineCommonConstants.FULL_PERCENT)
    .margin({
      top: 24
    })
  }

  @Builder
  renderStationIndicator(index: number) {
    if (index === 0) {
      Stack() {
        Row()
          .backgroundColor('#0A59F7')
          .height(8)
          .width(66)
          .borderRadius({ topLeft: 6, bottomLeft: 6 })
        if (index === this.currentStop.stopOffsetIndex) {
          Image($r('app.media.nearest_stop'))
            .height(20)
            .width(20)
        } else {
          Image($r('app.media.line_start'))
            .height(20)
            .width(20)
        }
      }
      .alignContent(Alignment.Start)
    } else if (index < this.busstops.length - 2) {
      Stack() {
        Row()
          .backgroundColor('#0A59F7')
          .height(8)
          .width(56)
        if (index === this.currentStop.stopOffsetIndex) {
          Image($r('app.media.nearest_stop'))
            .height(20)
            .width(20)
            .offset({ x: -10 })
        } else {
          Image($r('app.media.line_arrow'))
            .height(8)
            .width(4)
            .offset({ x: -2 })
        }
      }
      .alignContent(Alignment.Start)
    }
  }

  @Builder
  renderLastStationIndicator() {
    Stack() {
      Row()
        .backgroundColor('#0A59F7')
        .height(8)
        .width(66)
        .borderRadius({ topRight: 6, bottomRight: 6 })
      if (this.busstops.length - 2 === this.currentStop.stopOffsetIndex) {
        Image($r('app.media.nearest_stop'))
          .height(20)
          .width(20)
          .offset({ x: -10 })
      } else {
        Image($r('app.media.line_arrow'))
          .height(8)
          .width(4)
          .offset({ x: -2 })
      }
      if (this.busstops.length - 1 === this.currentStop.stopOffsetIndex) {
        Image($r('app.media.nearest_stop'))
          .height(20)
          .width(20)
          .offset({ x: 46 })
      } else {
        Image($r('app.media.line_end'))
          .height(20)
          .width(20)
          .offset({ x: 46 })
      }
    }
    .alignContent(Alignment.Start)
  }

  @Builder
  renderStationInfo(item: LineDetailBusstop, index: number) {
    if (index === 0) {
      Row() {
        if (index === this.currentStop.stopOffsetIndex) {
          Text(item.name)
            .fontColor('#0A59F7')
            .width(16)
            .fontSize(16)
            .offset({ x: 2 })
        } else {
          Text(item.name)
            .fontColor('#cc000000')
            .fontSize(12)
            .offset({ x: 4 })
            .width(12)
        }
        Column() {
          ForEach(item.transferLines, (transferLine: TransferDetailLine) => {
            Column() {
              Text(transferLine.name)
                .fontColor('#FFFFFF')
                .fontSize(10)
                .textAlign(TextAlign.Center)
                .width('100%')
            }
            .width(18)
            .backgroundColor(transferLine.color)
            .padding({
              right: 3,
              top: 4,
              left: 3,
              bottom: 4
            })
            .margin({ top: 4 })
            .borderRadius(9)
            .alignItems(HorizontalAlign.Center)
          }, (v: TransferDetailLine) => v.name)
        }.margin({ top: 10, left: 10 })
      }.width(66)
      .alignItems(VerticalAlign.Top)
    } else if (index < this.busstops.length - 2) {
      Row() {
        if (index === this.currentStop.stopOffsetIndex) {
          Text(item.name)
            .offset({ x: -8 })
            .fontColor('#0A59F7')
            .width(16)
            .fontSize(16)
        } else {
          Text(item.name)
            .fontColor('#cc000000')
            .offset({ x: -6 })
            .width(12)
            .fontSize(12)
        }
        Column() {
          ForEach(item.transferLines, (transferLine: TransferDetailLine) => {
            Column() {
              Text(transferLine.name)
                .fontSize(10)
                .fontColor('#FFFFFF')
                .width('100%')
                .textAlign(TextAlign.Center)
            }
            .width(18)
            .backgroundColor(transferLine.color)
            .padding({
              right: 3,
              bottom: 4,
              left: 3,
              top: 4
            })
            .borderRadius(9)
            .alignItems(HorizontalAlign.Center)
            .margin({ top: 4 })
          }, (v: TransferDetailLine) => v.name)
        }.margin({ top: 10 })
      }.width(56)
      .alignItems(VerticalAlign.Top)
    }
  }

  @Builder
  renderLastStationInfo() {
    Row() {
      if (this.busstops.length - 2 === this.currentStop.stopOffsetIndex) {
        Text(this.busstops[this.busstops.length - 2].name)
          .fontColor('#0A59F7')
          .width(16)
          .fontSize(16)
          .offset({ x: -8 })
      } else {
        Text(this.busstops[this.busstops.length - 2].name)
          .fontColor('#cc000000')
          .width(12)
          .fontSize(12)
          .offset({ x: -6 })
      }
      Column() {
        ForEach(this.busstops[this.busstops.length - 2].transferLines, (transferLine: TransferDetailLine) => {
          Column() {
            Text(transferLine.name)
              .fontColor('#FFFFFF')
              .width(12)
              .fontSize(10)
          }
          .width(18)
          .backgroundColor(transferLine.color)
          .padding({
            right: 3,
            left: 3,
            top: 4,
            bottom: 4
          })
          .margin({ top: 4 })
          .borderRadius(9)
          .alignItems(HorizontalAlign.Center)
        }, (v: TransferDetailLine) => v.name)
      }.margin({ top: 10 })

      Column() {
        if (this.busstops.length - 1 === this.currentStop.stopOffsetIndex) {
          Text(this.busstops[this.busstops.length - 1].name)
            .width(16)
            .fontColor('#0A59F7')
            .fontSize(16)
            .offset({ x: -2 })
        } else {
          Text(this.busstops[this.busstops.length - 1].name)
            .fontSize(12)
            .width(12)
            .fontColor('#cc000000')
            .offset({ x: -4 })
        }
        Column() {
          ForEach(this.busstops[this.busstops.length - 1].transferLines,
            (transferLine: TransferDetailLine) => {
              Column() {
                Text(transferLine.name)
                  .fontSize(10)
                  .fontColor('#FFFFFF')
                  .width(12)
              }
              .width(18)
              .backgroundColor(transferLine.color)
              .padding({
                left: 3,
                top: 4,
                right: 3,
                bottom: 4
              })
              .borderRadius(9)
              .alignItems(HorizontalAlign.Center)
              .margin({ top: 4 })
            }, (v: TransferDetailLine) => v.name)
        }
        .margin({ top: 10 })
        .offset({ x: -4 })
      }
    }
    .width(66)
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    Scroll() {
      Column() {
        Row() {
          Text('站点: ')
            .lineHeight(19)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#e6000000')
          Text(this.currentStop.name)
            .fontWeight(FontWeight.Bold)
            .fontSize(16)
            .fontColor('#0A59F7')
            .lineHeight(19)
        }
        .margin({
          top: 12,
          left: 12,
          bottom: 12,
          right: 12
        })
        .height(22)

        this.subwayCarState()

        this.buslineSlider()

      }
      .width(LineCommonConstants.FULL_PERCENT)
      .constraintSize({ minHeight: 300 })
      .backgroundColor($r('app.color.widget_background'))
      .padding({
        top: 12,
      })
      .borderRadius(16)
      .alignItems(HorizontalAlign.Start)
    }
    .scrollBar(BarState.Off)
    .height(300)
  }
}