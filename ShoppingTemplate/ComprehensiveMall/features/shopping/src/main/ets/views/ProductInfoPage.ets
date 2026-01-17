import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast'
import { iData, routerStack, RouterMap, WindowUtil, BreakpointSystem } from 'lib_foundation';
import { CommonConfirmDialog, CommonSymbol, CustomServiceSheet, NavTitleBar } from 'lib_widget';
import { ProductDetail } from 'module_product_detail';
import { CartApi } from 'module_shopping_cart';
import { PreOrderInfoReq, ProductApis } from 'lib_network';
import { SharePicker, ShareRecordData } from 'aggregated_share';

@ComponentV2
export struct ProductInfoNewPage {
  @Local
  productId: string = 'product_10001';
  @Local
  isLogin: boolean = iData.global.isLogin;
  @Local
  cartNum: number = iData.global.cartTotal;
  @Local
  isMember: boolean = iData.global.userInfo.isMember
  @Local
  collectedStatus: boolean = false
  @Local
  shareOptions: ShareRecordData = { title: '' }

  build() {
    NavDestination() {
      NavTitleBar({
        title: '商品详情',
      }) {
        Row({ space: 16 }) {

          if (this.shareOptions.title) {
            CommonSymbol({
              src: this.collectedStatus ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'),
              color: this.collectedStatus ? $r('app.color.theme_color') : $r('sys.color.font_primary'),
            })
              .onClick(() => {
                this.changeCollectStatus()
              })

            Image($r('app.media.ic_share'))
              .width(40)
              .height(40)
              .onClick(() => {
                const picker: SharePicker = new SharePicker(this.shareOptions);
                picker.show();
              })
          }
        }
        .justifyContent(FlexAlign.End)
        .layoutWeight(1)
      };

      if (this.productId) {
        ProductDetail({
          stack: routerStack,
          isLogin: this.isLogin,
          isMember: false,
          productId: this.productId,
          cartProdNum: this.cartNum,
          getProductInfo: (data) => {
            this.shareOptions = {
              coverUrl: data.banners[0],
              title: data.title,
              landingPageUrl: `http://test/${data.id}`,
            };
          },
          clickCustomService: () => {
            CustomServiceSheet.show()
          },
          clickCart: () => {
            routerStack.pushPath({ name: RouterMap.PRODUCT_CART });
          },
          handleAddCart: (skuCode, count) => {
            CartApi.addSkuToCart({ skuCode, count }).then(async () => {
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
          handleClickMemberLink: () => {
            routerStack.pushPathByName(RouterMap.USER_MEMBER_SUBSCRIPTION, undefined)
          },
        })
          .layoutWeight(1);
      }
    }
    .hideTitleBar(true)
    .backgroundColor(BreakpointSystem.isTablet ?
      $r('app.color.background_color_grey') :
      $r('app.color.background_color_white'))
    .onReady((context) => {
      const params = context.pathInfo.param as string | undefined;
      if (params) {
        this.productId = params;
        this.getCollectedStatus(params)
        ProductApis.addProductViewHistory(params)
      }
    })
    .onShown(() => {
      this.getCartNum();
      this.isLogin = iData.global.isLogin;
      this.isMember = iData.global.userInfo.isMember;
    })
  }

  async getCartNum() {
    const cartData = await CartApi.getCartData();
    this.cartNum = cartData.total;
  }

  async getCollectedStatus(id: string) {
    const res = await ProductApis.getProductCollectStatus(id)
    if (res.code === 0 && res.status) {
      this.collectedStatus = true
    }
  }

  async changeCollectStatus() {
    if (!this.collectedStatus) {
      const res = await ProductApis.collectProduct(this.productId)
      if (res.code === 0) {
        WindowUtil.toast('收藏商品成功！')
        this.collectedStatus = true
      }
    } else {
      CommonConfirmDialog.show({
        content: '是否确认取消收藏该商品？',
        confirm: async () => {
          const res = await ProductApis.cancelCollectProduct([this.productId])
          if (res.code === 0) {
            WindowUtil.toast('取消收藏成功！')
            this.collectedStatus = false;
          }
        },
      })
    }
  }
}

@Builder
export function buildProductInfoNewPage() {
  ProductInfoNewPage();
}

