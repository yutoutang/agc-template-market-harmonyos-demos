import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { BaseViewModel, RouterMap, RouterUtils } from 'lib_common';
import { AccountApi } from 'lib_account';
import { FormCardRouterModel } from '../common/Types';

@ObservedV2
export class IndexPageViewModel extends BaseViewModel {
  @Trace translateY: string | number = '';
  @Trace tabPaddingBottom: Length = '';
  @Trace firstBackTime: number = 0;
  public pageId: number = -1;
  @Trace formCardRouter: FormCardRouterModel =
    AppStorageV2.connect(FormCardRouterModel, () => new FormCardRouterModel())!;

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

  checkMyComponent() {
    if (this.formCardRouter.targetPage === RouterMap.MY_COMPONENT_PAGE && !this.formCardRouter.cardId) {
      RouterUtils.popToName(RouterMap.INDEX_PAGE, undefined, false);
      RouterUtils.pushPathByName(RouterMap.MY_COMPONENT_PAGE)
    } else if (this.formCardRouter.targetPage === RouterMap.COMPONENT_DETAIL_PAGE && this.formCardRouter.cardId) {
      RouterUtils.popToName(RouterMap.INDEX_PAGE, undefined, false);
      RouterUtils.pushPathByName(RouterMap.COMPONENT_DETAIL_PAGE)
    }
  }

  onReady(context: NavDestinationContext) {
    if (context.pathStack.getAllPathName()?.length) {
      this.pageId = context.pathStack.getAllPathName().length - 1;
    }
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