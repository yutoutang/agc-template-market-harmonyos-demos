// 充值档次
export class RechargeTier {
  id: string = ''
  name: string = ''
  payMoney: number = 0
  realMoney: number = 0
  desc: string = ''
  type: number = 0
}

export interface RechargeRecord {
  id: string
  // 充值金额
  rechargeMoney: number
  // 当前余额
  balance: number
  // 充值时间
  time: number
}