@ComponentV2
@Preview
export struct busLine {
  @Param busLineInfo: BusLineInfo = new BusLineInfo()
  @Local messageHeight: number = 48
  @Local messageBottom: number = 12
  @Local messageView: Visibility = Visibility.Visible

  aboutToAppear(): void {
  }

  build() {
    Column() {
      Column() {
        Text() {
          Span(this.busLineInfo.busNumber)
            .fontSize(18)
          Span('   ')
          Span(this.busLineInfo.direction)
            .fontSize(10)
            .fontColor('#707070')
        }
        .margin({ bottom: '8vp' })

        Row() {
          Text() {
            Span(this.busLineInfo.lineStartStop)
              .fontColor('#9A9A9A')
          }
          .fontSize(10)
          .margin({ right: '12vp' })

          Image($r('app.media.reverse'))
            .width('10.94vp')
            .height('9.25vp')
            .margin({ right: '12vp' })

          Text() {
            Span(this.busLineInfo.lineEndStop)
              .fontColor('#9A9A9A')
          }
          .fontSize(10)
        }
        .margin({ bottom: '8vp' })

        Row() {
          Text() {
            Span('首班车：')
            Span(this.busLineInfo.lineFirstTime)
            Span('  ')
            Span('末班车：')
            Span(this.busLineInfo.lineEndTime)
          }
          .fontSize(10)
          .fontColor('#9A9A9A')

          Text() {
            Span('票价：')
            Span(this.busLineInfo.price.toString())
            Span('元')
          }
          .fontSize(10)
          .fontColor('#9A9A9A')
        }
        .width('286vp')
        .justifyContent(FlexAlign.SpaceBetween)

      }
      .height('92vp')
      .width('90%')
      .borderRadius('10vp')
      .margin({ bottom: '12vp' })
      .padding({ top: '10vp', left: '16vp' })
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .alignItems(HorizontalAlign.Start)

      if (this.busLineInfo.nearestThreeBuses.length && this.busLineInfo.nearestThreeBuses[0].remainMinute < 2) {
        Row() {
          Row() {
            Image($r('app.media.icon_messageing'))
              .height(32)
              .width(32)
              .margin({ left: 12, right: 14 })
            Text() {
              Span(this.busLineInfo.busNumber)
              Span('公交即将抵达！')
            }
            .fontSize(12)
          }

          Image($r('app.media.icon_close'))
            .height(12)
            .width(12)
            .onClick(() => {
              this.messageView = Visibility.Hidden
              this.messageHeight = 0
              this.messageBottom = 0
            })
            .margin({ right: 6, top: -16 })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('90%')
        .height(this.messageHeight)
        .borderRadius(10)
        .backgroundColor($r('app.color.background_color_white'))
        .margin({ bottom: this.messageBottom })
        .visibility(this.messageView)
      }

      Row() {
        Image($r('app.media.bus'))
          .height('32vp')
          .width('32vp')
          .margin({ left: '24vp', right: '24vp' })
        ForEach(this.busLineInfo.nearestThreeBuses, (item: BusFromCurrent) => {
          Column() {
            Row() {
              Text() {
                Span(item.remainStop.toString())
                  .fontSize('24vp')
                  .fontColor('#62B42E')
                Span('站')
                  .fontSize('12vp')
                  .fontColor('#62B42E')
              }

              Image($r('app.media.signal'))
                .size({ height: '16vp', width: '16vp' })
            }
            .alignItems(VerticalAlign.Top)

            Text(`约${item.remainDistance}KM`)
              .fontSize('8vp')

            Text(`大约${item.remainMinute}分钟`)
              .fontSize('8vp')
          }
          .height('64vp')
          .width('64vp')
          .margin({ right: '16vp' })
          .justifyContent(FlexAlign.Center)
        }, (item: BusFromCurrent) => item.remainStop.toString())
      }
      .height('92vp')
      .width('90%')
      .borderRadius('10vp')
      .margin({ bottom: '12vp' })
      .backgroundColor($r('sys.color.comp_background_list_card'))
    }
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#62B42E')
  }
}

@ObservedV2
export class BusLineInfo {
  private _busNumber: string = ''

  public set busNumber(value: string) {
    this._busNumber = value
  }

  public get busNumber(): string {
    return this._busNumber
  }

  private _direction: string = ''

  public set direction(value: string) {
    this._direction = value
  }

  public get direction(): string {
    return this._direction
  }

  private _lineEndTime: string = ''

  public set lineEndTime(value: string) {
    this._lineEndTime = value
  }

  public get lineEndTime(): string {
    return this._lineEndTime
  }

  private _lineFirstTime: string = ''

  public set lineFirstTime(value: string) {
    this._lineFirstTime = value
  }

  public get lineFirstTime(): string {
    return this._lineFirstTime
  }

  private _price: number = 0

  public set price(value: number) {
    this._price = value
  }

  public get price(): number {
    return this._price
  }

  private _currentStation: number = 0

  public set currentStation(value: number) {
    this._currentStation = value
  }

  public get currentStation(): number {
    return this._currentStation
  }

  private _line: Array<string> = []

  public set line(value: Array<string>) {
    this._line = value
  }

  public get line(): Array<string> {
    return this._line
  }

  private _lineEndStop: string = this.line[this.line.length-1]
  private _lineStartStop: string = this.line[0]

  public get lineEndStop(): string {
    return this.line[this.line.length-1]
  }

  public get lineStartStop(): string {
    return this.line[0]
  }

  private _lastThreeBuses: Array<BusFromCurrent> = []

  // 设置value值 设置最近三辆公交车的值
  public set nearestThreeBuses(value: Array<BusFromCurrent>) {
    this._lastThreeBuses = value
  }

  // 获取value值 获取最近三辆公交车的值
  public get nearestThreeBuses(): Array<BusFromCurrent> {
    return this._lastThreeBuses
  }

  constructor(busNumber: string = '', direction: string = '', lineFirstTime: string = '', lineEndTime: string = '',
    price: number = 0,
    currentStation: number = 0, line: Array<string> = [], nearestThreeBuses: Array<BusFromCurrent> = []) {
    this._busNumber = busNumber // 车次
    this._direction = direction // 行车方向
    this._lineFirstTime = lineFirstTime // 首班车
    this._lineEndTime = lineEndTime // 末班车
    this._price = price // 票价
    this._currentStation = currentStation // 当前站点
    this._line = line // 具体路线
    this._lastThreeBuses = nearestThreeBuses.slice(0,3) // 距离最近的三辆车
    this._lineEndStop = line[line.length - 1]
    this._lineStartStop = line[0]
  }
}

export class BusFromCurrent {
  public remainStop: number
  public remainDistance: number
  public remainMinute: number

  constructor(remainStop: number = 0, remainDistance: number = 0, remainMinute: number = 0) {
    this.remainStop = remainStop
    this.remainDistance = remainDistance
    this.remainMinute = remainMinute
  }
}