import { CommonConstants } from 'lib_common';
import { HomePageBuilder } from 'business_home';
import { MinePageBuilder } from 'business_mine';
import { VideoPageBuilder } from 'business_video';
import { InteractionPageBuilder } from 'business_interaction';
import { CustomTabBar } from '../components/CustomTabBar';
import { IndexPageViewModel } from '../viewmodels/IndexPageVM';
import { TabBarItem, TABS_INFO } from '../common/Constants';

@Builder
export function IndexPageBuilder() {
  IndexPage()
}

@ComponentV2
struct IndexPage {
  @Local vm: IndexPageViewModel = new IndexPageViewModel();
  @Provider() selectedIndex: number = 0;

  aboutToAppear(): void {
    this.vm.refreshUserInfo();
    this.vm.checkJumpNewsDetail();
    this.vm.checkContinueScene();
  }

  @Monitor('selectedIndex')
  onChangeTabIndex() {
    this.vm.tabModel.selectedIndex = this.selectedIndex;
  }

  build() {
    NavDestination() {
      Column() {
        Tabs({ index: $$this.selectedIndex }) {
          TabContent() {
            HomePageBuilder()
          }
          .tabBar(this.tabBuilder(TABS_INFO[0]))

          TabContent() {
            VideoPageBuilder()
          }
          .tabBar(this.tabBuilder(TABS_INFO[1]))

          TabContent() {
            InteractionPageBuilder()
          }
          .tabBar(this.tabBuilder(TABS_INFO[2]))

          TabContent() {
            MinePageBuilder()
          }
          .tabBar(this.tabBuilder(TABS_INFO[3]))
        }
        .barWidth(this.vm.tabWidth)
        .barHeight(this.vm.tabBarHeight)
        .animation({ duration: 200, curve: Curve.EaseInOut })
        .vertical(this.vm.tabModel.isTabVertical)
        .barPosition(this.vm.barPosition)
        .scrollable(false)
        .divider(this.vm.showDivider)
        .barOverlap(!this.vm.tabModel.isTabVertical)
        .barBackgroundColor(this.vm.barBgColor)
        .barBackgroundBlurStyle(BlurStyle.NONE)
        .animationDuration(0)
        .onChange((index) => {
          this.selectedIndex = index;
        })
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .backgroundColor(this.vm.pageBgColor)
      .padding({
        bottom: this.vm.paddingBottom,
      })
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      return this.vm.onBackPressed();
    })
  }

  @Builder
  tabBuilder(item: TabBarItem) {
    CustomTabBar({ item: item })
      .translate({ x: 0, y: this.vm.translateY })
      .animation({ duration: 200, curve: Curve.EaseInOut })
      .onAreaChange((ov: Area, nv: Area) => {
        this.vm.tabModel.tabHeight = nv.height
      })
  }
}
