import { common } from '@kit.AbilityKit';
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import {
  StoreInfo,
  GoodListInfo,
  GoodInfo,
  getStoreInfo,
  getGoodList,
  PopViewUtils,
  CommonConstants,
  CommonUtils,
  SystemSceneUtils,
  GetUserInfoResp,
  GoodCard,
  BreakpointModel,
  BreakpointNameEnum,
  AppPrivacyUtils,
  silentLogin,
  StoreInfoModel,
  RouterModule,
  RouterMap,
  Params,
  DialogCallBuilder,
} from 'foundation';
import { LIST_RULE, RuleID } from '../common/Constant';
import { ActiveMember } from '../components/ActiveMemberModule';
import { SingleVisitList } from '../components/SingleVisitModule';
import { GroupBuyList } from '../components/GroupModule';
import { HomeBaseVM } from '../viewmodel/HomeBaseVM';

const TAG = '[HomePage]';

@Styles
function subTextContainer() {
  .padding({
    left: 4,
    right: 4,
    top: 2,
    bottom: 2,
  })
  .backgroundColor($r('app.color.common_page_bg'))
  .borderRadius(4)
}

@Extend(Text)
function subText() {
  .fontSize(10)
  .fontColor($r('app.color.common_grey'))
}

@ComponentV2
export struct Home {
  homeVM: HomeBaseVM = HomeBaseVM.instance;
  @Local storeInfo: StoreInfo = new StoreInfo();
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Local userInfo: GetUserInfoResp = PersistenceV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local goodList: GoodListInfo[] = [];
  @Local distance: string = '0m';
  @Local titleBgOpacity: number = 0;
  @Local isGranted: boolean = false;
  @Local isRefreshing: boolean = false;
  scroller: Scroller = new Scroller();
  @Local privacyImpl: AppPrivacyUtils = AppPrivacyUtils.instance;

  @Monitor('privacyImpl.agreeFlag')
  agreeFlagChange() {
    if (this.privacyImpl.agreeFlag) {
      Logger.info(TAG, 'user has agree the privacy, start silent login and apply permission');
      // 静默登录
      silentLogin();
      SystemSceneUtils.applyLocationPermission().then((isGranted) => {
        if (isGranted) {
          this.calcDistance();
        }
      })
    }
  }

  @Monitor('storeModel.storeId')
  storeIdChange() {
    const store = this.homeVM.storeList.find((item) => item.id === this.storeModel.storeId);
    if (store) {
      this.storeInfo.id = store.id;
      this.storeInfo.storeName = store.storeName;
      this.storeInfo.mobile = store.mobile;
      this.storeInfo.coords = store.coords;
      this.storeInfo.address = store.address;
      this.distance = store.distance ?? '0m'
    }
  }

  aboutToAppear(): void {
    // 静默登录
    if (this.privacyImpl.agreeFlag) {
      silentLogin();
    }
    this.init();
  }

  async init() {
    await this.getStoreInfo();
    this.getGoodList();
    await this.homeVM.init();
    // 申请权限
    if (this.privacyImpl.agreeFlag) {
      const isGranted = await SystemSceneUtils.applyLocationPermission();
      if (isGranted) {
        this.calcDistance();
      }
    }
    this.storeModel.storeList = this.homeVM.storeList;
  }

  getStoreInfo() {
    return getStoreInfo().then((resp) => {
      this.storeInfo = new StoreInfo(resp as StoreInfo);
      this.storeModel.storeId = this.storeInfo.id
      Logger.info(TAG, 'get store info response = ' + JSON.stringify(resp));
    }).catch((e: BusinessError) => {
      Logger.error(TAG, 'get store info error = ' + JSON.stringify(e));
    })
  }

  getGoodList() {
    getGoodList().then((resp) => {
      this.goodList = resp as GoodListInfo[];
      setTimeout(() => {
        this.isRefreshing = false;
      }, 100)
    })
  }

  calcDistance() {
    SystemSceneUtils.getDistance(this.storeInfo.coords).then((resp) => {
      this.distance = resp;
    });
    this.homeVM.storeList.forEach((item) => {
      SystemSceneUtils.getDistance(item.coords).then((resp) => {
        item.distance = resp;
      });
    })
  }

  @Computed
  get starCount() {
    const scoreNum = Math.floor(Number(this.storeInfo.score));
    const multiple = Math.ceil(scoreNum / 5);
    return scoreNum / multiple;
  }

  @Computed
  get waterFlowLanes() {
    let lanesValue = 2
    switch (this.breakPointModel.currentBreakpoint) {
      case BreakpointNameEnum.SM:
        lanesValue = 2;
        break;
      case BreakpointNameEnum.MD:
        lanesValue = 4;
        break;
      case BreakpointNameEnum.LG:
      case BreakpointNameEnum.XL:
        lanesValue = 5;
        break;
    }

    return lanesValue
  }

  openPhoneDialog() {
    PopViewUtils.showPopView<Params>(wrapBuilder(DialogCallBuilder), new Params(this.storeInfo.mobile.split(',')),
      { alignment: DialogAlignment.Bottom, autoCancel: true });
  }

  selectStore() {
    this.storeModel.storeList = this.homeVM.storeList;
    RouterModule.push({url: RouterMap.SELECT_STORE_PAGE})
  }

