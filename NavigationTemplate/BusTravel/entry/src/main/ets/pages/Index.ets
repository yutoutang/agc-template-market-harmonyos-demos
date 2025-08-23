import { TabInfo } from 'common'
import AppConstants from '../constants/AppConstants'
import { EntryVM } from '../viewmodels/EntryVM'

@Entry
@ComponentV2
struct Index {
  vm: EntryVM = EntryVM.instance
  private tabController: TabsController = new TabsController();
  aboutToAppear(): void {
    this.vm.redirect()
  }
  build() {
    RelativeContainer() {
      Navigation(this.vm.pageStack) {
        Stack() {
          Tabs({ barPosition: BarPosition.End, controller: this.tabController }) {
            ForEach(this.vm.homeTabList, (item: TabInfo) => {
              TabContent() {
                item.component?.builder();
              }
              .tabBar(this.TabBarBuilder(item.index, item.label, item.defaultIcon, item.activeIcon, item.flag))
            },(item:TabInfo)=>item.index.toString())
          }
          .barBackgroundColor($r('app.color.home_bar_bgc_color'))
          .scrollable(false)
          .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
            if (index === targetIndex) {
              return
            }
            this.vm.currentIndex = targetIndex
          })
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .width(AppConstants.FULL_PERCENT)
        .height(AppConstants.FULL_PERCENT)
        .backgroundColor($r('app.color.home_content_bgc_color'))
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .mode(NavigationMode.Stack)
      .hideTitleBar(true)
      .hideBackButton(true)
      .hideToolBar(true)
    }.expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  TabBarBuilder(index: number, label?: Resource, defaultIcon?: Resource, activeIcon?: Resource, flag?: boolean) {
    if (flag) {
      Column().width($r('app.string.icon_image_width'))
    } else {
      Column() {
        Image(this.vm.currentIndex === index ? activeIcon : defaultIcon)
          .size({ width: $r('app.string.icon_image_width'), height: $r('app.string.icon_image_height') })
        Text(label)
          .fontSize($r('app.string.home_tab_fontsize'))
          .fontColor(this.vm.currentIndex === index ? $r('app.color.home_tab_active_color') :
          $r('app.color.home_tab_default_color'))
          .margin({ top: '3vp' })
      }
      .padding({ top: '5vp' })
    }
  }
}
