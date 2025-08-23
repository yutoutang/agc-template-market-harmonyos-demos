import { paymentService } from '@kit.PaymentKit';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { ActiveOrder, https, OrderType, RepayOrderBody } from 'network';
import { RouterModule, RouterMap } from 'commonlib';
import { OrderStatus } from '../types/Index';

const TAG = '[ActiveOrderDetailVM]';

@ObservedV2
export class ActiveOrderDetailVM {
  @Trace detail: ActiveOrder | undefined = undefined;
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private static _instance: ActiveOrderDetailVM;

  public static get instance() {
    if (!ActiveOrderDetailVM._instance) {
      ActiveOrderDetailVM._instance = new ActiveOrderDetailVM();
    }
    return ActiveOrderDetailVM._instance;
  }

  public getParm() {
    this.detail = RouterModule.getNavParam({ url: RouterMap.ACTIVE_ORDER_DETAIL });
  }

  public jumpSuccessPage(data: ActiveOrder) {
    RouterModule.push({ url: RouterMap.ACTIVE_SUCCESS, param: { details: data } });
  }

  public async toPayOrder(data: ActiveOrder) {
    const body: RepayOrderBody = {
      orderNo: data.orderNo,
      orderType: OrderType.ACTIVE_ORDER,
    };
    this.detail = undefined
    const res = await https.repayOrder(body);
    if (res.code === 0) {
      this.detail = res.data as ActiveOrder
      try {
        paymentService
          .requestPayment(this.context, data.orderStr)
          .then(() => {
            this.jumpSuccessPage(data);
          })
          .catch((error: BusinessError) => {
            // mock支付成功
            this.jumpSuccessPage(data);
          });
      } catch (e) {
        // mock支付成功
        this.jumpSuccessPage(data);
      }
    }
  }
}