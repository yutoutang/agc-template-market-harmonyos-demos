import { StopDetailModel } from './StopDetailModel';

/**
 * 当前站点详情（用户首页定时任务该站点下所有路线到站公交实时数据，地图点击进入站点详情需要，首页附近站点不需要）
 */
@ObservedV2
export class CurrentStopDetailModel {
  // 线路名称
  @Trace stopDetailList: StopDetailModel[] = []
}