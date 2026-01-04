
/**
 * 线路模型
 */
@ObservedV2
export class LineDetailModel {
  // 公交地铁类型
  @Trace busSubwayType?: string
  // 线路ID
  @Trace id?: string
  // 线路名称
  @Trace name?: string
  // 线路经纬度
  @Trace polyline?: string
  // 首发站
  @Trace startStop?: string
  // 末站
  @Trace endStop?: string
  // 首班车时间
  @Trace startTime?: string
  // 末班车时间
  @Trace endTime?: string
  // 反向线路 id
  @Trace direc?: string
  // 起步价
  @Trace basicPrice?: string
  // 全程票价
  @Trace totalPrice?: string
  // 发车间隔
  @Trace interval?: string
  // 颜色
  @Trace uicolor?: string
  // 途径站
  @Trace busstops?: LineDetailBusstop[]
  // 最近站点
  @Trace currentStop?: CurrentBusstop
  // 切换路线
  switchDirec?: () => void
}

/**
 * 线路站点
 */
@ObservedV2
export class LineDetailBusstop {
  // 站点ID
  @Trace id?: string
  // 公交站名
  @Trace name?: string
  // 公交站经纬度
  @Trace location?: string
  // 换乘线路名称
  @Trace transferLines?: TransferDetailLine[]
  // 拥堵状况
  @Trace congestion?: string
}

/**
 * 最近站点
 */
@ObservedV2
export class CurrentBusstop {
  // 站点ID
  @Trace id?: string
  // 公交站名
  @Trace name?: string
  // 离起始站的索引
  @Trace stopOffsetIndex?: number
  // 公交站经纬度
  @Trace location?: string
  // 快到站公交
  @Trace comingBusList: ComingBus[] = []
  // 最近地铁车厢状态
  @Trace comingSubwayCarList: SubwayCarState[] = []
}

/**
 * 快到站公交
 */
@ObservedV2
export class ComingBus {
  // 站数
  @Trace stations?: number
  // 时间
  @Trace time?: number
  // 距离
  @Trace distance?: number
  // 车牌
  @Trace numberplate?: string
  // 汽车拥堵状态
  @Trace crowdState?: string
  // 距离站点宽度
  @Trace offsetX?: number
}

/**
 * 快到站公交
 */
@ObservedV2
export class SubwayCarState {
  // 站数
  @Trace crowdState?: string
  // 时间
  @Trace tempretureState?: string
}

/**
 * 换乘线路
 */
@ObservedV2
export class TransferDetailLine {
  // 名称
  @Trace name?: string
  // 颜色
  @Trace color?: string
}