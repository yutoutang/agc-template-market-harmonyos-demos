export interface OnlineInfo {
  coinIcon: string // 图标
  coin: number // 金币数量
  time: string // 在线时间
  node: number // 奖励时间节点
  canGet: boolean // 是否可以获得奖励
  isObtained: boolean // 是否已经获得
}

@ObservedV2
export class OnlineInfoClass implements OnlineInfo {
  coinIcon: string
  coin: number
  time: string
  node: number
  @Trace canGet: boolean
  @Trace isObtained: boolean

  constructor(coinIcon: string, coin: number, time: string, node: number, canGet: boolean = false,
    isObtained: boolean = false) {
    this.coinIcon = coinIcon
    this.coin = coin
    this.time = time
    this.node = node
    this.canGet = canGet
    this.isObtained = isObtained
  }
}