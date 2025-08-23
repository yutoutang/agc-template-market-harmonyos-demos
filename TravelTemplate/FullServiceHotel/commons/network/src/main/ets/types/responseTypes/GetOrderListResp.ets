export interface OrderItem {
  orderNo: string;
  orderStatus: string;
  createTime: string;
  id: number;
  actualPaidPrice: string;
  shopName: string;
  goodsName: string;
  orderType: string;
  goodsQty: number;
  shopLogo: ResourceStr;
  displayImg: ResourceStr;
}

export type GetOrderListResp = OrderItem[];
