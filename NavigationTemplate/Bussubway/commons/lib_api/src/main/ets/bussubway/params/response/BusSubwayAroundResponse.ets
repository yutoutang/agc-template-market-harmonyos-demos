import { BusbaseResponse } from './BusbaseResponse'

/**
 * 公交站关键字响应
 */
export interface BusSubwayAroundResponse extends BusbaseResponse {
  // 结果数
  count: number
  // 公交线路信息
  pois: PoiResponse[]
}

export interface PoiResponse {
  // poi 名称
  name: string
  // poi 唯一标识
  id: string
  // poi 经纬度
  location: string
  // 公交类型
  typecode: string
}

/**
 * 公交车站信息列表
 */
export interface BuslineStopResponse {
  // 公交站名
  name: string
  // 经纬度
  location: string
}