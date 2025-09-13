import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { RequestUrlMap } from '../../constants/Enums';
import {
  OrderCreateReq, OrderReviewReq, OrderUpdateReq, PreOrderInfoReq,
} from '../../types/RequestTypes';
import { BaseResponse } from '../../types/responses/BaseResponse';
import {
  OrderCreateResp,
  OrderItem,
  OrderListResp,
  OrderSkuItem,
  PreOrderResp,
} from '../../types/responses/OrderResponse';
import { MockOrderData } from '../mockdata/MockOrderData';
import { MockProductData } from '../mockdata/MockProductData';

export class OrderMockApis {
  private readonly PAGE_SIZE = 6;
  private _orderList: OrderItem[] = JSON.parse(JSON.stringify(MockOrderData.orderList));

  public start(adapter: AxiosMockAdapter) {
    // 获取预支付商品信息
    adapter
      .onGet(RequestUrlMap.ORDER_PRE_INFO)
      .reply((config: AxiosRequestConfig) => {
        const data: PreOrderInfoReq = config.params;
        const skuList: OrderSkuItem[] = [];
        data.items.forEach((item) => {
          const skuItem = MockProductData.PRODUCT_SKU_TABLE.find(
            (sku) => sku.skuCode === item.skuCode,
          );
          if (skuItem) {
            const orderSku: OrderSkuItem = {
              productId: skuItem.productId,
              skuCode: skuItem.skuCode,
              skuDesc: skuItem.skuDesc,
              count: item.count,
              banner: skuItem.banner,
              title: skuItem.title,
              serviceDesc: skuItem.serviceDesc,
              dashPrice: skuItem.dashPrice ?? skuItem.price,
              price: skuItem.price,
            };
            skuList.push(orderSku);
          }
        });
        const totalPrice = skuList.reduce(
          (pre, cur) => pre + cur.price * cur.count,
          0,
        );
        const res: PreOrderResp = {
          code: 0,
          skuList,
          totalPrice,
        };
        return [HttpStatusCode.Ok, res];
      });

    // 获取订单列表
    adapter
      .onGet(RequestUrlMap.ORDER_LIST)
      .reply((config: AxiosRequestConfig) => {
        const page: number = config.params.curPage;
        const status: number[] = config.params.status;
        const keywords: string | undefined = config.params.keywords;
        const startIndex = (page - 1) * this.PAGE_SIZE;
        const endIndex = startIndex + this.PAGE_SIZE;
        let list = this._orderList.filter((order) =>
        status.includes(order.orderInfo.status),
        );
        if (keywords) {
          list = list.filter((order) => {
            const titles = order.skuInfo.map((sku) => sku.title);
            return titles.some((title) => title.includes(keywords));
          });
        }
        const orders = list.slice(startIndex, endIndex);
        const isFinal = orders.length < this.PAGE_SIZE;
        const total = list.length;
        const res: OrderListResp = {
          code: 0,
          orderList: orders,
          curPage: page,
          total,
          isFinal,
        };
        return [HttpStatusCode.Ok, res];
      });

    // 获取订单详情
    adapter
      .onGet(RequestUrlMap.ORDER_DETAIL)
      .reply((config: AxiosRequestConfig) => {
        const orderId: string = config.params.orderId;
        const order = this._orderList.find(
          (item) => item.orderInfo.orderNo === orderId,
        );
        if (!order) {
          return [
            HttpStatusCode.Ok,
            {
              code: 1,
              msg: '订单不存在',
            },
          ];
        }
        return [
          HttpStatusCode.Ok,
          {
            code: 0,
            detail: order,
          },
        ];
      });

    // 创建订单
    adapter
      .onPost(RequestUrlMap.ORDER_CREATE)
      .reply((config: AxiosRequestConfig) => {
        const data = JSON.parse(config.data ?? '{}') as OrderCreateReq;
        const orderTime = new Date().getTime();
        const orderNo = 'mock_order_' + orderTime;
        const remainingTime = orderTime + 60 * 60 * 1000 * 24;
        const orderItem: OrderItem = {
          skuInfo: data.skuList,
          logisticInfo: [],
          orderInfo: {
            status: 0,
            orderNo,
            addressInfo: data.orderInfo.addressInfo,
            orderTime,
            remark: data.orderInfo.remark ?? '',
            originalPrice: data.orderInfo.originalPrice,
            finalPrice: data.orderInfo.finalPrice,
            discounts: data.orderInfo.discounts,
            remainingTime,
            receivingMethod: data.orderInfo.receivingMethod,
          },
        };
        this._orderList.unshift(orderItem);
        const res: OrderCreateResp = {
          code: 0,
          msg: '创建成功',
          orderNo,
          orderStr: orderNo,
        };
        return [HttpStatusCode.Ok, res];
      });

    // 更新订单
    adapter
      .onPut(RequestUrlMap.ORDER_UPDATE)
      .reply((config: AxiosRequestConfig) => {
        const orderId: string = config.params.orderId;
        const data: OrderUpdateReq = JSON.parse(config.data ?? '{}');
        const order = this._orderList.find(
          (item) => item.orderInfo.orderNo === orderId,
        );
        const res: BaseResponse = {
          code: 1,
          msg: '订单不存在',
        };
        if (order) {
          if (data.status) {
            order.orderInfo.status = data.status;
          }
          if (data.addressInfo) {
            order.orderInfo.addressInfo = data.addressInfo;
          }
          res.code = 0;
          res.msg = '更新成功';
        }
        return [HttpStatusCode.Ok, res];
      });

    // 删除订单
    adapter
      .onDelete(RequestUrlMap.ORDER_DELETE)
      .reply((config: AxiosRequestConfig) => {
        const orderId: string = config.params.orderId;
        const idx = this._orderList.findIndex(
          (item) => item.orderInfo.orderNo === orderId,
        );
        const res: BaseResponse = {
          code: 1,
          msg: '订单不存在',
        };
        if (idx >= 0) {
          this._orderList.splice(idx, 1);
          res.code = 0;
          res.msg = '删除成功';
        }
        return [HttpStatusCode.Ok, res];
      });

    // 添加订单评论
    adapter
      .onPost(RequestUrlMap.ORDER_ADD_COMMENT)
      .reply((config: AxiosRequestConfig) => {
        const orderId: string = config.params.orderId;
        const data: OrderReviewReq = JSON.parse(config.data ?? '{}');
        const order = this._orderList.find(
          (item) => item.orderInfo.orderNo === orderId,
        );
        const res: BaseResponse = {
          code: 1,
          msg: '订单不存在',
        };
        if (order) {
          if (order.skuInfo.length && data.reviews?.length) {
            order.skuInfo.forEach((item) => {
              const review = data.reviews.find(
                (review) => review.skuCode === item.skuCode,
              );
              item.skuReview = review;
            });
            order.orderInfo.status = 5;
          }
          res.code = 0;
          res.msg = '评论添加成功';
        }
        return [HttpStatusCode.Ok, res];
      });
  }
}
