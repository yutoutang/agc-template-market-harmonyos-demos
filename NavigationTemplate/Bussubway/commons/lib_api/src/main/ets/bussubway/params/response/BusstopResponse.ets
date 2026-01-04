import { BusbaseResponse } from './BusbaseResponse'

/**
 * 公交站关键字响应
 */
export interface BusstopSearchResponse extends BusbaseResponse {
  // 结果数
  count: number
  // 公交车站信息列表
  busstops: BusstopResponse[]
}

/**
 * 公交车站信息列表
 */
export interface BusstopResponse {
  // 站点Id
  id: string
  // 公交站名
  name: string
  // 经纬度
  location: string
  // 途径此站的公交路线列表
  buslines: BusstopLineResponse[]
  // 城市编码
  citycode: string

}

/**
 * 途径此站的公交路线列表
 */
export interface BusstopLineResponse {
  // 线路ID
  id: string
  // 公交线路途径此站的经纬度
  location: string
  // 线路名称
  name: string
  // 首发站
  start_stop: string
  // 末站
  end_stop: string

}