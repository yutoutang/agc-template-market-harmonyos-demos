import { BusbaseResponse } from './BusbaseResponse'

/**
 * 公交站关键字响应
 */
export interface DistanceResponse extends BusbaseResponse {
  // 返回的规划方案列表
  results: TransitResultResponse[]
}

/**
 * 公交方案
 */
export interface TransitResultResponse {
  // 本条路线的总距离，单位：米
  distance: number
  // 路线分段
  duration: number
}

