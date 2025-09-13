export interface UserInfoResp {
  id: string
  name: string
  img: string
  openId: string
  unionId: string
  storeId: string
  totalScore: number
  wallet: number
  userTel: string
}

export interface HelpMsgResp {
  id: string
  question: string
  answer: string
}

export interface RechargeRecord {
  id: string
  // 充值金额
  rechargeMoney: number
  // 当前余额
  balance: number
  // 充值时间
  time: number
  // 充值状态
  statue:number
}
