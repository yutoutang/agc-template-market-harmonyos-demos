import {
  LoadingStatus,
  routerStack,
  RouterMap,
  GlobalStateMgr,
  iData,
} from 'lib_foundation';
import { CategoryItem, HomeApis } from 'lib_network';

@ObservedV2
export class HomePageVM {
  public readonly global: GlobalStateMgr = iData.global;
  @Trace
  public loadingStatus: LoadingStatus = LoadingStatus.LOADING;
  @Trace
  public refreshStatus: RefreshStatus = RefreshStatus.Inactive;
  @Trace
  public isRefreshing: boolean = false;
  @Trace
  categoryList: CategoryItem[] = [];

  public onRefreshStateChange(state: RefreshStatus): void {
    this.refreshStatus = state;
    if (state === RefreshStatus.Refresh) {
      this.loadHomePage();
    }
  }

  async loadHomePage(): Promise<void> {
    this.loadingStatus = LoadingStatus.LOADING;
    try {
      const res = await HomeApis.getHomeConfig();
      if (res.code === 0) {
        this.categoryList = res.categoryList;
        this.loadingStatus = LoadingStatus.SUCCESS;
      }
    } catch (e) {
      this.loadingStatus = LoadingStatus.FAIL;
    }
    this.isRefreshing = false;
  }

  public jumpToCategoryPage(id: string) {
    routerStack.pushPathByName(RouterMap.PRODUCT_CATEGORY, id);
  }
}
