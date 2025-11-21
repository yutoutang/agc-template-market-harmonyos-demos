import { CommonConstants, RouterModule } from 'lib_foundation';
import { TabItemModel } from '../model/TabItemModel';
import { HomePage } from 'business_home';
import { ToolPage } from 'business_tool';
import { MinePage } from 'business_mine';

@Entry
@ComponentV2
struct Index {
  @Local selectIndex: number = 0;
  aboutToAppear() {
   let message = AppStorage.get('widget_router') ?? ''
    if (!message || message === 'all') {
      return
    }
    // 直接点击卡片
    RouterModule.getStack().clear();
    if (message === 'calculator') {
      this.selectIndex = 0;
    } else {
      this.selectIndex = 1;
    }
  }

  build() {
    Navigation(RouterModule.getStack()) {
      Column() {
        Tabs({ index: $$this.selectIndex }) {
          TabContent() {
            HomePage();
          }
          .clip(false)
          .tabBar(this.tabBuilder(0, {
            label: '计算器',
            icon: $r('app.media.calculator_unselect'),
            iconSelected: $r('app.media.calculator_select'),
          }))

          TabContent() {
            ToolPage();
          }
          .clip(false)
          .tabBar(this.tabBuilder(1, {
            label: '工具',
            icon: $r('app.media.tool_unselect'),
            iconSelected: $r('app.media.tool_select'),
          }))

          TabContent() {
            MinePage()
          }
          .clip(false)
          .tabBar(this.tabBuilder(2, {
            label: '我的',
            icon: $r('app.media.mine_unselect'),
            iconSelected: $r('app.media.mine_select'),
          }))
        }
        .clip(false)
        .height(CommonConstants.FULL_PERCENT)
        .width(CommonConstants.FULL_PERCENT)
        .scrollable(false)
        .barPosition(BarPosition.End)
        .barBackgroundColor($r('sys.color.background_secondary'))
        .onTabBarClick((index: number) => {
          this.selectIndex = index;
        })
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
    }.hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM])
    .backgroundColor($r('sys.color.background_secondary'))
    .mode(NavigationMode.Stack);
  }



  @Builder
  tabBuilder(index: number, item: TabItemModel) {
    Column({ space: 4 }) {
      Image(this.selectIndex === index ? item.iconSelected : item.icon)
        .width(20)
        .height(20);
      Text(item.label)
        .fontColor(this.selectIndex === index ? $r('sys.color.font_emphasize') : $r('sys.color.font_secondary'))
        .fontSize(10)
        .fontWeight(500)
        .lineHeight(13)
    }.width(CommonConstants.FULL_PERCENT)
  }
}