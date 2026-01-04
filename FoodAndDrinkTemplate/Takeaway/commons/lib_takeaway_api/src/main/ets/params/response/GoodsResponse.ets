export interface SpecItemResp {
  specValId: string
  specValName: string
  specValLogo: string
  specValNum: string
}

export interface SpecCatalogResp {
  specId: string
  specName: string
  specValId: string
  specVal: SpecItemResp[]
}

/**
 * 商品
 */
export interface GoodsResp {
  id: string
  name: string
  logo: string
  bigImg: string[]
  // 现价
  money: number
  // 原价
  money2: number
  // 折扣
  discount: string
  content: string
  sales: number
  // 是否有规格 1 无 2有规格 3套餐 4加购商品
  specType: number
  details: string
  num: number
  isMust: number
  spec: SpecCatalogResp[]
  // 餐盒费
  boxMoney: number
}

@ObservedV2
export class Goods implements GoodsResp {
  id: string = ''
  name: string = ''
  logo: string = ''
  bigImg: string[] = []
  // 现价
  money: number = 0
  // 原价
  money2: number = 0
  // 折扣
  discount: string = ''
  content: string = ''
  sales: number = 0
  // 是否有规格 1 无 2有规格 3套餐
  specType: number = 0
  details: string = ''
  @Trace num: number = 0
  isMust: number = 0
  spec: SpecCatalogResp[] = []
  // 餐盒费
  boxMoney: number = 0
}

/**
 * 商品类别
 */
export interface GoodsTypeResp {
  id: string
  typeName: string
  goods: GoodsResp[]
}

/**
 * 规格商品
 */
export interface GoodsSpecResp {
  id: string
  money: number
  money2: number
  discount: string
  spec: string
  combination: PackageSpecResp[]
  number: number
  goodsId: string
  boxMoney: number
  isMust: number
  specType: number
}


export interface MyCarResp {
  boxMoney: number
  goodsList: CarGoodsInfoResp[]
  num: number
  money: number
}

export interface PackageSpecResp {
  // 规格名称
  specName: string
  // 规格值
  specNum: number
}

export interface CarGoodsInfoResp {
  // 购物车id
  id: string
  // 商品id
  goodsId: string
  // 商品名称
  name: string
  // 商品logo
  logo: string
  // 商品数量
  num: number
  // 商品规格类型
  specType: number
  // 商品规格
  spec: string
  // 商品规格详情
  combination: PackageSpecResp[]
  // 商品折扣
  discount: string
  // 商品现价
  money: number
  // 商品原价
  money2: number
  // 商品打包费
  boxMoney: number
  // 商品是否必选
  isMust: number
  // 商品是否选中
  isCheck: boolean

}

@ObservedV2
export class CarGoodsInfo {
  @Trace id: string = ''
  @Trace goodsId: string = '';
  @Trace name: string = ''
  @Trace logo: string = ''
  @Trace num: number = 0
  @Trace specType: number = 0
  @Trace spec: string = ''
  @Trace combination: PackageSpec[] = []
  @Trace discount: string = ''
  @Trace money: number = 0
  @Trace money2: number = 0
  @Trace boxMoney: number = 0
  @Trace isMust: number = 0
  @Trace isCheck: boolean = false
}

@ObservedV2
export class PackageSpec {
  @Trace specName: string = ''
  @Trace specNum: number = 0
}




