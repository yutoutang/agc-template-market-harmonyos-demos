import { ReviewMediaType } from './Enums';

export interface ProductInfo {
  id: string;
  banners: ResourceStr[];
  price: string;
  dashPrice: string;
  sales: string;
  title: string;
  tags: string[];
  logistics: ProductServiceItem[];
  service: ProductServiceItem[];
  pictures: ResourceStr[];
  selectionInfo: ProductSelectionInfo;
}

export interface ProductServiceItem {
  icon: ResourceStr;
  content: string;
}

export interface ProductSelectionInfo {
  defaultBanner: ResourceStr;
  basicPrice: string;
  priceRange: string;
  priceRemark: string;
  totalPriceRemark: string;
  services: string[];
  skuItems: SkuItem[];
  specOptions: SpecOption[];
  specOptionWithImage: SpecOption | null;
}

export interface SkuItem {
  skuCode: string; // 库存保持单元编码 (唯一)
  specs: Record<string, string>; // 规格组合 (key to uuid)
  stock: number;
  price: number;
  dashPrice: number;
}

export interface SpecValue {
  id: string;
  text: string;
  image?: ResourceStr;
}

export interface SpecOption {
  key: string;
  values: SpecValue[];
}

export interface ProductReviewItem {
  productId: string;
  userAvatar: ResourceStr;
  userName: string;
  skuCode: string;
  skuDesc: string[];
  rating: number;
  date: number; //时间戳
  content: string;
  mediaList: ReviewMediaItem[];
}

export interface ReviewMediaItem {
  uri: ResourceStr;
  type: ReviewMediaType;
}

export interface ProductReviewResp {
  reviewList: ProductReviewItem[];
  curPage: number;
  total: number;
  isFinal: boolean;
}
