export const STORE_TABS = [
  '点餐',
  '评价',
  '商家',
]

export class Constants {
  static readonly GOOD_TYPE_HOT = '1'
  static readonly GOODS_MUST = 1
}

export class CommonUrl {
  static readonly CLOUD_STORAGE_URL = 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/test-1pvkp/'
}

// 商品类别
export enum GoodsSpecEnum {
  // 正常
  NORMAL = 1,
  // 选规格
  SPEC_TYPE = 2,
  // 选套餐
  PACKAGE_TYPE = 3,
}

