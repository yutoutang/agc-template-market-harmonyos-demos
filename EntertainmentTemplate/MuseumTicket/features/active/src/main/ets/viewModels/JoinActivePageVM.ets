import { promptAction } from '@kit.ArkUI';
import { paymentService } from '@kit.PaymentKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger, RouterMap, RouterModule } from 'commonlib';
import { ActiveInfo, Contacts, PreActiveOrderBody, https, ActiveOrder } from 'network';
import { Contact } from 'module_person_manage';


const TAG = '[JoinActivePageVM]';


@ObservedV2
export class JoinActivePageVM {
  @Trace activeInfo: ActiveInfo | undefined = undefined;
  @Trace contactName: string = '';
  @Trace contactPhone: string = '';
  @Trace visitors: Contacts[] = [];
  @Trace delPersonId: string = '';
  @Trace disableId:string[]=[]
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private reg = /^[1][3,4,5,6,7,8,9][0-9]{9}$/;
  private static _instance: JoinActivePageVM;

  public static get instance() {
    if (!JoinActivePageVM._instance) {
      JoinActivePageVM._instance = new JoinActivePageVM();
    }
    return JoinActivePageVM._instance;
  }

  public getActiveInfo() {
    const param: Record<string, ActiveInfo> | undefined = RouterModule.getNavParam({ url: RouterMap.Join_Active_Page });
    if (param) {
      this.activeInfo = param.activeInfo;
    }
  }

  public removeVisitor() {
    this.visitors = this.visitors.filter((item) => item.personID !== this.delPersonId);
    this.disableId = this.visitors.map((item)=>item.personID)
  }

  public isValidate(): boolean {
    if (!this.contactName) {
      promptAction.showToast({ message: '请填写活动联系人姓名！' });
      return false;
    }

    if (!this.contactPhone) {
      promptAction.showToast({ message: '请填写活动联系人电话！' });
      return false;
    }

    if (!this.reg.test(this.contactPhone)) {
      promptAction.showToast({ message: '请正确填写活动联系人电话！' });
      return false;
    }

    if (!this.visitors.length) {
      promptAction.showToast({ message: '请添加参与活动的人员！' });
      return false;
    }
    return true;
  }

  // 跳转成功页
  public toSuccessPage(data:ActiveOrder) {
    RouterModule.push({
      url: RouterMap.ACTIVE_SUCCESS,
      param: { details:data },
    });
  }

  // 跳转详情页
  public toDetailPage(data: ActiveOrder) {
    RouterModule.push({ url: RouterMap.ACTIVE_ORDER_DETAIL, param: data });
  }

  // 重新赋值避免mock时json序列化的问题
  public handleVisitors(arr: Contact[]) {
    const resArr = arr.map((item) => {
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

  public async preActiveOrder() {
    if (this.activeInfo) {
      const body: PreActiveOrderBody = {
        totalPrice: this.visitors.length * this.activeInfo.deposit,
        visitors: this.visitors,
        contactName: this.contactName,
        contactPhone: this.contactPhone,
        title: this.activeInfo.title,
        activeId: this.activeInfo.activeId,
        activeTime: this.activeInfo.time,
      };
      const res = await https.preOrderActive(body);
      if (res.code === 0) {
        try {
          paymentService
            .requestPayment(this.context, res.data.orderStr)
            .then(() => {
              this.toSuccessPage(res.data);
            })
            .catch((error: BusinessError) => {
              Logger.error(`failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
              //  默认mock支付成功
              this.toSuccessPage(res.data)
            });
        }catch (e) {
          //  默认mock支付成功
          this.toSuccessPage(res.data)
        }
      }
    }

  }
}