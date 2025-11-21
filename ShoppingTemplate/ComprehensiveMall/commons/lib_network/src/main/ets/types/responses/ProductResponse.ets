import { BaseResponse } from './BaseResponse';

export interface ProductSkuItem {
  productId: string;
  skuCode: string;
  skuDesc: string;
  stock: number;
  banner: string;
  title: string;
  serviceDesc: string;
  price: number;
  dashPrice?: number;
}

export interface LabelItem {
  preset: number;
  data: string;
}

export interface ProductCardItem {
  categoryId: string;
  productId: string;
  price: number;
  dashPrice?: number;
  title: string;
  banner: ResourceStr;
  promotion: string[];
  label: LabelItem[];
  summary: ProductItemSummary;
  sales: number;
}

export interface ProductItemSummary {
  size: string[];
  minPrice: number;
  maxPrice: number;
  place: string;
}

export interface ProductListResp extends BaseResponse {
  list: ProductCardItem[];
  curPage: number;
  total: number;
  isFinal: boolean;
}

export interface ProductCollectStatusResp extends BaseResponse {
  status: number; // 0:未收藏 1：已收藏
}
