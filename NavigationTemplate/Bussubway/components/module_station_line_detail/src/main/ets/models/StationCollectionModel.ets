import { Type } from '@kit.ArkUI'
import { StopDetailModel } from './StopDetailModel'

/**
 * 站点收藏内部模型（按标签分组）
 */
@ObservedV2
export class StationCollectionInnerModel {
  // 标签名称
  @Trace tag?: string
  // 该标签下的站点列表
  @Type(StopDetailModel)
  @Trace stopDetailList: StopDetailModel[] = []
}

/**
 * 站点收藏模型
 */
@ObservedV2
export class StationCollectionModel {
  // 按标签分组的站点收藏列表
  @Type(StationCollectionInnerModel)
  @Trace stationCollectionInnerModels: StationCollectionInnerModel[] = []
}
