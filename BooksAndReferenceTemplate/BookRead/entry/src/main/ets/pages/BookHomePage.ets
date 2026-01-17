import { BreakpointStorage, BreakpointSystem, BreakpointTypeEnum, TabInfo } from 'common';
import { UserInfo } from 'base_common';
import { IndexData } from '../model/MainTab';

@ComponentV2
export struct BookHomePage {
  @Provider('currentIndexTab') currentIndexTab: number = 0;
  @Provider('tabController') tabsController: TabsController = new TabsController();
  @Provider('isHistory') isHistory: boolean = false
  @Provider('userInfo') userInfo: UserInfo | undefined = undefined;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Builder
  tabBuilder(title: string, index: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndexTab === index ? selectedImg : normalImg)
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
      Text(title)
        .margin({ top: 4 })
        .fontSize(10)
        .fontColor(this.currentIndexTab === index ? $r('app.color.font_overdue') : '#E6000000')
    }
    .justifyContent(FlexAlign.Center)
    .height(this.isTablet ? 100 : undefined)
    .width('100%')
    .onClick(() => {
      this.currentIndexTab = index;
      this.tabsController.changeIndex(this.currentIndexTab);
    })

  }

  @Computed
  get isTablet() {
    return BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.LG
  }

  build() {
    NavDestination() {
      Tabs({
        barPosition: this.curBreakpoint.value === BreakpointTypeEnum.LG ? BarPosition.Start : BarPosition.End,
        index: this.currentIndexTab,
        controller: this.tabsController
      }) {
        ForEach(IndexData.MAIN_TAB, (item: TabInfo) => {
          TabContent() {
            item.component?.builder();
          }
          .tabBar(this.tabBuilder(item.label, item.index, item.activeIcon, item.defaultIcon))
        }, (item: TabInfo) => item.index.toString())
      }
      .clip(false)
      .height('100%')
      .backgroundColor('#fff')
      .padding({ bottom: 18 })
      .animationDuration(0)
      .scrollable(false)
      .barMode(this.isTablet ? BarMode.Scrollable : BarMode.Fixed)
      .vertical(this.isTablet)
      .barWidth(this.isTablet ? 96 : '100%')
      .onAnimationStart((targetIndex: number) => {
        this.currentIndexTab = targetIndex;
      })
    }
    .onWillShow(() => {
      if (AppStorage.has('userInfo')) {
        this.userInfo = AppStorage.get('userInfo') as UserInfo;
      }
    })
    .hideTitleBar(true)
  }
}