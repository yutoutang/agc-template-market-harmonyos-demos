import { CommonConstants } from 'lib_common';
import { OrderInfo, OrderServiceApi } from 'lib_takeaway_api';
import { formatHourTime } from '../utils/FormatUtils';
import { OrderListPageVM } from '../viewModels/OrderListPageVM';

@ComponentV2
export struct OrderCountdown {
  @Param @Require orderInfo: OrderInfo
  @Param @Require vm: OrderListPageVM
  @Local countdownNum: number = 0;
  @Local countdownNumStr: string = '';

  aboutToAppear(): void {
    //初始化检查
    this.initCheck()
    this.countdownNum = (this.orderInfo.orderTime + 15 * 60 * 1000 - Date.now()) / 1000;
    this.countdownNumStr = formatHourTime(this.countdownNum)
    //开启读秒
    this.countdownOrder()
  }

  build() {
    Row() {
      Text(`将在${this.countdownNumStr}后自动取消`)
        .padding({ left: CommonConstants.SPACE_S })
    }
  }

  countdownOrder() {
    let interval = setInterval(() => {
      this.countdownNum--; // 变量在变化
      if (this.countdownNum <= 0) {
        clearInterval(interval);
        OrderServiceApi.updateOrderStatus(this.orderInfo.orderNo, 1)
        this.vm.refreshOrderList()
      }
      this.countdownNumStr = formatHourTime(this.countdownNum)
    }, 1000);
  }

  initCheck() {
    if (this.orderInfo.remainingTime !== undefined && this.orderInfo.remainingTime <= this.orderInfo.orderTime) {
      OrderServiceApi.updateOrderStatus(this.orderInfo.orderNo, 1)
      this.vm.refreshOrderList()
    }
  }
}
