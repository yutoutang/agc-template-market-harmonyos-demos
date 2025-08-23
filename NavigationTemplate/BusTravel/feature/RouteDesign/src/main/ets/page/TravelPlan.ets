import { getDataFromJSON, RouteEntryVM } from 'common'
import { SearchSet } from 'route_detail'
import { RouteSearch, LineInfo } from 'route_search'
import { RandomCountdown } from '../components/RandomCountdown'
import { RouterDetailParam } from '../viewmodels/RouterParams'


@Builder
export function TravelPlanBuilder() {
  TravelPlan()
}

class LineStartEnd {
  lineName: string = ''
  startStation = ''
  endStation = ''
}

@ComponentV2
export struct TravelPlan {
  @Consumer('busLineTimeList') busLineTimeList: Map<string, RandomCountdown> = new Map()
  vm: RouteEntryVM = RouteEntryVM.instance
  @Local listInfoItem: Array<SearchSet> = []
  @Local startText: string = '' // 起点
  @Local endText: string = '' //终点
  @Local searchListInfoItem: Array<SearchSet> = [] // 传入的查询总数据
  @Local sameLines: Array<LineStartEnd> = []
  @Local stationNameList: Array<string> = [] // 传入搜索页面进行站点查询
  @Local lineInfo: LineInfo[] = []

  aboutToAppear(): void {
    this.initDataSource()
  }

  initDataSource() {
    this.listInfoItem = getDataFromJSON<SearchSet>('Bus_Station.json', this)
    for (let i = 0; i < this.listInfoItem.length; i++) {
      this.stationNameList.push(this.listInfoItem[i].stationName)
    }
  }

  getSearchListInfo() {
    if (this.startText) { // 判断用户是否输入了内容
      this.searchListInfoItem = this.listInfoItem.filter((item, index) => { // filter遍历listInfoItem
        return item.stationName.indexOf(this.startText) !== -1 // 若indexOf()返回的结果不为-1即name中包含changeValue，则保留该项
      }) // 筛选完后的值会被赋值到searchListInfoItem中
    }
  }

  // 1先找到在哪些线路
  findLine(str: string) {
    let lines: Array<SearchSet> = []
    for (let index = 0; index < this.listInfoItem.length; index++) {
      const element = this.listInfoItem[index]
      if (str === element.stationName) {
        lines.push(this.listInfoItem[index])
      }
    }
    return lines
  }

  // 2再找这两个线路中有无相同线路
  // searchSet包含 线路名 起点终点站 经纬度 站名 seq
  // class应该改包含线路名 起点终点站 startText 的经纬度 endText
  findSameLine() {
    let startLines: Array<SearchSet> = this.findLine(this.startText)
    let endLines: Array<SearchSet> = this.findLine(this.endText)
    let lines: LineInfo[] = []
    for (let i = 0; i < startLines.length; i++) {
      for (let j = 0; j < endLines.length; j++) {
        // 确定为线路名
        if (startLines[i].lineName === endLines[j].lineName &&
          startLines[i].startStation === endLines[j].startStation) {
          // 确认起始站和终点站顺序
          if (startLines[i].sequence < endLines[j].sequence) {
            lines.push(new LineInfo(startLines[i].lineName, '下行', startLines[i].startStation,
              startLines[i].endStation, '4', '10'))
          }
        }
      }
    }
    // 根据线路名去重
    if (lines !== null) {
      const uniqueLine = Array.from(
        new Map(lines.map(line => [line.lineName, line])).values()
      )
      return Array.from(uniqueLine)
    } else {
      return lines
    }
  }

  // 点击input框，跳转搜索页
  clickInput(index: number) {
    this.vm.toSearchDetail(this.stationNameList, (popInfo: PopInfo) => {
      if (index === 0) {
        this.startText = `${popInfo.result}`
      }
      if (index === 1) {
        this.endText = `${popInfo.result}`
      }
      this.getSearchListInfo()
    })
  }

  clickListItem(lineItem: LineInfo) {
    this.vm.pushByParams('RouteDetailPage',
      { lineName: lineItem.lineName, busTimer: this.busLineTimeList.get(lineItem.lineName) } as RouterDetailParam)
  }

  inputChange(value: string, index: number) {
    if (index === 0) {
      this.startText = value
    } else {
      this.endText = value
    }
    this.lineInfo = this.findSameLine()
  }

  build() {
    Column() {
      RouteSearch({
        defaultStartText: this.startText,
        defaultEndText: this.endText,
        lineInfo: this.lineInfo,
        onInputChange: (value: string, index: number) => {
          this.inputChange(value, index)
        },
        clickInput: (index: number) => {
          this.clickInput(index)
        },
        clickListItem: (lineItem: LineInfo) => {
          this.clickListItem(lineItem)
        }
      })
    }
    .width('100%')

  }
}