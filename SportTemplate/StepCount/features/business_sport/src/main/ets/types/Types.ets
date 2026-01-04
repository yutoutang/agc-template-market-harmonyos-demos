/**
 * 运动SportItem类型
 */

export interface SportItemType {
  name: string
  itemIndex: number
}

/**
 * 运动SportItem类型
 */

export interface WalkType {
  name: string
  itemIndex: number
}

interface Location {
  latitude: number
  longitude: number
}

/**
 * 路线数据类型
 */

export interface RouteType {
  name: string
  itemIndex: number
  length: number
  distance: number
  picture: string
  recommend: boolean
  place: Location[]
}