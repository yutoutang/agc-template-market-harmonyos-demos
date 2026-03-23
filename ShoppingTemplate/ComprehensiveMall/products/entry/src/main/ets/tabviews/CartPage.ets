import {
  iData, routerStack, RouterMap, ProductInfoPageParam, WindowUtil,
} from 'lib_foundation';
import { CartProductInfo, PreOrderInfoReq, PreOrderItem, PriceType } from 'lib_network';
import { ShoppingCart } from 'module_shopping_cart';
import { ProductWaterFlow } from 'product';
import { ShoppingCartVM } from '../viewmodels/CartPageVM';

@ComponentV2
struct CartPage {
  @Param
  public pageName?: string = undefined;
  private vm: ShoppingCartVM = new ShoppingCartVM()
  @Local isChildRoute: boolean = false;

  aboutToAppear(): void {
    this.isChildRoute = Boolean(this.pageName);
    this.vm.isSubPage = this.isChildRoute;
  }

  private handleCheckout(list: CartProductInfo[]): void {
    if (!list.length) {
      WindowUtil.toast('您还没有选择商品')
      return;
    }
    const orders: PreOrderItem[] = [];
    for (let product of list) {
      const preOrderItem: PreOrderItem = {
        skuCode: product.skuCode,
        count: product.count,
        priceType: product.priceType,
      };
      if (product.priceType === PriceType.SECKILL && product.slotId) {
        preOrderItem.seckillInfo = {
          slotId: product.slotId,
          productId: product.productId,
          seckillPrice: product.price,
        }
      }
      orders.push(preOrderItem);
    }
    const preOrderRequest: PreOrderInfoReq = {
      items: orders,
    };
    routerStack.pushPathByName(RouterMap.ORDER_SUBMIT, preOrderRequest);
  }

  build(): void {
    NavDestination() {
      // 购物车页面
      ShoppingCart({
        isChildRoute: this.isChildRoute,
        isLogin: this.vm.global.isLogin,
        isMember: this.vm.global.userInfo.isMember,
        customContentBuilder: () => {
          // 自定义组件  推荐商品
          this.recommendedProductSection();
        },
        onLogin: () => {
          // 登录逻辑
          routerStack.pushPathByName(RouterMap.USER_LOGIN, () => {
            this.vm.global.isLogin = iData.global.isLogin;
          });
        },
        onCardClick: (id: string, slotId?: string) => {
          // 点击购物车卡片
          routerStack.pushPath({
            name: RouterMap.PRODUCT_INFO,
            param: {
              productId: id,
              slotId,
            } as ProductInfoPageParam,
          });
        },
        onBack: () => {
          routerStack.pop();
        },
        onCheckout: (selectedGoodList: CartProductInfo[]) => {
          // 结算逻辑
          this.handleCheckout(selectedGoodList);
        },
      })
    }
    .transition(TransitionEffect.OPACITY.animation({ duration: 600 }))
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background_color_grey'))
    .onShown(() => {
      this.isChildRoute = true;
      if (this.vm.isSubPage) {
        this.vm.refresh(false);
      }
    })
    .onHidden(() => {
      this.isChildRoute = false;
    })
  }

  @Builder
  recommendedProductSection() {
    buildSpecialDivider();
    Column() {
      ProductWaterFlow({
        bgColor: $r('app.color.background_color_grey'),
        handleProductClick: (id) => {
          routerStack.pushPath({
            name: RouterMap.PRODUCT_INFO,
            param: { productId: id } as ProductInfoPageParam,
          });
        },
      })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .padding({ left: 12, right: 12 })
    .backgroundColor($r('app.color.background_color_grey'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}


@Builder
export function buildCartPage(pageName?: string) {
  CartPage({ pageName: pageName })
}

@Builder
function buildSpecialDivider() {
  Row() {
    Column()
      .width(5.5)
      .height(5.5)
      .borderRadius(10)
      .linearGradient({
        angle: -130.6,
        colors: [['#FFE64566', 0.3], ['#00E64566', 1.0]],
      })
      .margin({ right: 10 })
    Column()
      .width(7)
      .height(7)
      .borderRadius(10)
      .linearGradient({
        angle: -130.6,
        colors: [['#FFE64566', 0.3], ['#00E64566', 1.0]],
      })
    Text('推荐商品')
      .fontSize(15)
      .fontColor($r('app.color.font_color_level1'))
      .margin({ left: 15, right: 15 })
    Column()
      .width(7)
      .height(7)
      .borderRadius(10)
      .linearGradient({
        angle: 130.6,
        colors: [['#FFE64566', 0.3], ['#00E64566', 1.0]],
      })
    Column()
      .width(5.5)
      .height(5.5)
      .borderRadius(10)
      .linearGradient({
        angle: 130.6,
        colors: [['#FFE64566', 0.3], ['#00E64566', 1.0]],
      })
      .margin({ left: 10 })
  }
  .width('100%')
  .height(47)
  .alignItems(VerticalAlign.Center)
  .justifyContent(FlexAlign.Center)
}
