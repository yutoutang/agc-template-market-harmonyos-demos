import { SymbolGlyphModifier } from '@kit.ArkUI'
import { getDataFromJSON, RouteEntryVM } from 'common'
import { LineSet, SearchSet } from 'route_detail'
import { LineSetInfo, RealTimeBusComponent } from '../components/BusInfo'
import { RandomCountdown } from '../components/RandomCountdown'
import { RouterDetailParam } from '../viewmodels/RouterParams'

@Builder
export function RealTimeBusBuilder() {
  RealTimeBus()
}

@ComponentV2
export struct RealTimeBus {
  vm: RouteEntryVM = RouteEntryVM.instance
  // 站线名 起点站 终点站 经纬度 站点名 seq
  @Local busSetItems: Array<SearchSet> = []
  // 线路名 起点站 终点站 经纬度 orders
  @Local busInfoList: Array<LineSet> = []
  @Local busInfoListAll: Array<LineSet> = []
  @Consumer('busLineTimeList') busLineTimeList: Map<string, RandomCountdown> = new Map()
  @Local busInfoListName: Array<string> = []
  @Local busInfoListNameOri: Array<string> = []
  scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    this.initDataSource()
  }

  initDataSource() {
    this.busSetItems = getDataFromJSON<SearchSet>('Bus_Station.json', this)
    this.busInfoListAll = getDataFromJSON<LineSet>('Bus_LineName.json', this)
    this.busInfoList = getDataFromJSON<LineSet>('Bus_Linetop3.json', this)
    for (let i = 0; i < this.busInfoListAll.length; i++) {
      this.busInfoListName.push(this.busInfoListAll[i].lineName)
    }
    this.busInfoListNameOri = JSON.parse(JSON.stringify(this.busInfoListName))
    this.busInfoListAll.forEach(item => {
      let busTimer = new RandomCountdown(item.lineName)
      this.busLineTimeList.set(item.lineName, busTimer)
    })
    this.busInfoList.forEach(item => {
      let busTimer = new RandomCountdown(item.lineName)
      this.busLineTimeList.set(item.lineName, busTimer)
    })
  }

  @Local changeValueLine: string = ''
  @Local lineValueInfo: Array<LineSet> = []

  getLineValueToLineInfo(str: string) {
    this.lineValueInfo = []
    for (let i = 0; i < this.busInfoListAll.length; i++) {
      if (this.busInfoListAll[i].lineName.includes(str)) {
        this.lineValueInfo.push(this.busInfoListAll[i])
        break
      }
    }
  }

  getSearchListInfo() {
    if (this.changeValueLine) {
      // 判断用户是否输入了内容
      this.busInfoListName = this.busInfoListNameOri.filter((item, index) => {
        return item.indexOf(this.changeValueLine) !== -1
      })
    }
  }

  build() {
    NavDestination() {
      Column() {
        Stack() {
          Search({ value: this.changeValueLine, placeholder: '搜索公交线路和站点' })
            .caretStyle({ width: 1.5, color: $r('app.color.system_color_green') })
            .searchIcon(new SymbolGlyphModifier($r('sys.symbol.magnifyingglass')).fontSize('16vp'))
            .focusable(false)
            .cancelButton({ style: CancelButtonStyle.INVISIBLE })
            .margin({ left: 20, right: 20, bottom: 20 })
            .onClick(() => {
              this.vm.toSearchDetail(this.busInfoListNameOri, (popInfo: PopInfo) => {
                // 跳转SpecificContentSearch
                this.changeValueLine = `${popInfo.result}`
                this.getSearchListInfo()
              })
            })
            .onChange((value: string) => {
              if (value) {
                this.getLineValueToLineInfo(this.changeValueLine)
              } else {
                this.lineValueInfo.splice(0, this.lineValueInfo.length)
              }
            })
          if (this.changeValueLine) {
            Row() {
              Image($r('app.media.ic_close')).width(12)

            }.margin({ right: 22 }).padding(10).onClick(() => {
              this.changeValueLine = ''
            })

          }

        }
        .alignContent(Alignment.TopEnd)

        Column() {
          Text('附近站点')
            .width('90%')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .align(Alignment.TopStart)
            .margin({ bottom: 16 })
          // 根据changeValue的值判断
          if (this.lineValueInfo.length) {
            List({ space: 8 }) {
              ForEach(this.lineValueInfo, (item: LineSetInfo) => {
                RealTimeBusComponent({ busInfo: item, busTimer: this.busLineTimeList.get(item.lineName) })
                  .onClick(() => {
                    // 跳转到对应路线
                    this.vm.pushByParams('RouteDetailPage',
                      {
                        lineName: item.lineName,
                        busTimer: this.busLineTimeList.get(item.lineName)
                      } as RouterDetailParam)
                  })
              }, (item: LineSetInfo) => item.lineName)
            }
            .padding({
              bottom: '175lpx'
            })
            .alignListItem(ListItemAlign.Center)
          } else {
            List({ space: '8lpx' }) {
              ForEach(this.busInfoList, (item: LineSetInfo) => {
                RealTimeBusComponent({ busInfo: item, busTimer: this.busLineTimeList.get(item.lineName) })
                  .onClick(() => {
                    this.vm.pushByParams('RouteDetailPage',
                      {
                        lineName: item.lineName,
                        busTimer: this.busLineTimeList.get(item.lineName)
                      } as RouterDetailParam)
                  })
              }, (item: LineSetInfo) => item.lineName)
            }
            .padding({
              bottom: '175lpx'
            })
            .alignListItem(ListItemAlign.Center)
          }
        }
      }
      .backgroundColor('#F1F3F5')
      .layoutWeight(1)
    }
    .hideTitleBar(true)
  }
}