import { BaseResponse } from './BaseResponse';

export interface PreOrderResp extends BaseResponse {
  skuList: OrderSkuItem[];
  totalPrice: number;
}

export interface OrderListResp extends BaseResponse {
  total: number;
  curPage: number;
  orderList: OrderItem[];
  isFinal: boolean;
}

export interface OrderDetailResp extends BaseResponse {
  detail: OrderItem;
}

export interface OrderCreateResp extends BaseResponse {
  orderNo: string;
  orderStr: string;
}

export interface OrderExpressResp extends BaseResponse {
  info: OrderExpressInfo
}

export interface OrderItem {
  orderInfo: OrderInfo;
  logisticInfo: LogisticsItem[];
  skuInfo: OrderSkuItem[];
}

export interface OrderInfo {
  status: number; // 0: 待付款, 1: 已取消, 2: 待发货, 3: 待收货, 4: 待评价, 5:已评价（已完成）, 6: 退款/售后, 7:已退款
  orderNo: string;
  addressInfo: AddressInfo;
  orderTime: number; // 时间戳
  remark?: string;
  originalPrice: number;
  finalPrice: number;
  discounts: DiscountItem[];
  remainingTime?: number;
  refundTime?: string;
  receivingMethod: number; //1: 快递物流  2: 到店自提
}

export interface AddressInfo {
  name: string;
  cellphone: string;
  address: string;
  city?: string;
  latitude?: number,
  longitude?: number
}

export interface DiscountItem {
  type: number;
  discountPrice: number;
}

export interface OrderSkuItem {
  productId: string;
  skuCode: string;
  skuDesc: string;
  count: number;
  banner: ResourceStr;
  title: string;
  serviceDesc: string;
  dashPrice: number;
  price: number;
  skuReview?: SkuReview;
}

export interface LogisticsItem {
  icon: ResourceStr;
  status: number; //1: 待确认  2: 已发货  3: 运输中  4:已签收
  desc: string;
  time: string;
}

export interface SkuReview {
  productId: string;
  date: number;
  skuCode: string;
  skuDesc: string;
  rating: number;
  content: string;
  mediaList: ReviewMediaItem[];
}

export interface ReviewMediaItem {
  uri: ResourceStr;
  type: number;
}

export interface OrderExpressInfo {
  orderId: string
  expressNo: string
  expressName: string
  origins: OrderPosition,
  destination: OrderPosition,
  waypoints: OrderPosition[],
  sendPosition: string,
  getPosition: string,
}

export interface OrderPosition {
  latitude: number,
  longitude: number
}