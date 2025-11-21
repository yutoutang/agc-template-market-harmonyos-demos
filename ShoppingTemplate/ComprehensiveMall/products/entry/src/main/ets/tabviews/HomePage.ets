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
      NavTitleBar({
        title: '首页',
        bgColor: this.vm.isTablet ? $r('app.color.background_color_transparent') :
          $r('app.color.background_color_white'),
      }) {
        if (this.vm.isTablet) {
          Blank()
          this.buildSearchBar()
        }
      }

      if (!this.vm.isTablet) {
        this.buildSearchBar()
      }

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
              })
                .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
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
          .justifyContent(FlexAlign.Center)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        }
        .nestedScroll({
          scrollForward: NestedScrollMode.PARENT_FIRST,
          scrollBackward: NestedScrollMode.SELF_FIRST,
        })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .align(Alignment.Top)
        .layoutWeight(1)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
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
    .backgroundColor($r('app.color.background_color_grey'))
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  @Builder
  buildSearchBar() {
    Row() {
      Row() {
        Image($r('app.media.ic_home_search'))
          .width(16)
          .margin({
            right: $r('app.float.space_l'),
          })
        Swiper() {
          ForEach(this.vm.searchList, (str: string) => {
            Text(str).fontColor($r('app.color.font_color_level2'))
          }, (str: string, index: number) => index + str)
          if (!this.vm.searchList.length) {
            Text('请输入关键字搜索').fontColor($r('app.color.font_color_level2'))
          }
        }
        .indicator(false)
        .loop(true)
        .autoPlay(true)
        .vertical(true)
        .onChange((index) => {
          if (this.vm.searchList.length) {
            this.vm.currentSearchStr = this.vm.searchList[index];
          }
        })
      }
      .height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius(20)
      .layoutWeight(1)
      .padding({
        left: $r('app.float.space_l'),
        right: $r('app.float.space_l'),
      })
      .margin({ right: $r('app.float.space_s') })
      .id('search')
      .onClick(() => {
        this.vm.jumpToSearchPage(this.getUIContext(), 'search')
      })

      Image($r('app.media.ic_scan'))
        .width(40)
        .onClick(() => {
          this.vm.jumpToScanPage()
        })
    }
    .width(this.vm.isTablet ? 400 : $r('app.string.size_percent_full'))
    .height(56)
    .backgroundColor(this.vm.isTablet ? $r('app.color.background_color_grey') : $r('app.color.background_color_white'))
    .alignItems(VerticalAlign.Center)
    .padding({
      left: $r('app.float.space_l'),
      right: $r('app.float.space_l'),
    })
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
    .backgroundColor($r('app.color.background_color_grey'))
  }
}


@Builder
export function buildHomePage() {
  HomePage();
}
