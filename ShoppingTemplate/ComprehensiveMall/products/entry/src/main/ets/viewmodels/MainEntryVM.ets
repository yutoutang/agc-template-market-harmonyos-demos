import { common } from '@kit.AbilityKit';
import { iData, routerStack, WindowUtil } from 'lib_foundation';
import { MemberStatusUtil } from 'membership';
import { CartApi } from 'module_shopping_cart';

@ObservedV2
export class MainEntryVM {
  // 路由栈实例
  @Trace navStack: NavPathStack = routerStack;
  // 当前页签
  @Trace curIndex: number = 0;
  @Trace firstBackTime: number = 0;

  public initData() {
    if (iData.global.isLogin) {
      CartApi.getCartData().then((cartDto) => {
        iData.global.cartVersion = cartDto.version;
        iData.global.cartTotal = cartDto.total;
      });
      MemberStatusUtil.queryPurchase(WindowUtil.globalContext as common.UIAbilityContext).then((list) => {
        if (list.nonRenewList.length) {
          iData.global.userInfo.isMember = true
        }
      })
    }
  }
}
