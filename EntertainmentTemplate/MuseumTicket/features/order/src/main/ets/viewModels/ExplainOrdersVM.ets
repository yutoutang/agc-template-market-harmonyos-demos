import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { paymentService } from '@kit.PaymentKit';
import { common } from '@kit.AbilityKit';
import { FormatUtil, AccountUtil,RouterModule,RouterMap } from 'commonlib';
import { https, ExplainOrder, CancelOrderRequest, RepayOrderBody, OrderType } from 'network';


const TAG = '[ExplainOrdersVM]';

@ObservedV2
export class ExplainOrdersVM {
  @Trace userId: number = AccountUtil.getUserInfo().id;
  @Trace currentIndex: number = 0;
  @Trace selectedIndex: number = 0;
  @Trace tabList: string[] = [
    '全部',
    '待支付',
    '待使用',
    '已结束',
    '已取消',
  ];
  @Trace orders: ExplainOrder[] = [];
  @Trace isLoading: boolean = false;
  // 将要取消的订单号
  @Trace toDeleteNo: string = '';
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private static _instance: ExplainOrdersVM;

  public static get instance() {
    if (!ExplainOrdersVM._instance) {
      ExplainOrdersVM._instance = new ExplainOrdersVM();
    }
    return ExplainOrdersVM._instance;
  }

  public formatTime(time: number, str: string): number {
    const day = FormatUtil.dateAsISO(new Date(time));
    const detailTime = 'T' + str.split('-')[0] + ':00Z';
    return new Date(day + detailTime).getTime();
  }


  public async getExplainOrders() {
    this.isLoading = true;
    const res = await https.getExplainOrders();
    if (res.code === 0) {
      this.orders = res.data.sort((a, b) => {
        return this.formatTime(a.time, a.timeSegment) - this.formatTime(b.time, b.timeSegment);
      });
      if (this.currentIndex !== 0) {
        this.orders = this.orders.filter((item) => item.status === this.currentIndex.toString());
      }
      this.isLoading = false;
    }
  }

  public async toPayOrder(data:ExplainOrder) {
    const body: RepayOrderBody = {
      orderNo: data.orderNo,
      orderType: OrderType.EXPLAIN_ORDER,
    };
    const res = await https.repayOrder(body);
    if (res.code === 0) {
      try {
        paymentService
          .requestPayment(this.context, data.orderStr)
          .then(() => {
            RouterModule.push({url:RouterMap.EXPLAIN_SUCCESS,param:{details:data}})
          })
          .catch((error: BusinessError) => {
            // 默认mock支付成功
            RouterModule.push({url:RouterMap.EXPLAIN_SUCCESS,param:{details:data}})
          });
      } catch (e) {
        // 支付模块无法拉起时，mock成功
        RouterModule.push({url:RouterMap.EXPLAIN_SUCCESS,param:{details:data}})
      }
    }

  }

  // 取消订单
  public async cancelOrder() {
    const req: CancelOrderRequest = {
      cancelTime: new Date().getTime().toString(),
      userId: this.userId,
      orderNo: this.toDeleteNo,
    };
    const res = await https.cancelExplainOrder(req);
    if (res.code === 0) {
      promptAction.showToast({ message: '取消成功！' });
      this.getExplainOrders();
    }
  }
}