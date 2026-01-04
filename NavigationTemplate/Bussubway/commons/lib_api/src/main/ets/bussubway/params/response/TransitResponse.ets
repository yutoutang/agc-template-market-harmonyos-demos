import { BusbaseResponse } from './BusbaseResponse'

/**
 * 公交站关键字响应
 */
export interface TransitResponse extends BusbaseResponse {
  // 返回的规划方案列表
  route: TransitRouteResponse
}

/**
 * 规划方案
 */
export interface TransitRouteResponse {
  // 起点经纬度
  origin: string
  // 终点经纬度
  destination: string
  // 公交方案列表
  transits: TransitRouteTransitResponse[]
}

/**
 * 公交方案
 */
export interface TransitRouteTransitResponse {
  // 本条路线的总距离，单位：米
  distance: string
  // 预计耗时
  cost?: TransitRouteCostResponse
  // 路线分段
  segments: TransitRouteTransitSegmentResponse[]
}

/**
 * 花费时间
 */
export interface TransitRouteCostResponse {
  duration: string
  transit_fee: string
}

/**
 * 路线分段
 */
export interface TransitRouteTransitSegmentResponse {
  // 此分段中需要步行导航的信息
  walking: TransitRouteTransitSegmentWorkResponse
  bus: TransitRouteTransitSegmentBusResponse
  taxi: TransitRouteTransitSegmentTaxiResponse
}

/**
 * 步行导航的信息
 */
export interface TransitRouteTransitSegmentWorkResponse {
  // 起点坐标
  origin: string
  // 终点坐标
  destination: string
  // 每段线路步行距离
  distance: number
  // 预计耗时
  cost: TransitRouteCostResponse
  // 步行路段列表
  steps: TransitRouteTransitSegmentWorkStepResponse[]
}

export interface TransitRouteTransitSegmentWorkStepResponse {
  // 步行导航信息
  instruction: string
  // 步行导航距离
  distance: number
  // 步行导航时间
  road: number
  // 步行导航经纬度
  polyline: TransitRoutePolylineResponse
}

/**
 * 路线分段
 */
export interface TransitRouteTransitSegmentBusResponse {
  buslines: TransitRouteTransitSegmentBusBuslineResponse[]
}

/**
 * 路线分段
 */
export interface TransitRouteTransitSegmentBusBuslineResponse {
  // 路段列表
  departure_stop: TransitRouteTransitSegmentBusBuslineDepartureStopResponse
  arrival_stop: TransitRouteTransitSegmentBusBuslineArrivalStopResponse
  name: string
  id: string
  type: string
  distance: number
  // 预计耗时
  cost: TransitRouteCostResponse
  polyline: TransitRoutePolylineResponse
  via_stops: TransitRouteTransitSegmentBusBuslineViaStopResponse[]
}

/**
 * 经过站点详情
 */
export interface TransitRouteTransitSegmentBusBuslineViaStopResponse {
  name: string
  id: string
  location: string
}

/**
 * 此段起乘站信息
 */
export interface TransitRouteTransitSegmentBusBuslineDepartureStopResponse {
  name: string
  id: string
  location: string
  entrance: string
}

/**
 * 乘站信息出入口
 */
export interface TransitRouteTransitSegmentBusBuslineDepartureStopEntranceResponse {
  name: string
  location: string
}

/**
 * 此段下车站
 */
export interface TransitRouteTransitSegmentBusBuslineArrivalStopResponse {
  name: string
  id: string
  location: string
  entrance: string
}

/**
 * 下车站出入口
 */
export interface TransitRouteTransitSegmentBusBuslineArrivalStopEntranceResponse {
  name: string
  location: string
}

/**
 * 此路段坐标集
 */
export interface TransitRoutePolylineResponse {
  polyline: string
}

/**
 * 路线分段
 */
export interface TransitRouteTransitSegmentTaxiResponse {
  distance: number,
  polyline: TransitRoutePolylineResponse,
  startpoint: string,
  endpoint: string
}