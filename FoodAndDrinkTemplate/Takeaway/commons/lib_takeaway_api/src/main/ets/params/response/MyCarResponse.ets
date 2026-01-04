import { CarGoodsInfoResp } from './GoodsResponse'
import { StoreResponse } from './StoreResponse'

export interface MyCarResp {
  boxMoney: number
  // 购物车商品列表
  goodsList: CarGoodsInfoResp[]
  // 购物车商品数量
  num: number
  // 购物车总价格
  money: number
  // 店铺id
  storeId: string
  // 店铺信息
  storeInfo: StoreResponse
  // 是否被选中
  isCheck: number
}
