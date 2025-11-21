import { promptAction } from '@kit.ArkUI';
import { BreakpointSystem, BreakpointTypeEnum, iData, routerStack } from 'lib_foundation';
import { CartApi } from 'module_shopping_cart';

@ObservedV2
export class MainEntryVM {
  // 路由栈实例
  @Trace navStack: NavPathStack = routerStack;
  // 当前页签
  @Trace curIndex: number = 0;
  @Trace firstBackTime: number = 0;

  @Computed
  get isTablet(){
    return BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.LG
  }

  public handleBackPressed() {
    let nowTime = Date.now();
    if (nowTime - this.firstBackTime < 1500) {
      return false;
    } else {
      this.firstBackTime = nowTime;
      promptAction.showToast({ message: '再按一次退出' });
      return true;
    }
  }

  public initData() {
    if (iData.global.isLogin) {
      CartApi.getCartData().then((cartDto) => {
        iData.global.cartVersion = cartDto.version;
        iData.global.cartTotal = cartDto.total;
      });
    }
  }
}
