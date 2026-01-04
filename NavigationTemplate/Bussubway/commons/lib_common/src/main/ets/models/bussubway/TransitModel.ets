/**
 * 线路规划模型
 */
export class TransitModel {
  // 返回的规划方案列表
  route?: TransitRoute
}

/**
 * 规划方案
 */
export class TransitRoute {
  // 起点经纬度
  origin?: string
  // 终点经纬度
  destination?: string
  // 公交方案列表
  transits?: TransitRouteTransit[]
}

/**
 * 公交方案
 */
export class TransitRouteTransit {
  // 本条路线的总距离，单位：米
  distance?: string
  cost?: TransitRouteCost
  // 路线分段
  segments?: TransitRouteTransitSegment[]
}

/**
 * 花费时间
 */
export class TransitRouteCost {
  duration?: string
  transitFee?: string
}


/**
 * 路线分段
 */
export class TransitRouteTransitSegment {
  // 此分段中需要步行导航的信息
  walking?: TransitRouteTransitSegmentWork
  bus?: TransitRouteTransitSegmentBus
  taxi?: TransitRouteTransitSegmentTaxi
}

/**
 * 步行导航的信息
 */
export class TransitRouteTransitSegmentWork {
  // 起点坐标
  origin?: string
  // 终点坐标
  destination?: string
  // 每段线路步行距离
  distance?: number
  // 每段线路步行时间
  cost?: TransitRouteCost
  // 步行路段列表
  steps?: TransitRouteTransitSegmentWorkStep[]
}

export class TransitRouteTransitSegmentWorkStep {
  // 步行导航信息
  instruction?: string
  // 步行导航距离
  distance?: number
  // 步行路名
  road?: number
  // 步行导航经纬度
  polyline?: TransitRoutePolyline
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
  type?: string
  distance?: number
  cost?: TransitRouteCost
  polyline?: TransitRoutePolyline
  viaStops?: TransitRouteTransitSegmentBusBuslineViaStop[]
  // 末站
  endStop?: string
  // 颜色
  uicolor?: string
  // 起步价
  basicPrice?: string
  // 全程票价
  totalPrice?: string
}

/**
 * 此段起乘站信息
 */
export class TransitRouteTransitSegmentBusBuslineViaStop {
  name?: string
  id?: string
  location?: string
}

/**
 * 此段起乘站信息
 */
export class TransitRouteTransitSegmentBusBuslineDepartureStop {
  name?: string
  id?: string
  location?: string
  entrance?: string
}

/**
 * 乘站信息出入口
 */
export class TransitRouteTransitSegmentBusBuslineDepartureStopEntrance {
  name?: string
  location?: string
}

/**
 * 此段下车站
 */
export class TransitRouteTransitSegmentBusBuslineArrivalStop {
  name?: string
  id?: string
  location?: string
  entrance?: string
}

/**
 * 下车站出入口
 */
export class TransitRouteTransitSegmentBusBuslineArrivalStopEntrance {
  name?: string
  location?: string
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
  polyline?: TransitRoutePolyline
  startpoint?: string
  endpoint?: string
}