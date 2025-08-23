@ObservedV2
export class OrderInfo {
  id?: string
  orderNum?: string
  time?: string
  payTime: number = 0
  money?: number
  boxMoney?: number
  mjMoney?: string
  xyhMoney?: string
  note?: string
  payType?: number
  orderType: number = 0
  cutlery?: string
  yhqMoney?: string
  couponId?: string
  @Trace state: number = 0
  oid?: string
  tel?: string
  storeName?: string
  address?: string
  coordinates?: string
  bagMoney?: number
}

//地址信息
@ObservedV2
export class AddressInfo {
  @Trace id: number = 0
  @Trace addressPre: string = ''
  @Trace addressNum: string = ''
  @Trace name: string = ''
  @Trace sex: boolean = true
  @Trace tel: string = ''
  @Trace tag: number = 0
  @Trace latitude: number = 0
  @Trace longitude: number = 0
}

//配送信息
@ObservedV2
export class DeliveryInfo {
  @Trace name: string = ''
  @Trace tel: string = ''
  @Trace latitude: number = 0
  @Trace longitude: number = 0
  @Trace distance: number = 0
  @Trace remainingTime: number = 0
  @Trace estimatedTime: string = ''
}