import { RouterMap, RouterUtils } from 'lib_common';
import { OrderItem, OrderServiceApi } from 'lib_takeaway_api';
import { OrderActionMap, OrderStatusMap } from '../common/Enums';
import { formatTime } from '../utils/FormatUtils';
import { OrderUtil } from '../utils/OrderUtil';

@ObservedV2
export class OrderInfoPageVM {
  @Trace
  orderItem: OrderItem | undefined = undefined;
  @Trace
  orderNo: string = '';
  @Trace
  isLoading: boolean = false;
  @Trace
  countdown: string | undefined = undefined;
  // 是否展示支付弹窗
  @Trace isShowPay: boolean = false;

  getGapTime(remainingTime: number) {
    const now = new Date().getTime();
    let gap = Math.floor((remainingTime - now) / 1000);
    this.countdown = formatTime(gap);
    const timer = setInterval(() => {
      gap--;
      if (gap < 0) {
        clearInterval(timer);
      }
      this.countdown = formatTime(gap);
    }, 1000);
  }

  async getOrderItem(orderNo: string) {
    this.isLoading = true;
    this.orderNo = orderNo;
    const res = await OrderServiceApi.getDetail(orderNo);
    if (res.code === 0) {
      this.orderItem = res.detail;
      if (res.detail.orderInfo.status === OrderStatusMap.PENDING_PAYMENT) {
        const remainTime = res.detail.orderInfo.remainingTime;
        if (remainTime) {
          this.getGapTime(remainTime);
        }
      }
    }
    this.isLoading = false;
  }

  public handleOrderItem(action: OrderActionMap) {
    if (!this.orderItem) {
      return;
    }
    if (action === OrderActionMap.REVIEW) {
      let onPop: Callback<PopInfo> = async (pop: PopInfo) => {
        await OrderServiceApi.updateOrderStatus(this.orderNo, OrderStatusMap.REVIEWED)
        RouterUtils.pop()
      }
      RouterUtils.pushPathByName(RouterMap.ORDER_SUBMITCOMMENT_PAGE, this.orderItem.orderInfo.orderNo, onPop)
    } else if (action === OrderActionMap.REORDER) {
      const carGoodsInfo = this.orderItem.carGoodsInfo;
      OrderUtil.handleReorder({
        orderNo: this.orderNo,
        storeId: this.orderItem.storeInfo.id,
        data: carGoodsInfo,
      });
    } else if (action === OrderActionMap.IMMEDIATE_PAYMENT) {
      this.isShowPay = true;
    } else {
      OrderUtil.handleOrderAction(action, {
        orderNo: this.orderItem.orderInfo.orderNo,
        storeId: this.orderItem.storeInfo.id,
        callback: () => {
          this.getOrderItem(this.orderNo);
          RouterUtils.pop()
        },
      });
    }
  }
}
