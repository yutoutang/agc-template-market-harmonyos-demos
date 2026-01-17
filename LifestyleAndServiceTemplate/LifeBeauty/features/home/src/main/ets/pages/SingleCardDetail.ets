import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import {
  BreakpointModel,
  CommonConstants,
  CommonUtils,
  CustomShareModel,
  GetUserInfoResp,
  IntroItem,
  IntroType,
  LoginButtonType5,
  OrderType,
  RouterMap,
  RouterModule,
  SimpleGoodInfo,
  SingleCardInfo,
  UIBackBtn,
} from 'foundation'
import { RuleID, ALIGN_RULE_CATEGORY, ALIGN_RULE_COUNT, ALIGN_RULE_DIVIDER } from '../common/Constant'
import { StoreList } from '../components/StoreList';
import { HomeBaseVM } from '../viewmodel/HomeBaseVM';

@Builder
export function SingleCardDetailBuilder() {
  SingleCardDetail()
}

@Extend(Column)
function cardContainer() {
  .width('100%')
  .padding({
    top: 24,
    bottom: 12,
    left: 12,
    right: 12,
  })
  .borderRadius(16)
  .backgroundColor(Color.White)
  .alignItems(HorizontalAlign.Start)
}

@ComponentV2
export struct SingleCardDetail {
  homeVM: HomeBaseVM = HomeBaseVM.instance;
  @Local cardInfo: SingleCardInfo = new SingleCardInfo();
  @Local isShowStoreSheet: boolean = false;
  @Local userInfo: GetUserInfoResp = PersistenceV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local instance: CustomShareModel = AppStorageV2.connect(CustomShareModel, () => new CustomShareModel())!;
  @Local titleBgOpacity: number = 0;
  scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    const paramList: Array<SingleCardInfo> = RouterModule.getNavParam({ url: RouterMap.SINGLE_CARD_DETAIL });
    if (paramList.length) {
      this.cardInfo = paramList[paramList.length - 1];
    }
    // 设置分享参数
    this.instance.pageName = 'SingleCardDetail';
    this.instance.goodId = this.cardInfo.id;
    this.instance.goodName = this.cardInfo.title;
    this.instance.goodType = OrderType.SINGLE_CARD;
  }

  aboutToDisappear(): void {
    // 设置分享参数
    this.instance.pageName = '';
    this.instance.goodName = '';
    this.instance.goodId = 0;
  }

  @Computed
  get storeDesc() {
    const distance = this.homeVM.storeList[0].distance;
    let distanceStr = distance ? `最近${distance}·` : '';
    return `门店：${distanceStr}${this.homeVM.storeList[0].storeName}等${this.homeVM.storeList.length}家门店适用`;
  }

  @Computed
  get buttonWidth() {
    return this.breakPointModel.currentBreakpoint === 'sm' ? '40%' : '54%'
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          Column() {
            Scroll(this.scroller) {
              Stack({alignContent: Alignment.Top}) {
                this.TopBanner()
                Column({ space: 10 }) {
                  // 标题卡片
                  this.TitleCard()
                  // 项目详情
                  this.DetailCard()
                  // 购买须知
                  this.PurchaseNotice()
                }
                .margin({ top: 200 })
                .padding({
                  left: this.breakPointModel.pagePadding,
                  right: this.breakPointModel.pagePadding,
                  bottom: 16,
                })
              }
            }
            .width('100%')
            .height('100%')
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
            .scrollBar(BarState.Off)
            .align(Alignment.Top)
            .edgeEffect(EdgeEffect.Spring)
            .onDidScroll(() => {
              this.titleBgOpacity = this.scroller.currentOffset().yOffset / 56;
            })
          }
          .width('100%')
          .layoutWeight(1)

          this.BottomOperate()
        }
        .width('100%')
        .height('100%')

        this.titleBuilder()
      }
      .alignContent(Alignment.Top)
      .height('100%')
    }
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .backgroundColor($r('app.color.common_page_bg'))
  }

  @Builder
  TopBanner() {
    Image(CommonUtils.handleImgUrl(this.cardInfo.image))
      .width(CommonConstants.FULL_PERCENT)
      .height(270)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  TitleCard() {
    Column() {
      // 价格
      Row() {
        Text() {
          Span('￥').fontSize(14)
          Span(CommonUtils.handleCash(this.cardInfo.vipPrice) + '').fontSize(20)
        }
        .fontColor('#E84026')
        .fontWeight(500)
        Text('￥' + CommonUtils.handleCash(this.cardInfo.price))
          .fontSize(12)
          .fontColor($r('sys.color.font_tertiary'))
          .decoration({ type: TextDecorationType.LineThrough, color: $r('sys.color.font_tertiary') })
          .margin({left: 4})
        Blank()
        Text(`年售${this.cardInfo.sales}+`).fontSize(12).fontColor($r('sys.color.font_secondary'))
      }
      .width('100%')

      Text(this.cardInfo.title).fontSize(16).fontWeight(500).alignSelf(ItemAlign.Start).margin({ top: 12 })
      // 项目次数
      Row() {
        RelativeContainer() {
          Column({ space: 5 }) {
            Text('项目次数').fontSize(12).fontColor($r('sys.color.font_secondary'))
            Text(this.cardInfo.availableNum + '次').fontSize(12)
          }
          .alignItems(HorizontalAlign.Start)
          .alignRules(ALIGN_RULE_COUNT)

          Divider()
            .vertical(true)
            .id(RuleID.DIVIDER_ID)
            .alignRules(ALIGN_RULE_DIVIDER)

          Column({ space: 5 }) {
            Text('项目种类').fontSize(12).fontColor($r('sys.color.font_secondary'))
            Text(this.cardInfo.projectNum + '种').fontSize(12)
          }
          .alignItems(HorizontalAlign.Start)
          .offset({ x: 12 })
          .alignRules(ALIGN_RULE_CATEGORY)
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height(56)
      .padding(12)
      .borderRadius(8)
      .backgroundColor($r('sys.color.background_secondary'))
      .margin({ top: 12 })

      // 门店
      Row({ space: 12 }) {
        Text(this.storeDesc)
          .fontSize(12)
          .fontColor($r('app.color.common_grey'))
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start)
        Blank()
        Image($r('app.media.ic_public_arrow_right'))
          .height(14)
          .fillColor($r('app.color.common_grey'))
      }
      .width('100%')
      .margin({ top: 10 })
      .onClick(() => {
        this.isShowStoreSheet = true;
      })
      .bindSheet($$this.isShowStoreSheet, this.StoreBuilder(), {
        title: { title: '适用门店' },
        showClose: true,
        height: SheetSize.MEDIUM,
      })
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 12, bottom: 16 })
    .borderRadius(16)
    .backgroundColor(Color.White)
  }

  @Builder
  PurchaseNotice() {
    Column() {
      Text('购买须知').fontSize(18).fontWeight(700)
      Column({ space: 4 }) {
        Text('服务说明').fontSize(14).fontWeight(500).margin({ top: 8, bottom: 8 })
        Text('1、次卡可在购买以下项目时直接抵扣').fontSize(14)
        Text('2、次卡一经售出，不退卡、不换卡').fontSize(14)
        Text('3、您可以在“我的”-“次卡”中查看卡片详情').fontSize(14)
        Text('4、您到店消费时，需要将次卡的二维码展示给商户').fontSize(14)
      }
      .alignItems(HorizontalAlign.Start)

      Column({ space: 4 }) {
        Text('服务详情').fontSize(14).fontWeight(500).margin({ top: 16, bottom: 8 })
        Text('可用日期：自购买日即可使用').fontSize(14)
        Text('有效期至：' +
          (this.cardInfo.availablePeriod === -1 ? '永久有效' :
          CommonUtils.formatDateTime(this.cardInfo.availablePeriod)))
          .fontSize(14)
        Text(`服务项目：${this.cardInfo.projectNum}个`).fontSize(14)
      }
      .alignItems(HorizontalAlign.Start)
    }.cardContainer()

  }

  @Builder
  DetailCard() {
    Column({ space: 10 }) {
      Text('项目详情').fontSize(18).fontWeight(700)
      Column() {
        Text(this.cardInfo.title).fontSize(14)
        Text(`服务项目：${this.cardInfo.projectNum}个`).fontSize(14)
        Text(`服务次数：${this.cardInfo.availableNum}次`).fontSize(14)
      }
      .alignItems(HorizontalAlign.Start)

      ForEach(this.cardInfo.intro, (item: IntroItem) => {
        if (item.type === IntroType.IMAGE) {
          Image(CommonUtils.handleImgUrl(item.value)).width('100%')
            .borderRadius(8)
            .aspectRatio(0.75)
        }
        if (item.type === IntroType.TEXT) {
          Text(item.value).fontSize(12)
        }
      }, (v: IntroItem) => JSON.stringify(v))
    }.cardContainer()
  }

  buildRouteParam() {
    const param = new SimpleGoodInfo();
    param.type = OrderType.SINGLE_CARD;
    param.id = this.cardInfo.id;
    param.title = this.cardInfo.title;
    param.subTitle = this.cardInfo.subTitle;
    param.vipPrice = this.cardInfo.vipPrice;
    param.price = this.cardInfo.price;
    param.image = this.cardInfo.image;
    param.availableNum = this.cardInfo.availableNum;
    return param;
  }

  jumpOrder() {
    const param = this.buildRouteParam();
    RouterModule.push({ url: RouterMap.SUBMIT_ORDER, param: param });
  }

  @Builder
  BottomOperate() {
    Row() {
      Text() {
        Span('￥').fontSize(14)
        Span(CommonUtils.handleCash(this.cardInfo.vipPrice) + '').fontSize(20)
      }
      .fontColor('#E84026')
      .fontWeight(500)

      Text('￥' + CommonUtils.handleCash(this.cardInfo.price))
        .fontSize(12)
        .decoration({ type: TextDecorationType.LineThrough, color: $r('sys.color.font_tertiary') })
        .margin({ left: 6 })
        .fontColor($r('sys.color.font_tertiary'))
      Blank()
      if (this.userInfo.mobile) {
        Button('立即购买')
          .type(ButtonType.Capsule)
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(500)
          .width(this.buttonWidth)
          .backgroundColor($r('app.color.common_theme_color'))
          .onClick(() => {
            this.jumpOrder();
          })
      } else {
        LoginButtonType5({
          onBind: () => {
            this.jumpOrder();
          },
        })
          .width(this.buttonWidth)
          .onClick(() => {
          })
      }
    }
    .width('100%')
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
      top: 10
    })
    .backgroundColor(Color.White)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  StoreBuilder() {
    StoreList()
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
        Text('次卡详情')
          .fontSize(16)
          .fontWeight(700)
          .height(56)
          .opacity(this.titleBgOpacity)
      }
      .width('100%')

    }
  }
}
