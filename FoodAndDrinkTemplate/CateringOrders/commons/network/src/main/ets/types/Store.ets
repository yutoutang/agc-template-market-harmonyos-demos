export class PreloadResponse {
  appInfo?: AppInfoResp
  tableList?: Array<TableInfoResp>
}

export interface AppInfoResp {
  // 店铺id
  storeId: string
  // 店铺类型 1：按桌号点餐 2：按取餐码点餐
  storeType: number
  // 店铺状态 1：营业
  status: number
}

export interface StoreInfoResp {
  id: string
  name: string
  address: string
  // 营业起止时间
  time1: string
  time2: string
  tel: string
  // 促销信息
  announcement: string
  logo: string
  // 位置坐标
  coordinates: string
  // 营业执照
  businessLicense: string
  // 食品经营许可证
  foodLicense: string
  environment: Array<string>
  isRest: number
  // 新用户满减金额
  xyhMoney: number
  // 备注口味：多个以;；分隔
  taste: string
  reductionList: Array<ReductionResp>
  // 充值档次
  rechargeTier: Array<RechargeTier>
}

export interface TableInfoResp {
  id: string
  // 餐桌名称
  tableName: string
  // 餐桌类型
  typeName: string
  // 餐桌人数
  num: number
  // 餐桌状态
  status: number
}

export interface ReductionResp {
  id: string
  name: string
  full: number
  reduction: number
  type: number
}

export interface RechargeTier {
  id: string
  name: string
  // 支付金额
  payMoney: number
  // 充值金额
  realMoney: number
  desc: string
  type: number
}