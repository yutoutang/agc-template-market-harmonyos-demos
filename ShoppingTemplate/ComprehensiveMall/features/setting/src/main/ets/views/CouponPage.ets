import { RouterMap, routerStack } from 'lib_foundation';
import { NavTitleBar } from 'lib_widget';
import { MyCouponsView } from 'module_coupons';

@Builder
export function buildCouponPage() {
  CouponPage();
}

@ComponentV2
export struct CouponPage {
  build() {
    NavDestination() {
      NavTitleBar({ title: '我的优惠券' })

      MyCouponsView({
        useNow: () => {
          routerStack.pushPath({ name: RouterMap.PRODUCT_CATEGORY });
        },
      }).layoutWeight(1);
    }
    .hideTitleBar(true);
  }
}