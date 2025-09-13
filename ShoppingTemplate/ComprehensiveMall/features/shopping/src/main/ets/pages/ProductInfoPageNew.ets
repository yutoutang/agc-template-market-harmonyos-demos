import { promptAction } from '@kit.ArkUI';
import { iData, routerStack, RouterMap } from 'lib_foundation';
import { NavTitleBar } from 'lib_widget';
import { ProductDetail } from 'module_product_detail';
import { ProductResource, ProductShare } from 'module_product_share';
import { CartApi } from 'module_shopping_cart';
import { PreOrderInfoReq } from 'lib_network';

@ComponentV2
export struct ProductInfoNewPage {
  @Local
  productId: string = '';
  @Local
  isLogin: boolean = iData.global.isLogin;
  @Local
  cartNum: number = iData.global.cartTotal;
  @Local
  productResource: ProductResource | undefined = undefined;

  build() {
    NavDestination() {
      NavTitleBar({
        title: '商品详情',
      }) {
        Row() {
          if (this.productResource) {
            ProductShare({
              customUI: this.shareIconBuilder,
              productResource: this.productResource,
            });
          }
        }
        .justifyContent(FlexAlign.End)
        .layoutWeight(1)
      };

      if (this.productId) {
        ProductDetail({
          stack: routerStack,
          isLogin: this.isLogin,
          productId: this.productId,
          cartProdNum: this.cartNum,
          getProductInfo: (data) => {
            this.productResource = {
              image: data.banners[0],
              title: data.title,
              price: Number(data.price),
              url: `http://test/${data.id}/${data.title}`,
            };
          },
          clickCart: () => {
            routerStack.pushPath({ name: RouterMap.PRODUCT_CART });
          },
          handleAddCart: (skuCode, count) => {
            CartApi.addSkuToCart(skuCode, count).then(async () => {
              const newCartData = await CartApi.getCartData()
              iData.global.cartVersion = newCartData.version;
              iData.global.cartTotal = newCartData.total;
              promptAction.showToast({ message: '成功加入购物车' });
              this.getCartNum();
            });
          },
          handlePayNow: (skuCode, count) => {
            const preOrderRequest: PreOrderInfoReq = {
              items: [{
                skuCode,
                count,
              }],
            };
            routerStack.pushPathByName(RouterMap.ORDER_SUBMIT, preOrderRequest);
          },
          handleNotLogin: () => {
            routerStack.pushPathByName(RouterMap.USER_LOGIN, () => {
              this.isLogin = iData.global.isLogin;
            });
          },
        })
          .layoutWeight(1);
      }
    }
    .hideTitleBar(true)
    .backgroundColor(Color.White)
    .onReady((context) => {
      const params = context.pathInfo.param as string | undefined;
      if (params) {
        this.productId = params;
      }
    })
    .onShown(() => {
      this.getCartNum();
    });
  }

  @Builder
  shareIconBuilder() {
    Image($r('app.media.ic_share'))
      .width(40)
      .height(40);
  }

  async getCartNum() {
    const cartData = await CartApi.getCartData();
    this.cartNum = cartData.total;
  }
}

@Builder
export function buildProductInfoNewPage() {
  ProductInfoNewPage();
}

