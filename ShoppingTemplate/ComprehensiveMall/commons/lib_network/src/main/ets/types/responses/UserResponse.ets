import { BaseResponse } from './BaseResponse'

export interface UserPoints {
  totalPoints: number
  checkedDays: number
  latestCheck: number // 时间戳
  pointsArr: number[]
}

export interface UserPointsResp extends BaseResponse {
  data: UserPoints
}

export interface UserPointsRecordResp extends BaseResponse {
  totalPoints: number
  month: string, // YYYY-MM
  list: UserPointsRecordItem[]
}

export interface UserPointsRecordItem {
  time: number // 时间戳
  type: number // 0:支出 1:收入
  label: string
  points: number
}

export interface UserPointRedemptionSku {
  skuCode: string
  price: number
  title: string
  banner: ResourceStr
  description?: string
}

export interface ProductForPointsResp extends BaseResponse {
  list: UserPointRedemptionSku[]
}