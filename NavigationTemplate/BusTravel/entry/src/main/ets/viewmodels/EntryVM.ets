import { TabInfo, RouterModule, PreferenceUtils,Common } from 'common'
import { homeTabInfo } from '../dataModel/HomeTab'


@ObservedV2
export class EntryVM {
  @Trace currentIndex: number = 0;
  @Trace homeTabList: TabInfo[] = homeTabInfo;
  @Trace pageStack: NavPathStack = RouterModule.stack;
  private static _instance: EntryVM;

  // 获取实例
  public static get instance() {
    if (!EntryVM._instance) {
      EntryVM._instance = new EntryVM();
    }
    return EntryVM._instance;
  }
  // 重定向
  redirect() {
    if (!this.isAgreePrivacy()) {
      RouterModule.push({
        url:'SafePage'
      })
    }
  }

  isAgreePrivacy() {
    return PreferenceUtils.getInstance().get(Common.AGREE_PRIVACY_KEY) as boolean;
  }
}