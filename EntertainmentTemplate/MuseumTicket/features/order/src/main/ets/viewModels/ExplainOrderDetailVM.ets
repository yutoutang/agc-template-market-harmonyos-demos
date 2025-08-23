import { paymentService } from '@kit.PaymentKit';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { RouterModule, RouterMap } from 'commonlib';
import { ExplainOrder, https, OrderType, RepayOrderBody } from 'network';
import { OrderStatus } from '../types/Index';


const TAG = '[ExplainOrderDetailVM]';

@ObservedV2
export class ExplainOrderDetailVM {
  @Trace detail: ExplainOrder | undefined = undefined;
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private static _instance: ExplainOrderDetailVM;

  public static get instance() {
    if (!ExplainOrderDetailVM._instance) {
      ExplainOrderDetailVM._instance = new ExplainOrderDetailVM();
    }
    return ExplainOrderDetailVM._instance;
  }

  public getParm() {
    this.detail = RouterModule.getNavParam({ url: RouterMap.EXPLAIN_ORDER_DETAIL });
  }

  public jumpSuccess(data: ExplainOrder) {
    RouterModule.push({ url: RouterMap.EXPLAIN_SUCCESS, param: { details: data } });
  }

  public async toPayOrder(data: ExplainOrder) {
    const body: RepayOrderBody = {
      orderNo: data.orderNo,
      orderType: OrderType.EXPLAIN_ORDER,
    };
    this.detail = undefined
    const res = await https.repayOrder(body);
    if (res.code === 0) {
      this.detail = res.data as  ExplainOrder
      try {
        paymentService
          .requestPayment(this.context, data.orderStr)
          .then(() => {
            this.jumpSuccess(data);
          })
          .catch((error: BusinessError) => {
            // 默认mock支付成功
            this.jumpSuccess(data);
          });
      } catch (e) {
        // 支付模块无法拉起时，mock成功
        this.jumpSuccess(data);
      }
    }
  }
}