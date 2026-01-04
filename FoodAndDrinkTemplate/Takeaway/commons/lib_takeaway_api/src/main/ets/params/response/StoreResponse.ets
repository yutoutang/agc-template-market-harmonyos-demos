import { StoreEnum } from '../../constants/Constants'

/**
 * 外卖内容-云侧接口响应模型
 */
export interface StoreResponse {
  // 店铺id
  id: string
  // 店铺类型
  type: StoreEnum
  // 店铺名称
  name: string
  // 创建时间
  createTime: number
  // 店铺评分
  score: number
  // 月销量
  monthlySales: number
  // 关注数量
  followCount: number
  // 分享数量
  shareCount: number
  // 封面图
  coverUrl?: string
  // 起送价
  startingPrice: number
  // 配送费
  deliveryFee: number
  // 店铺评分
  deliveryTime: number
  // 配送距离
  distance: number
  // 地址
  address?: string
  // 营业时间
  openTime?: string
  // 商家介绍
  introduction?: string
  // 纬度
  latitude?: number;

  // 经度
  longitude?: number;

}