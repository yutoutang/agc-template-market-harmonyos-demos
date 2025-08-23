import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { paymentService } from '@kit.PaymentKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { RouterModule, RouterMap, Logger } from 'commonlib';
import { https, Contacts, PreExplainOrderBody, ExplainOrder } from 'network';
import { Contact } from 'module_person_manage';
import { ExplainDetail } from '../types/Index';


const TAG = '[ExplainOrderPageVM]';


@ObservedV2
export class ExplainOrderPageVM {
  @Trace visitors: Contacts[] = [];
  @Trace delPersonId: string = '';
  @Trace details: ExplainDetail | undefined = undefined;
  // 禁用已经选择的参观人
  @Trace disableId:string[]=[]
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private static _instance: ExplainOrderPageVM;

  public static get instance() {
    if (!ExplainOrderPageVM._instance) {
      ExplainOrderPageVM._instance = new ExplainOrderPageVM();
    }
    return ExplainOrderPageVM._instance;
  }

  public removeVisitor() {
    this.visitors = this.visitors.filter((item) => item.personID !== this.delPersonId);
    this.disableId = this.visitors.map((item)=>item.personID)
  }

  public getExplainDetail() {
    this.details = RouterModule.getNavParam({ url: RouterMap.EXPLAIN_ORDER_PAGE });
  }


  public jumpSuccessPage(data:ExplainOrder) {
    RouterModule.push({ url: RouterMap.EXPLAIN_SUCCESS, param: { details: data } });
  }

  public jumpOrderDetail(order: ExplainOrder) {
    RouterModule.push({ url: RouterMap.EXPLAIN_ORDER_DETAIL, param: order });
  }

  // 重新赋值避免mock时json序列化的问题
  public handleVisitors(data: Contact[]) {
    const resArr = data.map((item) => {
      const obj: Contacts = {
        personID: item.personID,
        cardID: item.cardID,
        cardType: item.cardType,
        name: item.name,
        phone: item.phone,
      };
      this.visitors.push(obj)
    });
    this.disableId = this.visitors.map((item)=>item.personID)
  }


  public async preOrderExplain() {
    if (this.details) {
      const body: PreExplainOrderBody = {
        time: this.details.time,
        timeSegment: this.details.timeSegment,
        totalPrice: (this.details.price + this.details.headsetPrice) * this.visitors.length,
        visitors: this.visitors,
        title: this.details.title,
        price:this.details.price,
        img:this.details.cover,
        language:this.details.language,
        explainType:this.details.name
      };

      const res = await https.preOrderExplain(body);
      if (res.code === 0) {
        try {
          paymentService
            .requestPayment(this.context, res.data.orderStr)
            .then(() => {
              this.jumpSuccessPage(res.data);
            })
            .catch((error: BusinessError) => {
              Logger.error(`failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
              // 默认mock支付成功
              this.jumpSuccessPage(res.data);
            });
        } catch (e) {
          // 默认mock支付成功
          this.jumpSuccessPage(res.data);
        }

      }
    }

  }
}
