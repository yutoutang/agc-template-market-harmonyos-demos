
export interface Location{
  latitude: number
  longitude: number
}

/**
 * 路线数据类型
 */

export interface RouteType{
  name:string
  itemIndex:number
  length:number
  distance:number
  picture:string
  recommend:boolean
  checked:boolean
  place:Location[]
}