import {
  AddressInfo, DiscountItem, OrderSkuItem, SkuReview,
} from './responses/OrderResponse';

export interface OrderUpdateReq {
  status?: number;
  addressInfo?: AddressInfo;
}

export interface OrderReviewReq {
  reviews: SkuReview[];
}

export interface PreOrderInfoReq {
  items: PreOrderItem[];
}

export interface PreOrderItem {
  skuCode: string;
  count: number;
}

export interface OrderCreateReq {
  skuList: OrderSkuItem[];
  orderInfo: OrderCreateInfo;
}

export interface OrderCreateInfo {
  addressInfo: AddressInfo;
  remark?: string;
  originalPrice: number;
  finalPrice: number;
  discounts: DiscountItem[];
  receivingMethod: number; //1: 快递物流  2: 到店自提
}

export interface ProductListReq {
  curPage: number;
  targetId?: string;
  sortType?: number;
  filterList?: FilterSelectionItem[];
  categoryId?: string;
  keyword?: string;
}

export interface FilterSelectionItem {
  id: string;
  value: string[];
}

export interface UpdateUserPointsReq {
  newPoints: number
  type: number
  label: string
}

export interface UpdateUserInfoReq {
  type: string // avatar nickname phone
  value: string
}

export interface UserLoginReq {
  phoneNumbers?: string
  verifyCode?: string
  unionID?: string
  authorizationCode?: string
}