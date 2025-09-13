import { MyCarResp } from 'network'
import { CarGoodsInfo, MyCar } from '../models/StorageModel'

export function myCarMapper(myCarResp: MyCarResp) {
  let myCar: MyCar = new MyCar(myCarResp.boxMoney, myCarResp.goodsList, myCarResp.num, myCarResp.money)
  myCar.goodsList = myCarResp.goodsList.map(item => {
    let carGood = new CarGoodsInfo()
    carGood.id = item.id
    carGood.goodsId = item.goodsId
    carGood.name = item.name
    carGood.logo = item.logo
    carGood.num = item.num
    carGood.specType = item.specType
    carGood.spec = item.spec
    carGood.combination = item.combination
    carGood.discount = item.discount
    carGood.money = item.money
    carGood.money2 = item.money2
    carGood.boxMoney = item.boxMoney
    carGood.isMust = item.isMust
    return carGood
  })
  return myCar
}
