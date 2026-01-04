import { PersistenceV2 } from '@kit.ArkUI';
import { City, LineModel, RouterMap, RouterUtils, StopModel, StringUtils } from 'lib_common';
import { SearchServiceApi } from 'lib_api';
import { StopLineModelConvertUtil } from '../utils/StopLineModelConvertUtil';
import { CurrentBusstop,
  LineDetailModel,
  SubwayStopInfo,
  SubwayStopline, SubwayStoplineDetail, SubwayView } from 'module_station_line_detail';

@Builder
export function SubwayPageBuilder() {
  SubwayPage()
}

@ComponentV2
struct SubwayPage {
  currentCity: City = PersistenceV2.connect(City, () => new City())!;
  private pathStack: NavPathStack = new NavPathStack();
  private lnglat: string = '';

  build() {
    NavDestination() {
      SubwayView({
        cityName: this.currentCity.cityName,
        lnglat: this.lnglat,
        searchSubwayStopline: async (lineIds: string[]): Promise<SubwayStopline[]> => {
          const subwayStoplines: SubwayStopline[] = []
          let lineIdSearch = ''
          for (const lineId of lineIds) {
            lineIdSearch += lineId + '|'
          }
          let lineModels: LineModel[] = await SearchServiceApi.searchLineModelByIds(lineIdSearch)
          let direcVer = ''
          for (const stopline of lineModels) { //反向路线
            direcVer += stopline?.direc + '|'
          }
          let direcLineModels: LineModel[] = await SearchServiceApi.searchLineModelByIds(direcVer)
          for (let i = 0; i < lineModels.length; i++) {
            const stopline = lineModels[i]
            if (stopline !== null) {
              const subwayStopline: SubwayStopline = new SubwayStopline()
              subwayStopline.name = StringUtils.trimInBracket(stopline.name!)
              subwayStopline.uicolor = stopline.uicolor
              const subwayStoplineDetail: SubwayStoplineDetail = new SubwayStoplineDetail()
              subwayStoplineDetail.id = stopline.id
              subwayStoplineDetail.startStop = stopline.startStop
              subwayStoplineDetail.endStop = stopline.endStop
              subwayStoplineDetail.startTime = stopline.startTime
              subwayStoplineDetail.endTime = stopline.endTime
              subwayStopline.lineDetails?.push(subwayStoplineDetail)
              //反向路线
              const direcStopline = direcLineModels[i]
              const direcSubwayStoplineDetail: SubwayStoplineDetail = new SubwayStoplineDetail()
              direcSubwayStoplineDetail.id = stopline.id
              direcSubwayStoplineDetail.startStop = direcStopline.startStop
              direcSubwayStoplineDetail.endStop = direcStopline.endStop
              direcSubwayStoplineDetail.startTime = direcStopline.startTime
              direcSubwayStoplineDetail.endTime = direcStopline.endTime
              subwayStopline.lineDetails?.push(direcSubwayStoplineDetail)
              subwayStoplines.push(subwayStopline)
            }
          }
          return subwayStoplines
        },
        routeStopline: async (subwayStopInfo: SubwayStopInfo, id: string) => {
          const lineModel: LineModel | null = await SearchServiceApi.searchBuslineById(id)
          if (lineModel !== null) {
            // 转换可分可合组件内部模型
            const currentStop: CurrentBusstop = new CurrentBusstop()
            currentStop.id = subwayStopInfo.poiid
            currentStop.name = subwayStopInfo.name
            currentStop.location = subwayStopInfo.lnglat
            const lineDetailModel: LineDetailModel =
              await StopLineModelConvertUtil.genLineDetailModel(lineModel, currentStop);
            RouterUtils.pushPathByName(RouterMap.LINE_DETAIL_PAGE, lineDetailModel)
          }
        },
        onStationClick: async (stationInfo: SubwayStopInfo) => {
          // 跳转到站点详情页
          await this.navigateToStopDetail(stationInfo);
        },
        searchSubwayStopDistance: async (latlng: string) => {
          const distanceResponse = await SearchServiceApi.distanceSearch(latlng, this.lnglat)
          return distanceResponse
        },
      })
      Row() {
        Image($r('app.media.ic_back'))
          .width(40)
          .height(40)
          .aspectRatio(1)
          .margin({ top: 44, right: 16 })  // 仅保留顶部和左侧边距
          .onClick(() => {
            RouterUtils.pop()
          })
      }
      .position({ left: 16, top: 0 })
    }
    .onReady((context) => {
      this.pathStack = context.pathStack
      this.lnglat = context.pathInfo.param as string
    })
    .hideTitleBar(true)
  }

  @Builder
  blackBuilder() {

  }

  // 跳转到站点详情页
  private async navigateToStopDetail(stationInfo: SubwayStopInfo): Promise<void> {
    try {
      const stationId = stationInfo.poiid || stationInfo.id;
      if (!stationId) {
        return;
      }
      const stopModel: StopModel = await SearchServiceApi.searchBusstopById(stationId);
      const stopDetailModel = await StopLineModelConvertUtil.genStopDetailModel(stopModel);
      RouterUtils.pushPathByName(RouterMap.STOPDETAIL_PAGE, stopDetailModel);
    } catch (error) {

    }
  }
}