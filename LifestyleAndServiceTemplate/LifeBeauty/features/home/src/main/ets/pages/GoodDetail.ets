import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import {
  CommonConstants,
  GetUserInfoResp,
  GoodInfo,
  CommonUtils,
  LoginButtonType3,
  RouterMap,
  RouterModule,
  IntroType,
  UIBackBtn,
  IntroItem,
  BreakpointModel,
  SimpleGoodInfo,
  OrderType,
  CustomShareModel,
} from 'foundation';
import { TAG_CONSTANT_LIST, ImgDesc } from '../common/Constant';

@Builder
export function GoodDetailBuilder() {
  GoodDetail()
}

@ComponentV2
export struct GoodDetail {
  @Local userInfo: GetUserInfoResp = PersistenceV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local instance: CustomShareModel = AppStorageV2.connect(CustomShareModel, () => new CustomShareModel())!;
  @Local goodInfo: GoodInfo = new GoodInfo();
  @Local titleBgOpacity: number = 0;
  scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    const paramList: Array<GoodInfo> = RouterModule.getNavParam({ url: RouterMap.GOOD_DETAIL });
    if (paramList.length) {
      this.goodInfo = paramList[paramList.length - 1];
    }
    // 设置分享参数
    this.instance.pageName = 'GoodDetail';
    this.instance.goodId = this.goodInfo.id;
    this.instance.goodName = this.goodInfo.title;
    this.instance.goodType = OrderType.GROUP;
  }

  aboutToDisappear(): void {
    // 设置分享参数
    this.instance.pageName = '';
    this.instance.goodName = '';
    this.instance.goodId = 0;
  }

  @Computed
  get isBindPhone() {
    return Boolean(this.userInfo.mobile);
  }

  buildRouteParam() {
    const param = new SimpleGoodInfo();
    param.type = OrderType.GROUP;
    param.id = this.goodInfo.id;
    param.title = this.goodInfo.title;
    param.subTitle = this.goodInfo.subTitle;
    param.vipPrice = this.goodInfo.vipPrice;
    param.image = this.goodInfo.images[0] ?? '';
    param.price = this.goodInfo.price;
    return param;
  }

  jumpOrder() {
    const param = this.buildRouteParam();
    RouterModule.push({ url: RouterMap.SUBMIT_ORDER, param: param });
  }

  @Builder
  Banner() {
    Image(CommonUtils.handleImgUrl(this.goodInfo.images[0]))
      .width(CommonConstants.FULL_PERCENT)
      .height(270)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  GoodSimpleInfo() {
    Column({ space: 16 }) {
      Row({ space: 8 }) {
        Text() {
          Span('￥').fontSize(14)
          Span(CommonUtils.handleCash(this.goodInfo.price) + '').fontSize(20)
        }
        .fontColor('#E84026')
        .fontWeight(500)
        Row() {
          Text($r('app.string.good_detail_member_price')).fontSize(14).fontColor($r('app.color.common_fg_white'))
          Text('￥').fontSize(14).fontColor($r('app.color.common_fg_white'))
          Text(this.goodInfo.vipPrice.toFixed(2)).fontSize(20).fontColor($r('app.color.common_fg_white'))
        }
        .padding({
          top: 4,
          bottom: 4,
          left: 8,
          right: 8,
        })
        .backgroundColor($r('app.color.common_theme_color'))
        .borderRadius(20)
      }.justifyContent(FlexAlign.Start)

      Text(this.goodInfo.title)
        .fontSize(16).fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .maxLines(2)
        .textOverflow({overflow: TextOverflow.Ellipsis})

      Row() {
        ForEach(TAG_CONSTANT_LIST, (v: ImgDesc) => {
          Row({ space: 4 }) {
            Image(v.src).width(16).height(16)
            Text(v.desc).fontSize(12).fontColor($r('sys.color.font_secondary'))
          }
        }, (item: ImgDesc) => JSON.stringify(item))
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      top: 12,
      bottom: 16,
      left: 12,
      right: 12,
    })
    .backgroundColor($r('app.color.common_card_bg'))
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  GoodDetailInfo() {
    Column() {
      Text($r('app.string.good_detail_more_title'))
        .fontSize(18).fontWeight(700).margin({ bottom: 10 })
      Column({space: 4}) {
        Text(this.goodInfo.title).fontSize(14)
        Text(`服务项目：${this.goodInfo.projectNum}个`).fontSize(14)
      }
      .alignItems(HorizontalAlign.Start)

      if (this.goodInfo.intro.length) {
        // 富文本容器显示html
        this.RichContent()
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding({ left: 12, right: 12, top: 24, bottom: 16 })
    .borderRadius(16)
    .backgroundColor(Color.White)
  }

  @Builder
  RichContent() {
    Column({ space: 8 }) {
      ForEach(this.goodInfo.intro, (v: IntroItem) => {
        if (v.type === IntroType.IMAGE && v.value) {
          Image(CommonUtils.handleImgUrl(v.value)).width(CommonConstants.FULL_PERCENT).objectFit(ImageFit.Contain)
            .borderRadius(8)
        } else if (v.type === IntroType.TEXT && v.value) {
          Text(v.value).fontSize(16)
        }
      }, (item: IntroItem) => JSON.stringify(item))

    }.width(CommonConstants.FULL_PERCENT).padding({ top: 16 })

  }

  @Builder
  bottomBar() {
    Row({ space: 16 }) {
      if (this.isBindPhone) {
        Button($r('app.string.buy_good_btn'))
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor($r('app.color.common_theme_color'))
          .layoutWeight(1)
          .onClick(() => {
            this.jumpOrder();
          })
      } else {
        LoginButtonType3({
          onBind: () => {
            this.jumpOrder();
          },
        }).layoutWeight(1)
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.common_card_bg'))
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
      top: 10,
      bottom: 10,
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  titleBuilder() {
    Stack() {
      Row() {
        Text().height(56)
      }
      .opacity(this.titleBgOpacity)
      .backgroundColor(Color.White)
      .width('100%').expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])

      Row({ space: 10 }) {
        UIBackBtn()
        Text('服务详情')
          .fontSize(16)
          .fontWeight(700)
          .height(56)
          .opacity(this.titleBgOpacity)
      }
      .width('100%')

    }
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          Scroll(this.scroller) {
            Stack({alignContent: Alignment.Top}) {
              this.Banner()
              Column({ space: 12 }) {
                // 商品标题卡片
                this.GoodSimpleInfo()
                // 图文详情卡片
                this.GoodDetailInfo();
              }
              .margin({ top: 200 })
              .padding({
                left: this.breakPointModel.pagePadding,
                right: this.breakPointModel.pagePadding,
                bottom: 16,
              })
            }
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
          .width(CommonConstants.FULL_PERCENT)
          .layoutWeight(1)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .onDidScroll(() => {
            this.titleBgOpacity = this.scroller.currentOffset().yOffset / 56;
          })

          this.bottomBar()
        }
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)

        this.titleBuilder()
      }.alignContent(Alignment.Top)
    }
    .backgroundColor($r('app.color.common_page_bg'))
    .hideTitleBar(true)
  }
}
