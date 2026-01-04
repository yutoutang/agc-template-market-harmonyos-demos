import { LineDetailModel } from '../line/models/LineDetailModel'

/**
 * 站点模型
 */
@ObservedV2
export class SameStopDetailModel {
  // 站点ID
  siteId?: string
  // 站点名称
  name?: string
  // 站点地址
  address?: string
  // 距离（米）
  distance?: number
  // 是否已收藏
  isFavorited?: boolean
  // 站点经纬度
  latitude?: number
  longitude?: number
  // 主站台ID, 放在外部便于主站点切换
  @Trace mainStopId?: string
  // 同站点详情
  @Trace sameStopDetails: SameStopDetail[] = []
}

@ObservedV2
export class SameStopDetail {
  // 站点ID
  id?: string
  // 站点经纬度
  latitude?: number
  longitude?: number
  lineDetailModels: LineDetailModel[] = []
}

