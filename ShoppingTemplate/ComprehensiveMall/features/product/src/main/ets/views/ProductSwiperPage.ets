import {
  BreakpointStorage,
  BreakpointSystem,
  iData,
  RouterMap,
  routerStack,
  WindowUtil,
} from 'lib_foundation'
import { PreOrderInfoReq, ProductApis, ProductCardItem } from 'lib_network'
import { CommonSymbol, NavTitleBar } from 'lib_widget'
import { ProductOperationType, ProductSaleUtil } from 'module_product_detail'
import { ProductResource, ProductShare } from 'module_product_share'
import { CartApi } from 'module_shopping_cart';
import { CardLongTakeDelegate, LongTakeAnimationProperties, LongTakeTransitionParam } from 'module_transition'

@Builder
export function buildProductSwiperPage() {
  ProductSwiperPage()
}

@ComponentV2
export struct ProductSwiperPage {
  @Local
  stack: NavPathStack = new NavPathStack()
  @Local
  dataList: ProductCardItem[] = [];
  @Local
  curIndex: number = 0
  @Local
  isLogin: boolean = iData.global.isLogin;
  @Local
  curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Local
  longTakeSession: LongTakeAnimationProperties = new LongTakeAnimationProperties();
  @Local
  longTakeTransitionParam: LongTakeTransitionParam | undefined = undefined;

  util: ProductSaleUtil = new ProductSaleUtil()

  @Computed
  get curProduct() {
    if (!this.dataList.length) {
      return undefined
    }
    return this.dataList[this.curIndex]
  }

  @Computed
  get productResource() {
    if (!this.curProduct) {
      return undefined
    }
    const resource: ProductResource = {
      image: this.curProduct.banner,
      title: this.curProduct.title,
      price: this.curProduct.price,
      url: `http://test/${this.curProduct.productId}`,
    }
    return resource;
  }

