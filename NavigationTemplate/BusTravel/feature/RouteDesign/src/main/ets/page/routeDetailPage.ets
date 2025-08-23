import { mapCommon } from '@kit.MapKit'
import { BreakpointConstants, getDataFromJSON, RouteEntryVM, RouterModule } from 'common'
import { BusFromCurrent, BusLineInfo, LineSet, RouteDetail, SearchSet } from 'route_detail'
import { RandomCountdown } from '../components/RandomCountdown'
import { RouterDetailParam } from '../viewmodels/RouterParams'


@Builder
export function RouteDetailPageBuilder() {
  RouteDetailPage()
}

@ComponentV2
export struct RouteDetailPage {
  vm: RouteEntryVM = RouteEntryVM.instance
  // 站线名 起点站 终点站 经纬度 站点名 seq
  @Local busSetItems: Array<SearchSet> = []
  // 线路名 起点站 终点站 经纬度 orders
  @Local lineSetItems: Array<LineSet> = []
  @Local currentEveryStation: Array<SearchSet> = [] // 当前站点
  @Local currentEveryLine: Array<LineSet> = [] // 当前路线
  @Local busTimer: RandomCountdown = new RandomCountdown()
  @Local line: Array<string> = []
  // 线路，经纬度数组，用于在地图上绘制线路
  @Local lineDots: mapCommon.LatLng[] = []
  // 站点列表信息，用于地图站点绘制
  @Local stationLocation: SearchSet[] = []
  // 站线名
  @Local longLineName: string = ''
  // 公交信息，用于公交信息卡片展示
  @Local busLineInfo: BusLineInfo = new BusLineInfo(this.longLineName, '下行', '6：00', '22：00', 2, 3, this.line, [])
  @Local currentBreakpoint: string = BreakpointConstants.BREAKPOINT_MD
  // 地图上当前公交具体位置
  @Local busLocation: mapCommon.LatLng[] =
    [{ longitude: 116.4585837, latitude: 39.9072769 }, { longitude: 116.4397, latitude: 39.90719247 }]
  @Local nearToMe: number = 0
  @Local busIndex: number[] = [1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9]

  initDataSource() {
    this.busSetItems = getDataFromJSON<SearchSet>('Bus_Station.json', this)
    this.lineSetItems = getDataFromJSON<LineSet>('Bus_Line.json', this)
  }

  // 根据线路名找出当前路线的所有的站点名
  getCurrentEveryStation() {
    for (let i = 0; i < this.busSetItems.length; i++) {
      if (this.busSetItems[i].lineName === this.longLineName) {
        this.currentEveryStation.push(this.busSetItems[i])
        this.line.push(this.busSetItems[i].stationName)
        this.stationLocation.push(this.busSetItems[i])
        if (this.busSetItems[i].stationName === this.busSetItems[i].endStation) {
          break
        }
      }
    }
  }

  aboutToAppear(): void {

    let params = RouterModule.stack.getParamByName('RouteDetailPage') as Array<RouterDetailParam>
    this.longLineName = params[params.length-1].lineName
    this.busLineInfo.busNumber = params[params.length-1].lineName
    this.busTimer = params[params.length-1].busTimer

    this.busLineInfo.nearestThreeBuses[0] =
      new BusFromCurrent(this.busTimer.nearestFirstStation, this.busTimer.nearestFirstDis,
        this.busTimer.nearestFirstMin)
    this.busLineInfo.nearestThreeBuses[1] =
      new BusFromCurrent(this.busTimer.nearestSecondStation, this.busTimer.nearestSecondDis,
        this.busTimer.nearestSecondMin)
    this.busLineInfo.nearestThreeBuses[2] =
      new BusFromCurrent(this.busTimer.nearestThirdStation, this.busTimer.nearestThirdDis,
        this.busTimer.nearestThirdMin)

    this.initDataSource()
    this.getCurrentEveryStation()
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        RouteDetail({
          stationLocation: this.stationLocation,
          busLocation: this.busLocation,
          busLineInfo: this.busLineInfo,
          nearToMe: this.nearToMe,
          busIndex: this.busIndex
        })
        Image($r('app.media.icon_back'))
          .width(45)
          .height(45)
          .margin({ left: 12, top: 12 })
          .onClick(() => {
            this.vm.pop()
          })
      }
    }
    .hideTitleBar(true)
  }
}