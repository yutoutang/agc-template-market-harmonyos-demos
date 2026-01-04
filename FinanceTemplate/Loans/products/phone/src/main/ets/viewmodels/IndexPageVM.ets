import { promptAction } from '@kit.ArkUI';
import { BaseViewModel } from 'lib_common';
import { AccountApi } from 'lib_account';


@ObservedV2
export class IndexPageViewModel extends BaseViewModel {
  @Trace translateY: string | number = '';
  @Trace tabPaddingBottom: Length = '';
  @Trace firstBackTime: number = 0;
  public pageId: number = -1;


  @Monitor('tabModel.showTabBar')
  onChangeShowTabBar(monitor: IMonitor) {
    let isShowCustomTabBar = monitor.value()?.now as boolean
    if (isShowCustomTabBar) {
      this.translateY = ''
    } else {
      this.translateY = '100%'
    }
  }

  refreshUserInfo() {
    new AccountApi().queryUserInfo();
  }

  onReady(context: NavDestinationContext) {
    if (context.pathStack.getAllPathName()?.length) {
      this.pageId = context.pathStack.getAllPathName().length - 1;
    }
  }

  onDisAppear() {
  }

  onBackPressed() {

    let nowTime = Date.now();
    if (nowTime - this.firstBackTime < 1500) {
      return false;
    } else {
      this.firstBackTime = nowTime;
      promptAction.showToast({ message: '再按一次退出' });
      return true;
    }
  }
}