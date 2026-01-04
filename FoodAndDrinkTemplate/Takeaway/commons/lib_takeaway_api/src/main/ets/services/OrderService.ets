import { OrderDetailResp, OrderItem, OrderListResp } from '../params/response/OrderResponse';
import { MockOrderData } from './mockdata/MockOrderData';
import { BaseResponse } from '../params/response/BaseResponse';
import { Logger } from 'module_ui_base';

export class OrderService {
  private _orderList: OrderItem[] = JSON.parse(JSON.stringify(MockOrderData.orderList));
  private readonly PAGE_SIZE = 6;

  /**
   * 创建订单
   * @param order
   */
  public creatOrder(order: OrderItem) {
    this._orderList.unshift(order)
  }

  /**
   * 获取订单列表
   */
  public async queryOrderList(curPage: number, tatus: number[], keywords?: string): Promise<OrderListResp> {
    return new Promise<OrderListResp>((resolve, reject) => {
      const page: number = curPage;
      const status: number[] = tatus;
      const startIndex = (page - 1) * this.PAGE_SIZE;
      const endIndex = startIndex + this.PAGE_SIZE;
      let list = this._orderList.filter((order) =>
      status.includes(order.orderInfo.status),
      );
      if (keywords) {
        list = list.filter((order) => {
          const titles = order.carGoodsInfo.map((sku) => sku.name);
          Logger.info('titles', JSON.stringify(titles))
          //商品名称或店铺名称或订单号
          return titles.some((title) => title.includes(keywords)) || order.storeInfo.name.includes(keywords) ||
          order.orderInfo.orderNo.includes(keywords);
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
      resolve(res);
    });
  }


  /**
   * 获取订单详情
   */
  public async getDetail(orderId: string): Promise<OrderDetailResp> {
    return new Promise<OrderDetailResp>((resolve, reject) => {
      const order = this._orderList.find(
        (item) => item.orderInfo.orderNo === orderId,
      );
      if (order) {
        const res: OrderDetailResp = {
          code: 0,
          detail: order,
        };

        resolve(res);
      } else {
        // 订单不存在时，应该reject而不是什么都不做
        reject(new Error('Order not found'));
      }

    });
  }

  /**
   * 删除订单
   */
  public async deleteOrder(orderId: string): Promise<BaseResponse> {
    return new Promise<BaseResponse>((resolve, reject) => {
      const index = this._orderList.findIndex(
        (item) => item.orderInfo.orderNo === orderId,
      );
      if (index !== -1) {
        this._orderList.splice(index, 1);
        const resOk: BaseResponse = {
          code: 0,
          msg: '删除成功',
        };
        resolve(resOk);
      } else {
        const res: BaseResponse = {
          code: -1,
          msg: '订单不存在',
        };
        resolve(res);
      }
    });
  }

  /**
   * 更新订单状态
   */
  public async updateOrderStatus(orderId: string, status: number): Promise<BaseResponse> {
    return new Promise<BaseResponse>((resolve, reject) => {
      const index = this._orderList.findIndex(
        (item) => item.orderInfo.orderNo === orderId,
      );
      if (index !== -1) {
        this._orderList[index].orderInfo.status = status;
        if (status === 2) {
          this._orderList[index].orderInfo.payModel = '在线支付'
        }
        const res: BaseResponse = {
          code: 0,
          msg: '更新成功',
        };
        resolve(res);
      } else {
        const res: BaseResponse = {
          code: -1,
          msg: '订单不存在',
        };
        resolve(res);
      }


    });
  }
}


const instance = new OrderService();

export { instance as OrderServiceApi };