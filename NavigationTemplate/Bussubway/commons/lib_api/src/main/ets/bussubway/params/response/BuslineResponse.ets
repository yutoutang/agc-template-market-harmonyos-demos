import { BusbaseResponse } from './BusbaseResponse'

/**
 * 公交站关键字响应
 */
export interface BuslineSearchResponse extends BusbaseResponse {
  // 结果数
  count: number
  // 公交线路信息
  buslines: BuslineResponse[]
}

export interface BuslineResponse {
  //公交线路 id
  id: string
  // 公交类型
  type: string
  // 线路名称
  name: string
  // 线路经纬度
  polyline: string
  // 线路城市
  citycode: string
  // 首发站
  start_stop: string
  // 末站
  end_stop: string
  // 首班车时间
  start_time: string | string[]
  // 末班车时间
  end_time: string | string[]
  // 颜色
  uicolor?: string
  // 反向线路 id
  direc: string
  // 起步价
  basic_price: string
  // 全程票价
  total_price: string
  //途径站
  busstops: BuslineStopResponse[]
  // 发车间隔
  interval: string
}

/**
 * 公交车站信息列表
 */
export interface BuslineStopResponse {
  // 公交ID
  id: string
  // 公交站名
  name: string
  // 经纬度
  location: string
}