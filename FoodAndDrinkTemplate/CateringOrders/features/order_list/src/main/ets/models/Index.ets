import { OrderGoodsResp, OrderInfoResp, OrderTableResp } from 'network'

export interface BtnType {
  text: ResourceStr
  color: ResourceStr
  backgroundColor: ResourceStr
  callback: (orderId: string) => void
}

@ObservedV2
export class OrderInfo implements OrderInfoResp {
  id: string = ''
  orderNum: string = ''
  time: string = ''
  payTime: string = ''
  money: number = 0
  reductionMoney: number = 0
  boxMoney: number = 0
  mjMoney: number = 0
  xyhMoney: number = 0
  note: string = ''
  payType: number = 0
  orderType: number = 0
  tableware: string = ''
  yhqMoney: number = 0
  couponId: string = ''
  @Trace state: number = 0
  oid: string = ''
  tel: string = ''
  name: string = ''
  address: string = ''
  lat: string = ''
  lng: string = ''
  rechargeId: string = ''
  preorderTime: string = ''
  preorderPhone: string = ''
}

// 订单列表
@ObservedV2
export class MyOrderInfo {
  @Trace order: OrderInfo = new OrderInfo()
  goods: Array<OrderGoodsResp> = []
  table?: OrderTableResp
}