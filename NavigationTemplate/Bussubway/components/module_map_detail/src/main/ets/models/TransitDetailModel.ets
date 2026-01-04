/**
 * 公交站关键字响应
 */
export class TransitDetailModel {
  // 返回的规划方案列表
  route: TransitRoute = new TransitRoute()
}

/**
 * 规划方案
 */
export class TransitRoute {
  // 终点经纬度
  destination?: string
  // 起点经纬度
  origin?: string
  // 公交方案列表
  transits?: TransitRouteTransit[]
}

/**
 * 公交方案
 */
export class TransitRouteTransit {
  // 本条路线的总距离，单位：米
  distance?: string
  // 路线分段
  segments?: TransitRouteTransitSegment[]
  cost?: TransitRouteCost
}

/**
 * 花费时间
 */
export class TransitRouteCost {
  transitFee?: string
  duration?: string
}

/**
 * 路线分段
 */
export class TransitRouteTransitSegment {
  // 此分段中需要步行导航的信息
  bus?: TransitRouteTransitSegmentBus
  taxi?: TransitRouteTransitSegmentTaxi
  walking?: TransitRouteTransitSegmentWork
}

/**
 * 步行导航的信息
 */
export class TransitRouteTransitSegmentWork {
  // 起点坐标
  origin?: string
  // 每段线路步行距离
  distance?: number
  // 终点坐标
  destination?: string
  // 每段线路步行时间
  steps?: TransitRouteTransitSegmentWorkStep[]
  // 步行路段列表
  cost?: TransitRouteCost
}

export class TransitRouteTransitSegmentWorkStep {
  // 步行导航信息
  distance?: number
  // 步行导航距离
  instruction?: string
  // 步行导航时间
  polyline?: TransitRoutePolyline
  // 步行导航经纬度
  duration?: number
}

/**
 * 路线分段
 */
export class TransitRouteTransitSegmentBus {
  buslines?: TransitRouteTransitSegmentBusBusline[]
}

/**
 * 路线分段
 */
export class TransitRouteTransitSegmentBusBusline {
  // 路段列表
  departureStop?: TransitRouteTransitSegmentBusBuslineDepartureStop
  arrivalStop?: TransitRouteTransitSegmentBusBuslineArrivalStop
  name?: string
  id?: string
  // 末站
  endStop?: string
  // 颜色
  uicolor?: string
  // 起步价
  basicPrice?: string
  // 全程票价
  totalPrice?: string
  type?: string
  distance?: number
  cost?: TransitRouteCost
  polyline?: TransitRoutePolyline
  viaStops?: TransitRouteTransitSegmentBusBuslineViaStop[]
}

/**
 * 此段起乘站信息
 */
export class TransitRouteTransitSegmentBusBuslineViaStop {
  id?: string
  location?: string
  name?: string
}

/**
 * 此段起乘站信息
 */
export class TransitRouteTransitSegmentBusBuslineDepartureStop {
  id?: string
  name?: string
  entrance?: string
  location?: string
}

/**
 * 乘站信息出入口
 */
export class TransitRouteTransitSegmentBusBuslineDepartureStopEntrance {
  location?: string
  name?: string
}

/**
 * 此段下车站
 */
export class TransitRouteTransitSegmentBusBuslineArrivalStop {
  id?: string
  name?: string
  entrance?: string
  location?: string
}

/**
 * 下车站出入口
 */
export class TransitRouteTransitSegmentBusBuslineArrivalStopEntrance {
  location?: string
  name?: string
}

/**
 * 此路段坐标集
 */
export class TransitRoutePolyline {
  polyline?: string
}

/**
 * 路线分段
 */
export class TransitRouteTransitSegmentTaxi {
  distance?: number
  startpoint?: string
  polyline?: TransitRoutePolyline
  endpoint?: string
}

@ObservedV2
export class ComingBus {
  // 站数
  @Trace stations: number = 0
  // 距离
  @Trace distance?: number
  // 时间
  @Trace time?: number
  // 车牌
  @Trace numberplate?: string
}