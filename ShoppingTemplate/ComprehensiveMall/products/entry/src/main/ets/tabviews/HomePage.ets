import { LoadingStatus, Style, routerStack, RouterMap } from 'lib_foundation';
import { NavTitleBar } from 'lib_widget';
import { HomePageContent } from '../components/HomePageContent';
import { HomePageVM } from '../viewmodels/HomePageVM';

@ComponentV2
export struct HomePage {
  private vm: HomePageVM = new HomePageVM();
  scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    this.vm.loadHomePage()
  }

  build(): void {
    Column() {
      this.buildPageHeader()
      Refresh({
        refreshing: $$this.vm.isRefreshing,
        builder: this.buildRefreshingContent,
      }) {
        Scroll(this.scroller) {
          Column() {
            if (this.vm.loadingStatus === LoadingStatus.LOADING) {
              LoadingProgress()
                .width($r('app.float.loading_icon_size'))
            } else if (this.vm.loadingStatus === LoadingStatus.SUCCESS) {
              HomePageContent({
                categoryList: this.vm.categoryList,
                scroller: this.scroller,
                handleClickCategory: (id) => {
                  this.vm.jumpToCategoryPage(id);
                },
              });
            } else {
              Text('当前页面加载失败，请重新发起尝试')
                .fontSize($r('app.float.font_size_14'))
                .margin({ bottom: $r('app.float.space_l') })
                .fontColor($r('sys.color.mask_secondary'));
              Button('重新加载')
                .backgroundColor($r('app.color.theme_color'))
                .onClick(() => {
                  this.vm.loadHomePage()
                });
            }
          }
          .constraintSize({ minHeight: $r('app.string.size_percent_full') })
          .justifyContent(FlexAlign.Center)
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
      .backgroundColor($r('app.color.background_color_grey'))
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM]);
    }
    .width($r('app.string.size_percent_full'))
    .height($r('app.string.size_percent_full'))
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  @Builder
  buildPageHeader() {
    NavTitleBar({
      title: '首页',
      bgColor: $r('app.color.background_color_white'),
    }) {
      Row() {
        Image($r('app.media.ic_search_filled'))
          .width(40)
          .height(40)
          .onClick(() => {
            routerStack.pushPathByName(RouterMap.PRODUCT_SEARCH, null);
          })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.End)
    }
  }

  @Builder
  buildRefreshingContent() {
    Stack() {
      if (this.vm.refreshStatus === RefreshStatus.Refresh) {
        LoadingProgress().width($r('app.float.loading_icon_size'))
      } else if (this.vm.refreshStatus === RefreshStatus.OverDrag) {
        Text('释放可刷新页面')
          .fontColor(Style.FONT_COLOR_LEVEL2)
          .fontSize(Style.FONT_SIZE_12)
          .lineHeight(32)
          .halfLeading(true);
      } else if (this.vm.refreshStatus === RefreshStatus.Drag) {
        Text('下拉刷新')
          .fontColor(Style.FONT_COLOR_LEVEL2)
          .fontSize(Style.FONT_SIZE_12)
          .lineHeight(32)
          .halfLeading(true);
      }
    }
    .align(Alignment.Center)
    .clip(true)
    .constraintSize({ minHeight: 32 })
    .width('100%')
    .backgroundColor($r('app.color.background_color_grey'))
  }
}


@Builder
export function buildHomePage() {
  HomePage();
}
