import { RouterModule, RouterMap } from 'commonlib';
import { Contacts,ExplainOrder } from 'network';



const TAG = '[ExplainSuccessVM]';


@ObservedV2
export class ExplainSuccessVM {
  @Trace details: ExplainOrder | undefined = undefined;
  private static _instance: ExplainSuccessVM;

  public static get instance() {
    if (!ExplainSuccessVM._instance) {
      ExplainSuccessVM._instance = new ExplainSuccessVM();
    }
    return ExplainSuccessVM._instance;
  }



  public getParams() {
    const params: Record<string, ExplainOrder> | undefined =
      RouterModule.getNavParam({ url: RouterMap.EXPLAIN_SUCCESS });
    if (params) {
      this.details = params.details as ExplainOrder;
    }
  }
}
