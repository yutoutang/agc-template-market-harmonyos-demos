import { CommonConstants, Logger } from 'lib_common';
import { DrinkVM, HomePageBuilder } from 'business_home';
import { MinePageBuilder } from 'business_mine';
import { CustomTabBar } from '../components/CustomTabBar';
import { IndexPageViewModel } from '../viewmodels/IndexPageVM';
import { SportPageBuilder } from 'business_sport';
import { emitter } from '@kit.BasicServicesKit';
import { SportServiceApi } from 'lib_sport_api';

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
  @Local stack: NavPathStack = new NavPathStack();
  private controller: TabsController = new TabsController();

  aboutToAppear(): void {
    try {
      this.vm.refreshUserInfo();

      emitter.on<number>('switchTabIndex', (data) => {
        if (data.data) {
          this.selectedIndex = data.data
        }
      })
      // 初始化运动mock数据
      SportServiceApi.initData()
      setTimeout(() => {
        this.controller.preloadItems([0, 1, 2])
      }, 100)
    } catch (error) {
      Logger.error('IndexPage', 'aboutToAppear error: ' + JSON.stringify(error))
    }
  }

  @Monitor('selectedIndex')
  onChangeTabIndex() {
    this.vm.tabModel.selectedIndex = this.selectedIndex;
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          Tabs({ index: $$this.selectedIndex, controller: this.controller }) {
            TabContent() {
              HomePageBuilder(this.stack)
            }

            TabContent() {
              SportPageBuilder()
            }

            TabContent() {
              MinePageBuilder()
            }

          }
          .width(CommonConstants.FULL_PERCENT)
          .layoutWeight(1)
          .barHeight(0)
          .scrollable(false)
          .onChange((index) => {
            this.selectedIndex = index;
            if (index === 1) {
              this.vm.watchOperation()
            }
          })

          //占位下方的自定义tabbar组件
          Row() {
            CustomTabBar({
              fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
            })
          }.opacity(0)
        }

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
      this.stack = context.pathStack;
    })
    .onHidden(() => {
      DrinkVM.saveRecord()
    })
    .onBackPressed(() => {
      return this.vm.onBackPressed();
    })
  }
}
