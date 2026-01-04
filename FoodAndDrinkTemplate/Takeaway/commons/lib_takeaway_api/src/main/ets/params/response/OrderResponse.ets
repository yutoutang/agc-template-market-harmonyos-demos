import { IAddrInfo } from '../../database/IAddrType';
import { BaseResponse } from './BaseResponse';
import { CarGoodsInfo } from './GoodsResponse';
import { StoreResponse } from './StoreResponse';

export interface OrderListResp extends BaseResponse {
  total: number;
  curPage: number;
  orderList: OrderItem[];
  isFinal: boolean;
}

export interface OrderDetailResp extends BaseResponse {
  detail: OrderItem;
}

export interface OrderItem {
  orderInfo: OrderInfo;
  logisticInfo: LogisticsItem[];
  carGoodsInfo: CarGoodsInfo[];
  storeInfo: StoreResponse;
}

export interface SubmitOrderItem {
  addressInfo?: IAddrInfo;
  carGoodsList: CarGoodsInfo[];
  storeInfo: StoreResponse;
}

export interface OrderInfo {
  status: number; // 0: 待付款, 1: 已取消, 2: 待发货, 3: 待收货, 4: 待评价, 5:已评价（已完成）, 6: 退款/售后, 7:已退款
  orderNo: string;
  addressInfo: IAddrInfo | undefined;
  orderTime: number; // 时间戳
  deliveryTime: string; // 配送时间
  remark?: string;
  originalPrice: number;
  finalPrice: number;
  deliveryFee: number;
  payModel: string; //支付方式
  discounts: DiscountItem[];
  remainingTime?: number;
  refundTime?: string;
  receivingMethod: number; //0: 外卖配送  1: 到店自提
}

export interface DiscountItem {
  type: number;
  discountPrice: number;
}

export interface LogisticsItem {
  icon: string;
  status: number; //1: 待确认  2: 已发货  3: 运输中  4:已签收
  desc: string;
  time: string;
}
