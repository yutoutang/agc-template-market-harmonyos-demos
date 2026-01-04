import { LineDetailModel } from './LineDetailModel';

/**
 * 当前线路详情（用户首页定时任务刷新到站公交数据）
 */
@ObservedV2
export class CurrentLineDetailModel {
  // 线路名称
  @Trace lineDetailList: LineDetailModel[] = []
}