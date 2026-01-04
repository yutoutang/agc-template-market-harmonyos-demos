import { LoginSheetUtils } from 'lib_account';
import { CommonConstants, LinearColumnModifier, LoadingStatus, RandomUtils } from 'lib_common';
import { FilterComponents } from 'lib_product_waterflow';
import { HomePageContent } from '../components/HomePageContent';
import { HomeViewModel } from '../viewmodels/HomeViewModel';
import { HashMap } from '@kit.ArkTS';

@Builder
export function HomePageBuilder() {
  HomePage()
}

@ComponentV2
struct HomePage {
  scroller: Scroller = new Scroller();
  @Local vm: HomeViewModel = new HomeViewModel();
  @Local modifier: LinearColumnModifier = new LinearColumnModifier($r('app.color.home_linear'));
  @Provider() isShow: boolean = false;

  aboutToAppear(): void {
    this.vm.loadHomePage()
    this.vm.getHotSearchList()
    this.vm.startCarousel()
  }

  aboutToDisappear(): void {
    this.vm.stopCarousel()
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Image($r('app.media.ic_frame'))
            .width(20)
            .height(20)
            .margin({ left: 16, right: 8 })
          Text(this.vm.settingInfo.address)
            .fontSize(16)
            .fontColor('#FFFFFFFF')
        }
        .width('100%')
        .margin({ top: 50 })
        .onClick(() => {
          if (this.vm.userInfoModel.isLogin) {
            this.vm.jumpToMyAddressSearchPage();
          } else {
            LoginSheetUtils.open()
          }
        })

        Row() {
          Row() {
            Image($r('app.media.search'))
              .width(20)
              .height(20)
              .margin({ left: 16, right: 5 })
              .fillColor('#FFC0B7B7')

            Text(this.vm.getCurrentHotSearch())
              .fontSize(16)
              .layoutWeight(1)
              .textAlign(TextAlign.Start)
              .fontColor('#FFC0B7B7')
          }
          .width('90%')
          .height(40)
          .backgroundColor('#D1FFFFFF')
          .borderRadius(24)
          .margin({
            top: 15,
            bottom: 15,
            right: 20,
            left: 20
          })
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .onClick(() => {
          this.vm.jumpToSearchStorePage(0);
        })

        Stack({ alignContent: Alignment.Top }) {
          Refresh({
            refreshing: $$this.vm.isRefreshing,
            builder: this.buildRefreshingContent,
          }) {
            Scroll(this.scroller) {
              Stack({ alignContent: Alignment.Top }) {
                if (this.vm.loadingStatus === LoadingStatus.SUCCESS) {
                  HomePageContent({
                    vm: this.vm,
                    categoryList: this.vm.categoryList,
                    scroller: this.scroller,
                    handleClickCategory: (id, title, index) => {
                      this.vm.jumpToCategoryPage(id, title, index);
                    },
                  });
                } else if (this.vm.loadingStatus === LoadingStatus.FAIL) {
                  Text('当前页面加载失败，请重新发起尝试')
                    .fontSize($r('app.float.font_size_14'))
                    .margin({ bottom: $r('app.float.space_l') })
                    .fontColor($r('sys.color.mask_secondary'));
                  Button('重新加载')
                    .backgroundColor($r('app.color.theme_color'))
                    .fontSize($r('sys.float.Body_L'))
                    .fontWeight(FontWeight.Medium)
                }

              }
              .constraintSize({ minHeight: $r('app.string.size_percent_full') })
              .backgroundColor(Color.Transparent)
            }
            .nestedScroll({
              scrollForward: NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST,
            })
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
            .align(Alignment.Top)
            .layoutWeight(1)
          }
          .layoutWeight(1)
          .onStateChange((state) => {
            this.vm.onRefreshStateChange(state)
          })
          .pullDownRatio(this.vm.loadingStatus === LoadingStatus.SUCCESS ? 1 : 0)
          .backgroundColor(Color.Transparent)
          .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM]);

          if (this.vm.isShowFilter) {
            // 蒙层
            Column() {
            }
            .borderRadius({
              topLeft: 12,
              topRight: 12,
            })
            .margin({
              top: this.vm.isShowFilter ? 8 : 0,
            })
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.FULL_PERCENT)
            .backgroundColor($r('sys.color.mask_fourth'))
            .onClick(() => {
              this.vm.isShowFilter = false
            })

            // 筛选内容
            Column() {
              Text('筛选店铺')
                .fontWeight(FontWeight.Bold)
                .fontSize(24)
                .alignSelf(ItemAlign.Start)
                .padding({ left: 16, top: 16 })
              FilterComponents({
                scoreThreshold: this.vm.scoreThreshold,
                salesThreshold: this.vm.salesThreshold,
                deliveryTimeThreshold: this.vm.deliveryTimeThreshold,
                confirm: () => {
                  this.vm.isShowFilter = false
                },
                handleClickItem: (item: HashMap<string, number>) => {
                  // 遍历item值，获取对应的数据
                  if (!item.isEmpty()) {
                    this.vm.scoreThreshold = item.get(FilterComponents.EVALUATION_KEY)
                    this.vm.salesThreshold = item.get(FilterComponents.SALESVOLUME_KEY)
                    this.vm.deliveryTimeThreshold = item.get(FilterComponents.TIME_KEY)
                  } else {
                    // 清空筛选条件
                    this.vm.scoreThreshold = undefined
                    this.vm.salesThreshold = undefined
                    this.vm.deliveryTimeThreshold = undefined
                  }
                  //随机数
                  this.vm.changeByThreshold = RandomUtils.random(100)
                }

              })
            }
            .backgroundColor($r('app.color.background_color_white'))
            .borderRadius(12)
            .width(CommonConstants.FULL_PERCENT)
          }
        }
        .layoutWeight(1)
      }
      .width($r('app.string.size_percent_full'))
      .height($r('app.string.size_percent_full'))
      .backgroundColor(Color.Transparent)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);

    }
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
  }

  @Builder
  rightHeadPartBuilder() {
    Row({ space: CommonConstants.SPACE_S }) {
      Row() {
        Image($r('app.media.ic_search')).width($r('app.float.nav_icon_width')).fillColor($r('sys.color.font_primary'))
      }
      .padding(10)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius('50%')
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
  }

  @Builder
  buildRefreshingContent() {
    Stack() {
      if (this.vm.refreshStatus === RefreshStatus.Refresh) {
        LoadingProgress().width($r('app.float.loading_icon_size'))
      } else if (this.vm.refreshStatus === RefreshStatus.OverDrag) {
        Text('释放可刷新页面')
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Body_M'))
          .lineHeight(32)
          .halfLeading(true);
      } else if (this.vm.refreshStatus === RefreshStatus.Drag) {
        Text('下拉刷新')
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Body_M'))
          .lineHeight(32)
          .halfLeading(true);
      }
    }
    .align(Alignment.Center)
    .clip(true)
    .constraintSize({ minHeight: 32 })
    .width('100%')
    .backgroundColor(Color.Transparent)
  }
}