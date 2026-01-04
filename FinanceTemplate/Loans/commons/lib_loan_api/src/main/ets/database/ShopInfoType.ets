/**
 * 平台商家数据库字段
 */
export interface ShopInfoType {
  bannerIcon: ResourceStr
  interduceStart: string,
  interduceEnd: string,
  features: FeatureType[]
}

/**
 * 商家优势数据库字段
 */
export interface FeatureType {
  featureTitle: string,
  featureDesc: string
}