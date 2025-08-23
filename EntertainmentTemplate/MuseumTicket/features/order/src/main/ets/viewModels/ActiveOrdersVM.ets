import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { paymentService } from '@kit.PaymentKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ActiveOrder, https, CancelOrderRequest, RepayOrderBody, OrderType } from 'network';
import { AccountUtil, RouterModule, RouterMap } from 'commonlib';


const TAG = '[ActiveOrdersVM]';

@ObservedV2
export class ActiveOrdersVM {
  @Trace userId: number = AccountUtil.getUserInfo().id;
  @Trace currentIndex: number = 0;
  @Trace selectedIndex: number = 0;
  @Trace tabList: string[] = [
    '全部',
    '待支付',
    '待参加',
    '已结束',
    '已取消',
  ];
  @Trace orders: ActiveOrder[] = [];
  @Trace isLoading: boolean = false;
  @Trace delNo: string = '';
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private static _instance: ActiveOrdersVM;

  public static get instance() {
    if (!ActiveOrdersVM._instance) {
      ActiveOrdersVM._instance = new ActiveOrdersVM();
    }
    return ActiveOrdersVM._instance;
  }

  public async getActiveOrders() {
    this.isLoading = true;
    const res = await https.getActiveOrders();
    if (res.code === 0) {
      this.orders = res.data;
      if (this.currentIndex !== 0) {
        this.orders = this.orders.filter((item) => item.status === this.currentIndex.toString());
      }
      this.isLoading = false;
    }
  }

  public async toPayOrder(data: ActiveOrder) {
    const body: RepayOrderBody = {
      orderNo: data.orderNo,
      orderType: OrderType.ACTIVE_ORDER,
    };
    const res = await https.repayOrder(body);
    if (res.code === 0) {
      try {
        paymentService
          .requestPayment(this.context, data.orderStr)
          .then(() => {
            RouterModule.push({ url: RouterMap.ACTIVE_SUCCESS, param: { details: data } });
          })
          .catch((error: BusinessError) => {
            // mock支付成功
            RouterModule.push({ url: RouterMap.ACTIVE_SUCCESS, param: { details: data } });
          });
      } catch (e) {
        // mock支付成功
        RouterModule.push({ url: RouterMap.ACTIVE_SUCCESS, param: { details: data } });
      }
    }

  }

  public async cancelActiveOrder() {
    const requestBody: CancelOrderRequest = {
      userId: this.userId,
      cancelTime: new Date().getTime().toString(),
      orderNo: this.delNo,
    };
    const res = await https.cancelActiveOrder(requestBody);
    if (res.code === 0) {
      promptAction.showToast({ message: '取消成功！' });
      this.getActiveOrders();
    }
  }
}