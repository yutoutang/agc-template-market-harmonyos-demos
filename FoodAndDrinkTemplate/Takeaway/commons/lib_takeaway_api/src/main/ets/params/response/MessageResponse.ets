/**
 * 消息菜单类型
 */
export enum MineMsgMenuType {
  System, // 系统
  Coupon, // 优惠
  Order, // 订单
  Envelope // 红包
}

export interface IMineMsgItem {
  id: number
  type: MineMsgMenuType
  title: string
  content: string
  createTime: number
  isNewMessage?: boolean
}


