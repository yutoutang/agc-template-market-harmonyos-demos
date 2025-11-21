import {
  iData,
  routerStack,
  RouterMap,
  Style,
} from 'lib_foundation';
import { Product, ShoppingCart } from 'module_shopping_cart';
import { promptAction } from '@kit.ArkUI';
import { CartPageVM } from '../viewmodels/CartPageVM';
import { PreOrderInfoReq, PreOrderItem } from 'lib_network';
import { ProductWaterFlow } from 'product';

@ComponentV2
struct CartPage {
  @Param
  public pageName?: string = undefined;
  private vm: CartPageVM = new CartPageVM()
  @Local isChildRoute: boolean = false;

  aboutToAppear(): void {
    this.isChildRoute = Boolean(this.pageName);
    this.vm.isSubPage = this.isChildRoute;
  }

  private handleCheckout(list: Product[]): void {
    if (!list.length) {
      promptAction.showToast({ message: '您还没有选择商品' });
      return;
    }
    const orders: PreOrderItem[] = [];
    for (let product of list) {
      const preOrderItem: PreOrderItem = {
        skuCode: product.skuCode,
        count: product.count,
      };
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
        customContentBuilder: () => {
          // 自定义组件  推荐商品
          this.recommendedProductSection();
        },
        onLogin: () => {
          // 登录逻辑
          routerStack.pushPathByName('HuaweiQuickLoginPage', () => {
            this.vm.global.isLogin = iData.global.isLogin;
          });
        },
        onCardClick: (id: string) => {
          // 点击购物车卡片
          routerStack.pushPath({
            name: RouterMap.PRODUCT_INFO,
            param: id,
          });
        },
        onBack: () => {
          routerStack.pop();
        },
        onCheckout: (selectedGoodList: Product[]) => {
          // 结算逻辑
          this.handleCheckout(selectedGoodList);
        },
      })
    }
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
        bgColor: Style.BACKGROUND_COLOR_GREY,
        handleProductClick: (id) => {
          routerStack.pushPath({
            name: RouterMap.PRODUCT_INFO,
            param: id,
          });
        },
      })
        .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.BOTTOM])
    }
    .padding({ left: 12, right: 12 })
    .backgroundColor($r('app.color.background_color_grey'))
    .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.BOTTOM])
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
      .fontColor('#E6000000')
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
