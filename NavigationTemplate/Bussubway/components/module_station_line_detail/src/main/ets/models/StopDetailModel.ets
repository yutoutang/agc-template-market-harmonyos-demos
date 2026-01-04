import { LineDetailModel } from '../line/models/LineDetailModel'
/**
 * 站点详情模型
 */
@ObservedV2
export class StopDetailModel {
  // 站点ID
  @Trace siteId?: string
  // 站点名称
  @Trace name?: string
  // 站点地址
  @Trace address?: string
  // 距离（米）
  @Trace distance?: number
  // 同名站台数量
  @Trace sameNameCount?: number
  // 是否已收藏
  @Trace isFavorited?: boolean
  // 站点经纬度
  @Trace latitude?: number
  @Trace longitude?: number
  // 经过的公交线路列表
  @Trace busLines?: LineDetailModel[]
  // 经过的地铁线路列表
  @Trace subwayLines?: SubwayLineInfo[]
  // 站点类型
  @Trace stopType?: string
}

/**
 * 公交线路信息
 */
@ObservedV2
export class BusLineInfo {
  @Trace id?: string
  // 线路名称
  @Trace lineName?: string
  // 线路编号
  @Trace lineNumber?: string
  // 开往方向
  @Trace destination?: string
  // 距离站数
  @Trace stationCount?: number
  // 预计时间（分钟）
  @Trace estimatedTime?: number
  // 预计到站时间
  @Trace arrivalTime?: string
  // 线路颜色
  @Trace lineColor?: string
}

/**
 * 地铁线路信息
 */
@ObservedV2
export class SubwayLineInfo {
  // 线路名称
  @Trace lineName?: string
  // 线路编号
  @Trace lineNumber?: string
  // 线路颜色
  @Trace lineColor?: string
  // 双向信息
  @Trace directions: LineDetailModel[] = []
}

/**
 * 地铁方向信息
 */
@ObservedV2
export class SubwayDirection {
  @Trace id?: string
  // 开往方向
  @Trace destination?: string
  // 首班车时间
  @Trace firstTrainTime?: string
  // 末班车时间
  @Trace lastTrainTime?: string
  // 发车间隔（分钟）
  @Trace interval?: string
}

/**
 * 站台线路集合（用于按坐标映射同名站台线路）
 */
@ObservedV2
export class StopLinesBundle {
  @Trace busLines: BusLineInfo[] = []
  @Trace subwayLines: SubwayLineInfo[] = []
}