  build() {
    NavDestination() {
      CardLongTakeDelegate({
        longTakeSession:this.longTakeSession
      }){
        Column(){
          this.buildHeader()
          Swiper() {
            ForEach(this.dataList, (card: ProductCardItem) => {
              this.buildProductCard(card)
            }, (card: ProductCardItem) => card.productId)
          }
          .cachedCount(3)
          .backgroundColor($r('app.color.background_color_grey'))
          .layoutWeight(1)
          .vertical(true)
          .autoPlay(false)
          .indicator(false)
          .loop(false)
          .index($$this.curIndex)
          .disableSwipe(false)
          .displayCount(1)
          .nextMargin(32, true)
          .expandSafeArea([SafeAreaType.SYSTEM])
        }
        .height('100%')
      }
    }
    .hideTitleBar(true)
    .onReady((navDestContext: NavDestinationContext) => {
      let param = navDestContext.pathInfo?.param as Record<string, Object>;
      this.longTakeTransitionParam = param.longTakeTransitionParam as LongTakeTransitionParam;
      if (this.longTakeTransitionParam) {
        this.longTakeSession.init(navDestContext, this.longTakeTransitionParam, {
          pop: () => {
            routerStack.pop()
          },
        });
      }
      this.dataList = param.dataList as ProductCardItem[]
      this.initUtil()
    })
    .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
      this.longTakeSession.setNewSize(newValue);
    })
  }

  @Builder
  buildHeader() {
    NavTitleBar({
      title: '推荐商品',
    }) {
      Row({ space: 8 }) {
        CommonSymbol({ src: $r('sys.symbol.cart') })
          .onClick(() => {
            routerStack.pushPath({
              name: RouterMap.PRODUCT_CART,
            })
          })
        if (this.productResource) {
          ProductShare({
            productResource: this.productResource,
          }) {
            CommonSymbol({ src: $r('sys.symbol.share') })
          }
        }
      }
      .justifyContent(FlexAlign.End)
      .layoutWeight(1)
    }
  }

  @Builder
  buildProductCard(card: ProductCardItem) {
    Column() {
      Image(card.banner)
        .width($r('app.string.size_percent_full'))
        .objectFit(ImageFit.Contain)
        .layoutWeight(1)
        .margin({ bottom: $r('app.float.space_l') })
        .onClick(() => {
          routerStack.pushPath({
            name: RouterMap.PRODUCT_INFO,
            param: card.productId,
          })
        })
        .backgroundColor($r('app.color.background_color_grey'))

      Column() {
        Row() {
          Text(card.title)
            .fontColor($r('app.color.font_color_level1'))
            .margin({ right: $r('app.float.space_m') })
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Row() {
            Text('详情')
              .fontColor($r('sys.color.icon_emphasize'))
              .margin({ right: $r('app.float.space_xs') })
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontColor([$r('sys.color.icon_emphasize')])
              .width(12)
              .height(24)
              .fontSize(24)
          }
          .onClick(() => {
            routerStack.pushPath({
              name: RouterMap.PRODUCT_INFO,
              param: card.productId,
            })
          })
        }
        .width($r('app.string.size_percent_full'))
        .margin({ bottom: $r('app.float.space_m') })
        .justifyContent(FlexAlign.Start)

        Row() {
          Text() {
            Span('¥')
              .fontSize($r('app.float.font_size_12'))
              .fontColor($r('app.color.theme_color'))
            Span(card.price.toString())
              .fontSize($r('app.float.font_size_24'))
              .fontColor($r('app.color.theme_color'))
              .fontWeight(FontWeight.Medium)

            Span(' ').letterSpacing(2)
            if (card.dashPrice) {
              Span('¥')
                .fontSize($r('app.float.font_size_12'))
                .decoration({ type: TextDecorationType.LineThrough })
              Span(card.dashPrice.toString())
                .fontSize($r('app.float.font_size_12'))
                .decoration({ type: TextDecorationType.LineThrough })
            }
          }
          .fontColor($r('app.color.font_color_level2'))
          .layoutWeight(1)

          Text(`已售${card.sales}+`)
            .fontColor($r('app.color.font_color_level2'))
            .fontSize($r('app.float.font_size_14'))
        }
        .width($r('app.string.size_percent_full'))
        .margin({ bottom: $r('app.float.space_m') })

        Row() {
          Button('加入购物车')
            .bottomButtonStyle()
            .borderColor($r('app.color.background_color_grey_light'))
            .fontColor($r('app.color.theme_color'))
            .backgroundColor($r('app.color.background_color_grey_light'))
            .borderRadius({
              topLeft: $r('sys.float.corner_radius_level10'),
              bottomLeft: $r('sys.float.corner_radius_level10'),
              topRight: 0,
              bottomRight: 0,
            })
            .onClick(() => {
              this.util.options.productId = card.productId;
              this.util.options.isLogin = this.isLogin;
              this.util.handleButtonClick(ProductOperationType.ADD_TO_CART, true)
            });

          Button('立即购买')
            .bottomButtonStyle()
            .borderColor($r('app.color.theme_color'))
            .backgroundColor($r('app.color.theme_color'))
            .borderRadius({
              topLeft: 0,
              bottomLeft: 0,
              topRight: 20,
              bottomRight: 20,
            })
            .onClick(() => {
              this.util.options.productId = card.productId;
              this.util.options.isLogin = this.isLogin;
              this.util.handleButtonClick(ProductOperationType.PAY_NOW, true)
            });
        }
        .width($r('app.string.size_percent_full'))
        .justifyContent(FlexAlign.End)
      }
      .alignItems(HorizontalAlign.Start)
      .backgroundColor($r('app.color.background_color_white'))
      .padding({
        left: $r('app.float.space_l'),
        right: $r('app.float.space_l'),
      })
      .margin({ bottom: $r('app.float.space_l') })
    }
    .backgroundColor($r('app.color.background_color_white'))
    // .padding({ bottom: $r('app.float.space_l') })
    .margin({ bottom: $r('app.float.space_l') })
  }

  initUtil() {
    this.util.init({
      productId: this.curProduct?.productId ?? '',
      isLogin: this.isLogin,
      handleAddCart: (skuCode, count) => {
        CartApi.addSkuToCart(skuCode, count).then(async () => {
          const newCartData = await CartApi.getCartData()
          iData.global.cartVersion = newCartData.version;
          iData.global.cartTotal = newCartData.total;
          WindowUtil.toast('成功加入购物车');
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
  }
}

@Extend(Button)
function bottomButtonStyle() {
  .fontSize($r('sys.float.Body_M'))
  .borderWidth(1)
  .height(40)
  .type(ButtonType.Normal);
}