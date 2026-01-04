import { emitter } from '@kit.BasicServicesKit';
import { RouterMap, RouterUtils } from 'lib_common';
import { SportServiceApi } from 'lib_sport_api';
import { NavHeaderBar } from 'lib_widget';
import { LineSummaryPage, SaveRouteData } from 'module_trajectory';
import { Logger } from 'ui_base';
import { MonthItemModel } from '../model/SportOverviewModel';

@Builder
export function MyRouteMapBuilder() {
  MyRouteMap()
}

@ComponentV2
struct MyRouteMap {
  @Provider() stack: NavPathStack = new NavPathStack();
  @Provider() currentTypeTransmit: MonthItemModel[] = []
  @Provider() allCurrentTypeTransmit: MonthItemModel[] = []

  aboutToAppear() {
    let param: ESObject = RouterUtils.getParamByName(RouterMap.Route_Map_PAGE) as ESObject
    this.currentTypeTransmit = param.singleData
    this.currentTypeTransmit = this.currentTypeTransmit.concat(SaveRouteData)
    this.allCurrentTypeTransmit = param.allData
  }

  build() {
    NavDestination() {
      Column() {

        NavHeaderBar({
          title: '路线',
        })
        LineSummaryPage({
          onPopCallBack: (value: PopInfo) => {
            this.stack.pop(value)
          },
          deleteSportData: (deleteItem: MonthItemModel[]) => {
            SportServiceApi.updateSportRecord(deleteItem)
            try {
              emitter.emit('updateRecord')
            } catch (error) {
              Logger.info('MyRouteMap', 'windowStageEvent on error');
            }
          }
        }).layoutWeight(1)
      }
      .width('100%')
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((context) => {
      this.stack = context.pathStack;
    })
  }
}
