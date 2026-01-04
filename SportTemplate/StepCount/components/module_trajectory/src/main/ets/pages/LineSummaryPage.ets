import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { TrajectoryCommonConstants } from '../constants/TrajectoryCommonConstants';
import { MonthItemModel } from '../model/SportModel';
import { myRouteList, otherRouteList, routeItem, } from './LineSummaryComponents';
import { hilog } from '@kit.PerformanceAnalysisKit';

@ComponentV2
export struct LineSummaryPage {
  @Local myRoute: boolean = true
  @Event onPopCallBack: (value: PopInfo) => void
  @Event deleteSportData: (deleteItem: MonthItemModel[]) => void
  permissions: Permissions[] = ['ohos.permission.ACTIVITY_MOTION',
    'ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION']

  async aboutToAppear(): Promise<void> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(this.getUIContext().getHostContext() as common.UIAbilityContext,
      this.permissions)
      .then(() => {
        try {
          emitter.emit('checkPermissionEvent')
        } catch (error) {
          hilog.error(0x0000, 'LineSummaryPage', 'emitter emit checkPermissionEvent error');
        }
      }).catch((err: BusinessError) => {
      hilog.info(0x0000, 'LineSummaryPage', 'aboutToAppear requestPermissionsFromUser error');
    });
  }

  build() {
    Column() {
      routeItem({
        routeSelect: this.myRoute,
        routeChange: (type: boolean) => {
          this.myRoute = type
        }
      })
      if (this.myRoute) {
        myRouteList({
          onPopCallBack: (value: PopInfo) => {
            this.onPopCallBack(value)
          },
          deleteSportData: (deleteItem: MonthItemModel[]) => {
            this.deleteSportData(deleteItem)
          }
        })
          .margin({ top: 10 })
          .layoutWeight(1)
      } else {
        otherRouteList({
          onPopCallBack: (value: PopInfo) => {
            this.onPopCallBack(value)
          }
        })
          .margin({ top: 10 })
          .layoutWeight(1)
      }
    }
    .height(TrajectoryCommonConstants.FULL_PERCENT)
    .width(TrajectoryCommonConstants.FULL_PERCENT)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}