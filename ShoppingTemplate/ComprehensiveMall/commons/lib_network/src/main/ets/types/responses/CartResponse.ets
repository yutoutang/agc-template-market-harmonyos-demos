import { BaseResponse } from './BaseResponse';

export interface CartListResp extends BaseResponse {
  data: CartDto;
}

export interface CartDto {
  version: string;
  total: number;
  cards: CartSkuItem[];
}

export interface CartSkuItem {
  productId: string;
  skuCode: string;
  skuDesc: string;
  stock: number;
  count: number;
  banner: string;
  title: string;
  serviceDesc: string;
  price: number;
  dashPrice?: number;
  isSelected: boolean;
}
