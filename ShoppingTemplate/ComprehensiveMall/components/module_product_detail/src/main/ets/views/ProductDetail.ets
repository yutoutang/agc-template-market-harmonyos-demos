import { UISkeleton, SkeletonTheme, SkeletonType } from '@hw-agconnect/ui-skeleton';
import { BreakpointSystem, WindowUtil } from 'module_ui_base';
import { Constants } from '../commons/Constants';
import { ProductOperationType } from '../commons/Enums';
import { ProductInfo, ProductReviewItem } from '../commons/Types';
import { ProductInfoCard } from '../components/ProductInfoCard';
import { ProductReviewCard } from '../components/ProductReviewCard';
import { ProductSwiper } from '../components/ProductSwiper';
import { ProductDetailApis } from '../https/Apis';
import { ProductSaleUtil } from '../utils/ProductSaleUtil';

@ComponentV2
export struct ProductDetail {
  @Param
  stack: NavPathStack = new NavPathStack()
  @Param
  productId: string = '';
  @Param
  isLogin: boolean = false;
  @Param
  cartProdNum: number = 0;
  @Param
  isMember: boolean = false;
  @Event
  clickCustomService: () => void
  @Event
  clickCart: () => void;
  @Event
  handleAddCart: (skuCode: string, count: number) => void;
  @Event
  handlePayNow: (skuCode: string, count: number) => void;
  @Event
  handleNotLogin: () => void;
  @Event
  getProductInfo: (data: ProductInfo) => void;
  @Event
  handleClickMemberLink: () => void
  @Local
  isLoading: boolean = false;
  @Local
  reviewList: ProductReviewItem[] = []
  @Local
  reviewNum: number = 0
  util: ProductSaleUtil = new ProductSaleUtil()

  @Monitor('isLogin')
  changeLoginStatus() {
    this.util.options.isLogin = this.isLogin;
  }

  async aboutToAppear() {
    this.isLoading = true;
    WindowUtil.initWindowUtil(this.getUIContext())
    await this.util.init({
      productId: this.productId,
      isLogin: this.isLogin,
      cartProdNum: this.cartProdNum,
      clickCart: this.clickCart,
      handleAddCart: this.handleAddCart,
      handlePayNow: this.handlePayNow,
      handleNotLogin: this.handleNotLogin,
      getProductInfo: this.getProductInfo,
    })
    this.getReviewList()
    this.isLoading = false;
  }

  build() {
    Column() {
      if (this.isLoading) {
        Column() {
          UISkeleton({
            options: [
              { width: '100%', height: 320, type: SkeletonType.RECT },
              { width: 180, height: 30, type: SkeletonType.TEXT },
              { width: '100%', height: 30, type: SkeletonType.TEXT },
            ],
          })
            .height(420)
          UISkeleton({ theme: SkeletonTheme.PARAGRAPH })
        }
        .padding(16)
        .layoutWeight(1)
      } else if (!this.util.options.productInfo) {
        Column() {
          Image($r('app.media.ic_search_empty'))
            .width(120)
            .height(120);
          Text('暂无搜索结果')
            .fontSize(14)
            .fontColor($r('app.color.font_color_level2'));
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        if (BreakpointSystem.isTablet) {
          GridRow({
            columns: {
              lg: 2,
            },
            gutter: 12,
          }) {
            GridCol({ span: 1 }) {
              Column() {
                // 顶部轮播
                ProductSwiper({
                  imgList: this.util.options.productInfo?.banners ?? [],
                });
              }
              .layoutWeight(1)
            }

            GridCol({ span: 1 }) {
              Scroll() {
                Column() {
                  // 基本信息
                  ProductInfoCard({
                    productInfo: this.util.options.productInfo,
                  }).margin({ bottom: 8 });
                  // 会员推广卡片
                  this.memberCardBuilder()
                  // 用户评价
                  this.productReviewBuilder()
                  // 详情介绍
                  this.productDescBuilder();
                };
              }
              .edgeEffect(EdgeEffect.Spring)
              .scrollBar(BarState.Off)
              .layoutWeight(1);
            }
          }
          .backgroundColor($r('app.color.background_color_grey'))
          .layoutWeight(1);
        } else {
          Scroll() {
            Column() {
              // 顶部轮播
              ProductSwiper({
                imgList: this.util.options.productInfo?.banners ?? [],
              });
              // 基本信息
              ProductInfoCard({
                productInfo: this.util.options.productInfo,
              })
              // 会员推广卡片

              this.memberCardBuilder()
              // 用户评价
              this.productReviewBuilder()
              // 详情介绍
              this.productDescBuilder();
            };
          }
          .edgeEffect(EdgeEffect.Spring)
          .scrollBar(BarState.Off)
          .layoutWeight(1);
        }
        Blank();
        // 底部操作栏
        this.bottomOperationBarBuilder();
      }
    }
    .layoutWeight(1)
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Constants.BACKGROUND_COLOR_GREY)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
  }

  @Builder
  memberCardBuilder() {
    Column() {
      if (!this.isMember) {
        Row() {
          SymbolGlyph($r('sys.symbol.bell_fill'))
            .fontSize(24)
            .fontColor([$r('app.color.font_color_level1_invert')])
            .margin({ right: $r('app.string.space_xs') })
          Text('开通会员，享9折优惠！')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.font_color_level1_invert'))

          Blank()
          Button('立即查看')
            .backgroundColor($r('app.color.background_color_white'))
            .fontColor($r('app.color.theme_color'))
            .controlSize(ControlSize.SMALL)
            .onClick(() => {
              this.handleClickMemberLink?.()
            })
        }
        .width('100%')
        .padding($r('app.string.space_m'))
        .borderRadius($r('app.string.border_radius_8'))
        .backgroundColor($r('app.color.theme_color'))
      }
    }
    .padding($r('app.string.space_m'))
    .constraintSize({ minHeight: 12 })
  }

