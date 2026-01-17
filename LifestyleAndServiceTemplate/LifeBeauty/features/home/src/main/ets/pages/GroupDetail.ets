import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import {
  CommonConstants,
  GetUserInfoResp,
  GroupContentItem,
  GroupInfo,
  CommonUtils,
  IntroItem,
  IntroType,
  LoginButtonType5,
  OrderType,
  RouterMap,
  RouterModule,
  SimpleGoodInfo,
  UIEmpty,
  UIBackBtn,
  BreakpointModel,
  CustomShareModel,
  StoreInfoModel,
} from 'foundation';
import { StoreList } from '../components/StoreList';

@Builder
export function GroupDetailBuilder() {
  GroupDetail()
}

@Extend(Column)
function cardContainer() {
  .width('100%')
  .padding({ left: 12, right: 12, top: 12, bottom: 16 })
  .borderRadius(16)
  .backgroundColor(Color.White)
}

@ComponentV2
struct CardContainer {
  @Param title: string = '';
  @BuilderParam buildParam: () => void;

  build() {
    Column() {
      Text(this.title).fontSize(18).fontWeight(700).margin({ bottom: 10 })
      if (this.buildParam) {
        this.buildParam()
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding({ left: 12, right: 12, top: 24, bottom: 16 })
    .borderRadius(16)
    .backgroundColor(Color.White)
  }
}

@ComponentV2
export struct GroupDetail {
  @Local groupInfo: GroupInfo = new GroupInfo();
  @Local isShowStoreSheet: boolean = false;
  @Local userInfo: GetUserInfoResp = PersistenceV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local instance: CustomShareModel = AppStorageV2.connect(CustomShareModel, () => new CustomShareModel())!;
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Local titleBgOpacity: number = 0;
  scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    const paramList: Array<GroupInfo> = RouterModule.getNavParam({ url: RouterMap.GROUP_DETAIL });
    if (paramList.length) {
      this.groupInfo = paramList[paramList.length - 1];
    }
    // 设置分享参数
    this.instance.pageName = 'GroupDetail';
    this.instance.goodId = this.groupInfo.id;
    this.instance.goodName = this.groupInfo.title;
    this.instance.goodType = OrderType.GROUP;
  }

  aboutToDisappear(): void {
    // 设置分享参数
    this.instance.pageName = '';
    this.instance.goodName = '';
    this.instance.goodId = 0;
  }

  @Builder
  Banner() {
    Image(CommonUtils.handleImgUrl(this.groupInfo.images[0]))
      .width(CommonConstants.FULL_PERCENT)
      .height(270)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  StoreBuilder() {
    StoreList()
  }

  @Computed
  get storeDesc() {
    const storeInfo = this.storeModel.storeList.find((x) => x.id === this.storeModel.storeId)
    const distance = storeInfo?.distance;
    let distanceStr = distance ? `最近${distance}·` : '';
    return `门店：${distanceStr}${storeInfo?.storeName}等${this.storeModel.storeList?.length}家门店适用`;
  }

  @Computed
  get buttonWidth() {
    return this.breakPointModel.currentBreakpoint === 'sm' ? '40%' : '54%'
  }

  @Builder
  TitleCard() {
    Column() {
      Row() {
        Text() {
          Span('￥').fontSize(14)
          Span(CommonUtils.handleCash(this.groupInfo.vipPrice) + '').fontSize(20)
        }
        .fontColor('#E84026')
        .fontWeight(500)
        Text('￥' + CommonUtils.handleCash(this.groupInfo.price))
          .fontSize(12)
          .fontColor($r('sys.color.font_tertiary'))
          .decoration({ type: TextDecorationType.LineThrough, color: $r('sys.color.font_tertiary') })
          .margin({left: 4})

        Blank()
        Text(`年售${this.groupInfo.soldNum}+`).fontSize(12).fontColor($r('sys.color.font_secondary'))
      }
      .width('100%')

      Text(this.groupInfo.title).fontSize(16).fontWeight(500).margin({ top: 12 })
        .width('100%')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Row({ space: 12 }) {
        Text(this.storeDesc)
          .fontSize(12)
          .fontColor($r('app.color.common_grey'))
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start)
        Image($r('app.media.ic_public_arrow_right'))
          .height(14)
          .fillColor($r('app.color.common_grey'))
      }
      .width('100%')
      .margin({top: 16})
      .onClick(() => {
        this.isShowStoreSheet = true;
      })
      .bindSheet($$this.isShowStoreSheet, this.StoreBuilder(), {
        title: { title: '适用门店' },
        showClose: true,
        height: SheetSize.MEDIUM,
      })

    }.cardContainer()
  }

  @Builder
  ContentCard() {
    CardContainer({ title: '套餐内容' }) {
      Column({ space: 12 }) {
        Row({ space: 30 }) {
          Text('适用部位').fontSize(14).fontWeight(500)
          Text(this.groupInfo.groupContent.location).fontSize(14).fontWeight(400)
        }.width('100%').alignItems(VerticalAlign.Top)

        Row({ space: 30 }) {
          Text('包含项目').fontSize(14).fontWeight(500)
          Text(this.groupInfo.groupContent.including)
            .fontSize(14).layoutWeight(1).textAlign(TextAlign.Start)
            .fontWeight(400)
        }.width('100%').alignItems(VerticalAlign.Top)

        Row({ space: 30 }) {
          Text('附赠项目').fontSize(14).fontWeight(500)
          Text(this.groupInfo.groupContent.present).fontSize(14).fontWeight(400)
        }.width('100%').alignItems(VerticalAlign.Top)

        Text('团购详情').fontSize(14).fontWeight(500)
        Column({ space: 8 }) {
          ForEach(this.groupInfo.groupContent.detail, (item: GroupContentItem) => {
            Row() {
              Text('·').fontSize(14).fontWeight(400)
              Text(item.title).fontSize(14).fontWeight(400)
              Blank()
              Row({space: 16}) {
                Text(`(${item.numbers} 份)`).fontColor($r('app.color.common_grey')).fontSize(14).fontWeight(400)
                Text('￥' + CommonUtils.handleCash(item.price)).fontSize(14).fontWeight(400)
                  .width(50)
                  .textAlign(TextAlign.End)
              }
            }.width('100%')
          }, (v: GroupContentItem) => JSON.stringify(v))
        }
      }.alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  NoticeCard() {
    CardContainer({ title: '购买须知' }) {
      Column({ space: 16 }) {
        Column({ space: 4 }) {
          Text('服务说明').fontSize(14).margin({ bottom: 4 })
          Text('1、此卡可在购买以下项目时直接抵扣').fontSize(14)
          Text('2、次卡一经售出，不退卡、不换卡').fontSize(14)
          Text('3、您可以在“我的”-“我的次卡”中查看卡片详情').fontSize(14)
          Text('4、您到店消费时，需将次卡的二维码展示给商户').fontSize(14)
        }
        .alignItems(HorizontalAlign.Start)

        Column({ space: 4 }) {
          Text('服务详情').fontSize(14).margin({ bottom: 4 })
          Text('可用日期：自购买日即可使用').fontSize(14)
          Text('有效期至：' +
            (this.groupInfo.availablePeriod === -1 ? '永久有效' :
              CommonUtils.formatDateTime(this.groupInfo.availablePeriod)))
            .fontSize(14)
          Text(`服务项目：${this.groupInfo.projectNum}个`).fontSize(14)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  MoreDetail() {
    CardContainer({ title: '图文详情' }) {
      if (this.groupInfo.intro.length) {
        Column({ space: 12 }) {
          ForEach(this.groupInfo.intro, (item: IntroItem) => {
            if (item.type === IntroType.IMAGE) {
              Image(CommonUtils.handleImgUrl(item.value)).width('100%').height('auto')
                .borderRadius(8)
            }
            if (item.type === IntroType.TEXT) {
              Text(item.value).fontSize(14)
            }
          }, (v: IntroItem) => JSON.stringify(v))
        }
        .padding({ bottom: 10 })
      } else {
        UIEmpty({ emptyDesc: $r('app.string.good_detail_more_empty'), fg: 12 }).margin({ top: 60, bottom: 60 })
      }
    }
  }

  buildRouteParam() {
    const param = new SimpleGoodInfo();
    param.type = OrderType.GROUP;
    param.id = this.groupInfo.id;
    param.title = this.groupInfo.title;
    param.subTitle = this.groupInfo.subTitle;
    param.vipPrice = this.groupInfo.vipPrice;
    param.image = this.groupInfo.images[0] ?? '';
    param.price = this.groupInfo.price;
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
        Span(CommonUtils.handleCash(this.groupInfo.vipPrice) + '').fontSize(20)
      }
      .fontColor('#E84026')
      .fontWeight(500)
      Text('￥' + CommonUtils.handleCash(this.groupInfo.price))
        .decoration({ type: TextDecorationType.LineThrough, color: $r('sys.color.font_tertiary') })
        .fontSize(12)
        .fontColor($r('sys.color.font_tertiary'))
        .margin({ left: 6 })

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
      }
    }
    .width('100%')
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
      top: 15,
      bottom: 10,
    })
    .backgroundColor(Color.White)
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
        Text('团购详情')
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
                this.TitleCard()
                this.ContentCard()
                this.NoticeCard()
                this.MoreDetail()
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
          .width('100%')
          .layoutWeight(1)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .onDidScroll(() => {
            this.titleBgOpacity = this.scroller.currentOffset().yOffset / 56;
          })

          this.BottomOperate()
        }
        .width('100%')
        .height('100%')

        this.titleBuilder()
      }
      .alignContent(Alignment.Top)

    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.common_page_bg'))
  }
}
