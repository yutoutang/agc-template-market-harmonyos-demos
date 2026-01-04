import { CarGoodsInfo } from '../params/response/GoodsResponse'
import { MyCarResp } from '../params/response/MyCarResponse'
import { StoreModel } from './StoreModel'

@ObservedV2
export class MyCarModel {
  @Trace myCar: MyCar[] = []
  @Trace storeIdNow: string = ''
}

@ObservedV2
export class MyCar {
  @Trace boxMoney: number = 0
  @Trace goodsList: CarGoodsInfo[] = []
  @Trace num: number = 0
  @Trace money: number = 0
  @Trace storeId: string = ''
  @Trace storeInfo: StoreModel | undefined = undefined
  @Trace isCheck: number = 0
  @Trace isMust: number = 0
  @Trace checkCarIds: string[] = []

  update(item: MyCarResp) {
    this.boxMoney = item.boxMoney
    this.goodsList = item.goodsList
    this.num = item.num
    this.money = item.money
    this.isCheck = item.isCheck
    this.storeId = item.storeId
    this.storeInfo = new StoreModel(item.storeInfo)
  }
}