import { RouterMap, RouterModule } from 'commonlib';
import { ActiveInfo } from 'network';


const TAG = '[ActiveDetailVM]';


@ObservedV2
export class ActiveDetailVM {
  @Trace activeInfo: ActiveInfo | undefined = undefined;
  private static _instance: ActiveDetailVM;

  public static get instance() {
    if (!ActiveDetailVM._instance) {
      ActiveDetailVM._instance = new ActiveDetailVM();
    }
    return ActiveDetailVM._instance;
  }

  public getActiveInfo() {
    const param: Record<string, ActiveInfo> | undefined = RouterModule.getNavParam({ url: RouterMap.ACTIVE_DETAIL });
    if (param) {
      this.activeInfo = param.activeInfo;
    }
  }
}
