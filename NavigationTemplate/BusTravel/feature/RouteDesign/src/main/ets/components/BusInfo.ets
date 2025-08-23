import { getDataFromJSON } from 'common'
import { SearchSet } from 'route_detail'
import { RandomCountdown } from './RandomCountdown'
import { generateRandomNumber } from './BusStationRandom'

@ComponentV2
@Preview
export struct RealTimeBusComponent {
  @Param @Require busTimer: RandomCountdown
  @Param busInfo: LineSetInfo = new LineSetInfo('', '', '', 116.490437, 39.90536209, 0);
  @Local lineName: string = '';
  @Local busStationRandom: Array<string> = ['北京南站'];
  @Local randomBus: number = 0;
  @Local randomBusStopDistance: number = generateRandomNumber(0, 300);
  @Local countdownSecond: number = 0;
  @Local endDir: string = '';
  // 站线名 起点站 终点站 经纬度 站点名 seq
  @Local busSetItems: Array<SearchSet> = [];

  aboutToAppear(): void {
    this.endDir = this.busInfo.endStation
    this.busSetItems = getDataFromJSON<SearchSet>('Bus_Station.json', this);
    this.lineName = this.busInfo.lineName
  }

  build() {
    Row() {
      Column() {
        Row() {
          Image($r('app.media.ic_buslogo'))
            .height('24lpx')
            .width('24lpx')
            .margin({ right: '12lpx' })

          Text(this.busStationRandom[this.randomBus])
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#e6000000')
        }

        Divider()
          .margin({ top: 9, bottom: 7 })
          .strokeWidth('1px').color($r('sys.color.ohos_id_color_list_separator'))

        Row() {
          Text() {
            Span(this.busInfo.lineName)
          }
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
          .margin({ right: 4 })

          Text() {
            Span('开往 ')
            Span(this.endDir)
              .fontColor('#62B42E')
            Span(' 方向')
          }
          .height('24lpx')
          .width('153lpx')
          .fontSize(12)
        }
        .margin({ bottom: 5 })

        Row() {
          Image($r('app.media.location'))
            .size({ height: '16lpx', width: '16lpx' })
            .margin({ right: '2lpx' })

          Text(this.busStationRandom[this.randomBus])
            .fontSize(10)
            .fontWeight(FontWeight.Regular)

          Image($r('app.media.divider'))
            .size({ height: '16lpx', width: '2lpx' })
            .margin({ left: 6, right: 6 })
          Image($r('app.media.walking'))
            .size({ height: '16lpx', width: '16lpx' })

          Text() {
            Span('约')
            Span(this.randomBusStopDistance.toString())
            Span('米')
          }
          .fontSize(10)
        }
      }
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(12)
      .width('234lpx')
      .height('110lpx')
      .padding(12)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)

      Column() {
        Row() {
          Row() {
          }
          .width(16)
          .height(16)

          Image($r('app.media.signal'))
            .size({ height: '16lpx', width: '16lpx' })
        }
        .justifyContent(FlexAlign.SpaceAround)

        Row() {
          Text() {
            Span(`${this.busTimer.nearestFirstStation}`)
              .fontSize(18)
              .fontColor('#62B42E')
              .fontWeight(FontWeight.Medium)
            Span('站')
              .fontSize(18)
              .fontColor('#62B42E')
              .fontWeight(FontWeight.Medium)
          }
        }

        Text() {
          Span('约')
          Span(`${this.busTimer.nearestFirstMin}`)
          Span('分钟')
        }
        .fontSize('12fp')
        .fontWeight(FontWeight.Regular)
        .margin({ top: 4 })
      }
      .width('80lpx')
      .height('110lpx')
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(12)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .width('321lpx')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

@ObservedV2
export class LineSetInfo {
  private _lineName: string = ''

  public set lineName(value: string) {
    this._lineName = value
  }

  public get lineName(): string {
    return this._lineName
  }

  private _startStation: string = ''

  public set startStation(value: string) {
    this._startStation = value
  }

  public get startStation(): string {
    return this._startStation
  }

  private _endStation: string = ''

  public set endStation(value: string) {
    this._endStation = value
  }

  public get endStation(): string {
    return this._endStation
  }

  private _lon: number = 0

  public set lon(value: number) {
    this._lon = value
  }

  public get lon(): number {
    return this._lon
  }

  private _lat: number = 0

  public set lat(value: number) {
    this._lat = value
  }

  public get lat(): number {
    return this._lat
  }

  private _orders: number = 0;

  public set orders(value: number) {
    this._orders = value;
  }

  public get orders(): number {
    return this._orders;
  }

  constructor(lineName: string, startStation: string, endStation: string, lon: number, lat: number, orders: number) {
    this._lineName = lineName;
    this._startStation = startStation;
    this._endStation = endStation;
    this._lon = lon;
    this._lat = lat;
    this._orders = orders;
  }
}