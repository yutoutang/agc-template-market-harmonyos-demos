import { BusbaseResponse } from './BusbaseResponse'

/**
 * 公交站关键字响应
 */
export interface WalkingResponse extends BusbaseResponse {
  // 返回的规划方案列表
  route: WalkingRouteResponse
}

/**
 * 规划方案
 */
export interface WalkingRouteResponse {
  // 起点经纬度
  origin: string
  // 终点经纬度
  destination: string
  // 公交方案列表
  paths: WalkingRoutePathResponse[]
}

/**
 * 公交方案
 */
export interface WalkingRoutePathResponse {
  // 本条路线的总距离，单位：米
  distance: string
  // 预计耗时
  cost?: WalkingRouteCostResponse
  // 路线分段
  steps: WalkingRoutePathStepResponse[]
}

/**
 * 花费时间
 */
export interface WalkingRouteCostResponse {
  duration: string
}


export interface WalkingRoutePathStepResponse {
  // 步行导航信息
  instruction: string
  // 步行导航距离
  step_distance: number
  // 步行导航时间
  road_name: number
  // 预计耗时
  cost?: WalkingRouteCostResponse
  // 步行导航经纬度
  polyline: string
}

