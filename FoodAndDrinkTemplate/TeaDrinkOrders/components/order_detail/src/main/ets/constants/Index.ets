export class Constants {
  // 订单支付超时时间
  static readonly COUNTDOWN_TIME = 30
  // 时间转换
  static readonly SECOND_TO_MIN = 60
  // 延迟时间1000ms
  static readonly DELAY_TIME_1000 = 1000
}

// 订单类型
export enum OrderTypeEnum {
  // 到店自取
  PICK_SELF = 0,
  // 外卖配送
  TAKEAWAY_DELIVERY = 1,
}

// 订单状态
export enum OrderStateEnum {
  // 待支付
  TO_BE_PAID = 0,
  // 制作中
  MAKING,
  // 配送中
  DELIVERING,
  // 已完成
  COMPLETED,
  // 已取消
  CANCELED,
}

// 订单类型
export const orderTypeMap: Record<number, ResourceStr> = {
  // 到店自取
  0: $r('app.string.pick_self_tag'),
  // 外卖配送
  1: $r('app.string.takeaway_tag'),
}

// 订单状态
export const orderStateMap: Record<number, ResourceStr> = {
  // 待支付
  0: $r('app.string.to_be_paid'),
  // 制作中
  1: $r('app.string.making'),
  // 配送中
  2: $r('app.string.delivering'),
  // 已完成
  3: $r('app.string.completed'),
  // 已取消
  4: $r('app.string.canceled'),
}
