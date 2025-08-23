import { RouterMap, RouterModule } from 'commonlib';
import { ActiveOrder, ActiveInfo, Contacts, https } from 'network';


const TAG = '[ActiveSuccessVM]';


@ObservedV2
export class ActiveSuccessVM {
  @Trace activeInfo: ActiveInfo | undefined = undefined;
  @Trace visitors: Contacts[] = [];
  @Trace details: ActiveOrder | undefined = undefined;
  private static _instance: ActiveSuccessVM;

  public static get instance() {
    if (!ActiveSuccessVM._instance) {
      ActiveSuccessVM._instance = new ActiveSuccessVM();
    }
    return ActiveSuccessVM._instance;
  }


  public async getActiveInfo() {
    const param: Record<string, ActiveOrder> | undefined =
      RouterModule.getNavParam({ url: RouterMap.ACTIVE_SUCCESS });
    if (param) {
      this.details = param.details as ActiveOrder;
      this.visitors = this.details.visitors as Contacts[];
      const res = await https.getActiveInfo();
      if (res.code === 0 && this.details) {
        this.activeInfo = res.data.find((item) => item.activeId === this.details?.activeId);
      }
    }
  }
}