  @Builder
  StoreInfoCard() {
    // 卡片
    Column({ space: 12 }) {
      // 店铺的图文等介绍
      Row({ space: 12 }) {
        Image(CommonUtils.handleImgUrl(this.storeInfo.logoUrl)).width(64).height(64).borderRadius(8)
        Column({ space: 6 }) {
          Text(this.storeInfo.storeName).fontSize(16).fontWeight(FontWeight.Bold)
          Row({ space: 4 }) {
            ForEach([1,2,3,4,5], (v: number) => {
              Image($r('app.media.icon_star'))
                .width(12)
                .height(12)
                .fillColor(v <= this.starCount ? $r('app.color.common_theme_color') : $r('app.color.grey_20'))
            }, (item: number) => item.toString())
            Text(this.storeInfo.score)
              .fontSize(12)
              .fontColor($r('app.color.common_theme_color'))
            Text('营业时间')
              .fontSize(12)
              .fontColor($r('app.color.grey_60'))
              .margin({left: 8})
            Text(this.storeInfo.businessTimes).fontSize(12).fontColor($r('app.color.grey_60'))
          }

          Row({ space: 8 }) {
            Text($r('app.string.home_tag_no_other_price')).subTextContainer().subText()
            Text($r('app.string.home_tag_refund')).subTextContainer().subText()
            Text($r('app.string.home_tag_security')).subTextContainer().subText()
          }
        }.alignItems(HorizontalAlign.Start)
      }.width(CommonConstants.FULL_PERCENT).alignItems(VerticalAlign.Center)

      // 位置、导航、电话
      Row() {
        SymbolGlyph($r('sys.symbol.local')).fontSize(16).fontColor([$r('sys.color.icon_primary')])
        Column({ space: 4 }) {
          Row() {
            Text(this.storeInfo.address || $r('app.string.empty_location')).fontSize(12)
              .maxLines(1).textOverflow({overflow: TextOverflow.Ellipsis})
              .constraintSize({maxWidth: 'calc(100% - 24vp)'})
              .textOverflow({overflow: TextOverflow.Ellipsis})
            SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(18).fontColor([$r('sys.color.icon_primary')])
              .margin({left: 8 })
          }
          Text(`距您${this.distance}`).fontSize(12).fontColor($r('app.color.grey_60'))
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 4 })
        .layoutWeight(1)
        .onClick(() => {
          this.selectStore()
        })

        Column({space: 4}) {
          SymbolGlyph($r('sys.symbol.location_north_up_right_circle_fill'))
            .fontColor(['#E64566'])
            .fontSize(24)
        }
        .margin({ left: 10 })
        .onClick(() => {
          const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
          SystemSceneUtils.jumpPetalMap(context, this.storeInfo.address, this.storeInfo.coords.split(','))
        })

        Column({space: 4}) {
          Image($r('app.media.ic_call')).width(24).height(24)
        }
        .margin({ left: 8 })
        .onClick(() => {
          this.openPhoneDialog();
        })

      }.width(CommonConstants.FULL_PERCENT).alignItems(VerticalAlign.Top)
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding(12)
    .borderRadius(16)

    if (this.userInfo.mobile) {
      ActiveMember({
        isMember: Boolean(this.userInfo.memberId)
      })
    }
  }

  @Builder
  GoodList(v: GoodListInfo) {
    WaterFlow() {
      ForEach(v.goods, (good: GoodInfo) => {
        FlowItem() {
          GoodCard({ goodInfo: good })
        }
        .width(CommonConstants.FULL_PERCENT)
      }, (v: GoodInfo) => JSON.stringify(v))
    }
    .cachedCount(10)
    .columnsTemplate(`repeat(${this.waterFlowLanes}, 1fr)`)
    .columnsGap(10)
    .rowsGap(6)
    .width(CommonConstants.FULL_PERCENT)
    .scrollBar(BarState.Off)
  }

  @Builder
  titleBuilder() {
    Row() {
      Text('首页').fontSize(26).fontWeight(700).padding({ left: 16 }).height(56)
    }
    .width('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .backgroundColor(Color.White)
    .opacity(this.titleBgOpacity)
  }

  build() {
    NavDestination() {
      Stack() {
        Scroll(this.scroller) {
          Column() {
            RelativeContainer() {
              Image(CommonUtils.handleImgUrl(this.storeInfo.storeBanner))
                .width(CommonConstants.FULL_PERCENT)
                .height(200)
                .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
                .id(RuleID.BANNER_ID)

              Refresh({ refreshing: $$this.isRefreshing }) {
                Scroll() {
                  Column({ space: 12 }) {
                    this.StoreInfoCard()
                    SingleVisitList()
                    GroupBuyList()

                    Row() {
                      Text('为您推荐')
                        .fontSize(18)
                        .fontColor($r('sys.color.font_primary'))
                        .fontWeight(700)
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.Start)
                    .margin({top: 12})
                    ForEach(this.goodList, (v: GoodListInfo) => {
                      this.GoodList(v)
                    }, (item: GoodListInfo) => JSON.stringify(item))
                  }
                  .padding({
                    left: this.breakPointModel.pagePadding,
                    right: this.breakPointModel.pagePadding,
                    bottom: 10,
                  })
                }
                .align(Alignment.Top)
                .scrollBar(BarState.Off)
                .nestedScroll({
                  scrollForward: NestedScrollMode.PARENT_FIRST,
                  scrollBackward: NestedScrollMode.SELF_FIRST,
                })
              }
              .id(RuleID.GOOD_LIST_ID)
              .alignRules(LIST_RULE)
              .onRefreshing(() => {
                this.getGoodList();
              })
            }
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
            .height('auto')
            .width('auto')
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .onDidScroll(() => {
          this.titleBgOpacity = this.scroller.currentOffset().yOffset / 56;
        })

        this.titleBuilder()
      }
      .width('100%')
      .height('100%')
      .alignContent(Alignment.Top)

    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.common_page_bg'))
  }
}
