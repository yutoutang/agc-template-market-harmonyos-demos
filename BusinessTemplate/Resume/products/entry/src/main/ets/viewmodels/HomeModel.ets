import { TAB_CONFIG } from '../constants/constants';
import { TabSingleItem } from './TabSingleItem';

@ObservedV2
export class HomeModel {
  @Trace curIndex: number = 0;

  // 监听curIndex变化，同步到AppStorage
  @Monitor('curIndex')
  onCurIndexChange() {
    AppStorage.setOrCreate('currentTabIndex', this.curIndex)
  }
  public controller: TabsController = new TabsController();
  public tabList: TabSingleItem[] = TAB_CONFIG;
  private static _instance: HomeModel;

  public static get instance() {
    if (!HomeModel._instance) {
      HomeModel._instance = new HomeModel();
      AppStorage.setOrCreate('currentTabIndex', 0)
    }
    return HomeModel._instance;
  }
}