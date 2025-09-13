import { RouterMap, routerStack } from 'lib_foundation';
import { OrderApis, OrderItem } from 'lib_network';
import { OrderActionMap, OrderShipmentMap, OrderStatusMap } from '../common/Enums';
import { UpdateAddressSheetOptions } from '../pages/UpdateAddressSheet';
import { formatTime } from '../utils';
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

  @Computed
  get enableEditAddress() {
    if (this.orderItem) {
      const status = this.orderItem.orderInfo.status;
      if (this.orderItem.orderInfo.receivingMethod === OrderShipmentMap.SELF_PICK_UP) {
        return false;
      }
      if (
        status === OrderStatusMap.PENDING_PAYMENT ||
          status === OrderStatusMap.PENDING_SHIPMENT
      ) {
        return true;
      }
    }
    return false;
  }

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
    const res = await OrderApis.getDetail(orderNo);
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
    if (action === OrderActionMap.UPDATE_ADDRESS) {
      routerStack.pushPath(
        {
          name: RouterMap.ORDER_UPDATE_ADDRESS,
          param: {
            originalAddress: this.orderItem.orderInfo.addressInfo,
            orderNo: this.orderNo,
            handleSubmitSuccess: () => {
              routerStack.pop();
              this.getOrderItem(this.orderNo);
            },
          } as UpdateAddressSheetOptions,
        },
        false,
      );
    } else if (action === OrderActionMap.REVIEW) {
      routerStack.pushPath({
        name: RouterMap.ORDER_REVIEW_CREATE,
        param: this.orderItem,
        onPop: () => {
          this.getOrderItem(this.orderNo);
        },
      });
    } else if (action === OrderActionMap.REORDER) {
      const skuList = this.orderItem.skuInfo;
      OrderUtil.handleReorder({
        orderNo: this.orderNo,
        data: skuList,
      });
    } else if (action === OrderActionMap.VIEW_REVIEW) {
      OrderUtil.handleViewReview({
        orderNo: this.orderNo,
        data: this.orderItem,
      })
    } else {
      OrderUtil.handleOrderAction(action, {
        orderNo: this.orderItem.orderInfo.orderNo,
        callback: () => {
          this.getOrderItem(this.orderNo);
        },
      });
    }
  }

  openEditSheet() {
    routerStack.pushPath(
      {
        name: RouterMap.ORDER_UPDATE_ADDRESS,
        param: {
          originalAddress: this.orderItem?.orderInfo.addressInfo,
          orderNo: this.orderNo,
          handleSubmitSuccess: () => {
            routerStack.pop();
            this.getOrderItem(this.orderNo);
          },
        } as UpdateAddressSheetOptions,
      },
      false,
    );
  }
}
