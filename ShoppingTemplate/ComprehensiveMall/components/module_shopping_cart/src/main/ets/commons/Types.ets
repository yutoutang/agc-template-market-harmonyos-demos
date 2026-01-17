export interface ProductSkuItem {
  productId: string;
  skuCode: string;
  skuDesc: string;
  stock: number;
  banner: ResourceStr;
  title: string;
  serviceDesc: string;
  price: number;
  dashPrice?: number;
}

export interface CartProductInfo extends ProductSkuItem {
  count: number
}

export interface CartPrice {
  originalPrice: number
  discountList: DiscountItem[]
  finalPrice: number
}

export interface DiscountItem {
  type: number
  label:string
  discountPrice: number
}

export interface CartCardDto {
  productId: string;
  skuCode: string;
  skuDesc: string;
  stock: number;
  count: number;
  banner: ResourceStr;
  title: string;
  serviceDesc: string;
  price: number;
  dashPrice?: number;
  isSelected: boolean;
}

export interface CartDto {
  version: string;
  total: number;
  cards: CartCardDto[];
}

export interface UpdateCartReq {
  skuCode: string;
  count: number;
}

export interface DeleteCartReq {
  skuList: string[]
  isRemain: boolean
}

export interface CalcCartPriceReq {
  isMember: boolean
  skuList: CartProductInfo[],
  extraDiscount?:DiscountItem[]
}

export interface BaseResponse {
  code: number;
  msg?: string;
}