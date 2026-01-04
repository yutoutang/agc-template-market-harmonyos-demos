import { CommonConstants } from 'lib_common';
import { HomePageBuilder } from 'business_home';
import { MinePageBuilder } from 'business_mine';
import { DesktopComponentsPageBuilder } from 'business_desktop';
import { CustomTabBar } from '../components/CustomTabBar';
import { IndexPageViewModel } from '../viewmodels/IndexPageVM';

/**
 * index页面
 */
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
  }

  @Monitor('selectedIndex')
  onChangeTabIndex() {
    this.vm.tabModel.selectedIndex = this.selectedIndex;
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Tabs({ index: $$this.selectedIndex }) {
          TabContent() {
            HomePageBuilder()
          }
          .padding({
            bottom: this.vm.tabPaddingBottom
          })

          TabContent() {
            DesktopComponentsPageBuilder()
          }
          .padding({
            bottom: this.vm.tabPaddingBottom
          })

          TabContent() {
            MinePageBuilder()
          }
          .padding({
            bottom: this.vm.tabPaddingBottom
          })
        }
        .width(CommonConstants.FULL_PERCENT)
        .layoutWeight(1)
        .barHeight(0)
        .scrollable(false)
        .onChange((index) => {
          this.selectedIndex = index;
        })

        CustomTabBar({
          fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
        })
          .translate({ x: 0, y: this.vm.translateY })
          .animation({ duration: 200, curve: Curve.EaseInOut })
          .onAreaChange((ov: Area, nv: Area) => {
            this.vm.tabPaddingBottom = nv.height;
            this.vm.tabModel.tabHeight = nv.height
          })
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.vm.onReady(context);
    })
    .onShown(() => {
      if (this.vm.formCardRouter.formId) {
        this.vm.checkMyComponent();
      }
    })
    .onBackPressed(() => {
      return this.vm.onBackPressed();
    })
  }
}