  @Builder
  productDescBuilder() {
    Column() {
      Text('商品详情').chapterTitleStyle();
      if (this.util.options.productInfo?.pictures) {
        ForEach(this.util.options.productInfo.pictures, (item: ResourceStr) => {
          Image(item)
            .width('100%')
            .objectFit(ImageFit.Contain)
            .draggable(false);
        }, (item: ResourceStr) => JSON.stringify(item));
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Constants.BACKGROUND_COLOR)
    .padding({ top: 12, bottom: 12 });
  }

  @Builder
  productReviewBuilder() {
    Column({ space: 16 }) {
      Row() {
        Text() {
          Span('商品评价')
          Span(`(${this.reviewNum})`)
        }
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)

        Text('更多')
          .fontSize($r('app.string.font_size_12'))
          .fontColor(Constants.FONT_COLOR_LEVEL3)
          .margin({ right: $r('app.string.space_xs') })
        Image($r('app.media.ic_arrow_right'))
          .height(16)
          .fillColor(Constants.FONT_COLOR_LEVEL3)
      }
      .width($r('app.string.size_percent_full'))
      .justifyContent(FlexAlign.SpaceBetween)

      if (this.reviewList.length) {
        Column({ space: 16 }) {
          ForEach(this.reviewList, (reviewItem: ProductReviewItem) => {
            ProductReviewCard({ reviewItem })
          }, (item: ProductReviewItem, index: number) => index + '_' + item.date)
        }
      } else {
        Text('暂无商品评价')
          .fontSize($r('app.string.font_size_14'))
          .fontColor(Constants.FONT_COLOR_LEVEL2)
          .height(36)
      }
    }
    .padding($r('app.string.space_l'))
    .margin({ bottom: 8 })
    .backgroundColor(Constants.BACKGROUND_COLOR)
    .onClick(() => {
      if (this.reviewList.length) {
        this.stack.pushPath({ name: Constants.REVIEW_ROUTER, param: this.productId })
      }
    })
    .hitTestBehavior(HitTestMode.Default)
  }

  @Builder
  bottomOperationBarBuilder() {
    Row() {
      Column() {
        SymbolGlyph($r('sys.symbol.service'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
          .margin({ bottom: 2 });

        Text('客服')
          .fontSize(12)
          .fontColor(Constants.FONT_COLOR_LEVEL1);
      }
      .onClick(() => {
        this.clickCustomService?.()
      })
      .margin({ right: $r('app.string.space_l') })

      Badge({
        count: this.isLogin ? this.cartProdNum : 0,
        style: {
          badgeSize: 16,
          badgeColor: Constants.THEME_COLOR,
          fontWeight: FontWeight.Medium,
          fontSize: 10,
        },
        position: BadgePosition.RightTop,
      }) {
        Column() {
          SymbolGlyph($r('sys.symbol.cart'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
            .margin({ bottom: 2 });
          Text('购物车')
            .fontSize(12)
            .fontColor(Constants.FONT_COLOR_LEVEL1);
        }
        .padding(4);
      }
      .onClick(() => {
        this.clickCart?.();
      });


      Blank();
      Button('加入购物车')
        .bottomButtonStyle(BreakpointSystem.isTablet)
        .borderColor(Constants.BACKGROUND_COLOR_GREY_2)
        .fontColor(Constants.THEME_COLOR)
        .backgroundColor(Constants.BACKGROUND_COLOR_GREY_2)
        .borderRadius({
          topLeft: $r('sys.float.corner_radius_level10'),
          bottomLeft: $r('sys.float.corner_radius_level10'),
          topRight: 0,
          bottomRight: 0,
        })
        .onClick(() => {
          this.util.handleButtonClick(ProductOperationType.ADD_TO_CART);
        });

      Button('立即购买')
        .bottomButtonStyle(BreakpointSystem.isTablet)
        .borderColor(Constants.THEME_COLOR)
        .backgroundColor(Constants.THEME_COLOR)
        .borderRadius({
          topLeft: 0,
          bottomLeft: 0,
          topRight: $r('sys.float.corner_radius_level10'),
          bottomRight: $r('sys.float.corner_radius_level10'),
        })
        .onClick(() => {
          this.util.handleButtonClick(ProductOperationType.PAY_NOW);
        });
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 16,
    })
    .backgroundColor(Constants.BACKGROUND_COLOR)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  async getReviewList() {
    const res = await ProductDetailApis.getProductReviewList(this.productId, 1)
    this.reviewList = res.reviewList.slice(0, 2);
    this.reviewNum = res.total;
  }
}

@Extend(Text)
function chapterTitleStyle() {
  .textIndent(16)
  .fontColor(Constants.FONT_COLOR_LEVEL1)
  .fontWeight(FontWeight.Bold)
  .margin({ bottom: 16 });
}

@Extend(Button)
function bottomButtonStyle(isTablet: boolean = false) {
  .fontSize($r('sys.float.Body_M'))
  .borderWidth(1)
  .width(isTablet ? 200 : 'auto')
  .height(40)
  .type(ButtonType.Normal);
}