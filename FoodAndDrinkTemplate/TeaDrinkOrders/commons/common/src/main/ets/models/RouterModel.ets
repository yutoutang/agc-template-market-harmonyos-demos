import { CarGoodsInfo, Goods, StoreInfo } from './ResponseModel';

export interface HwMapModel {
  latitude: number,
  longitude: number,
  storeInfo: StoreInfo
}

export interface GoodsRouter {
  goodsInfo: Goods,
}

export interface IndexPageRouter {
  index: number,
  storeId: string,
  orderId: string,
}

export interface OrderDetailRouter {
  orderId: string,
  isOrderJump: boolean
}

export interface CouponRouter {
  totalMoney: number,
  selectId: string,
  reduce: string,
}

export interface RemarksRouter {
  remarks: string,
}

export interface ImageRouter {
  imageSrc: ResourceStr;
}

export interface ConfirmOrderRouter {
  carGoods: Array<CarGoodsInfo>;
}

export interface FormCardJump {
  url: string,
  params: OrderDetailRouter,
}
