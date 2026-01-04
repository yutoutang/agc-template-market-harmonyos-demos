import { StopDetailModel } from '../models/StopDetailModel'
import { StopCommonConstants } from '../common/StopCommonConstants'
import { StopDetailPanel } from '../components/StopDetailPanel'
import { SameStopDetailModel } from '../models/SameStopDetailModel'
import { StopNavigation } from '../models/StopNavigation'
import { LineDetailModel } from '../line/models/LineDetailModel'
import { BusSubwaySetting } from '../line/models/BusSubwaySetting'

@ComponentV2
export struct StopDetailView {
  @Param @Require stopDetailModel: StopDetailModel
  @Param @Require collectionStationTags?: string[]
  // 还有多少站台需要提醒
  @Param arrivalReminderStations: number = 0
  @Param sameStopDetailModel: SameStopDetailModel = new SameStopDetailModel()
  @Event onNavigate: (stopNavigation: StopNavigation) => void
  @Event collectStation: (tag: string) => void
  @Event routeLineDetailPage: (lineDetailModel: LineDetailModel) => void
  @Event onFavoriteClick?: () => void // 收藏按钮点击事件
  @Param setting: BusSubwaySetting = new BusSubwaySetting();

  build() {
    Stack() {

      // 底部详情面板
      StopDetailPanel({
        stopDetailModel: this.stopDetailModel,
        arrivalReminderStations: this.arrivalReminderStations,
        setting: this.setting,
        routeLineDetailPage: this.routeLineDetailPage,
        sameStopDetailModel: this.sameStopDetailModel,
        onNavigate: this.onNavigate,
        onFavoriteClick: () => {
          if (this.onFavoriteClick) {
            this.onFavoriteClick()
          }
        }
      })

    }
    .width(StopCommonConstants.FULL_PERCENT)
    .height(StopCommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.index_background'))
  }
}


