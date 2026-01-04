import { CommonConstants, LocationUtils } from 'lib_common';
import { HomePageBuilder } from 'business_home';
import { MinePageBuilder } from 'business_mine';
import { HomeMapBuilder } from 'business_map';
import { CustomTabBar } from '../components/CustomTabBar';
import { IndexPageViewModel } from '../viewmodels/IndexPageVM';
import { StopNavigation,MapChooseType } from 'module_map_detail';
import { mapCommon } from '@kit.MapKit';

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
  @Local isShowMap: boolean = false
  @Provider() latitude: number | undefined = undefined
  @Provider() longitude: number | undefined = undefined
  @Provider() address?: string = '我的位置'
  @Provider() addressAction?: string = ''
  @Provider() selectAddress?: string = '你要去哪'
  @Provider() selectedLatitude: number | undefined = undefined
  @Provider() selectedLongitude: number | undefined = undefined
  @Provider() isShowPlanning: boolean = false;
  private context: Context = this.getUIContext().getHostContext()!;

  @Monitor('selectedIndex')
  async onChangeTabIndex() {
    this.vm.tabModel.selectedIndex = this.selectedIndex;
    if (this.selectedIndex !== 1) {
      // 进入首页 获取一次当前定位
      let location: mapCommon.LatLng = await LocationUtils.getGCJ02CurrentLocation()
      this.address = '我的位置'
      this.longitude = location.longitude
      this.latitude = location.latitude
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Tabs({ index: $$this.selectedIndex }) {
          TabContent() {
            HomePageBuilder()
          }

          TabContent() {
            HomeMapBuilder(this.isShowMap)
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
    .onReady(async (context: NavDestinationContext) => {
      this.vm.onReady(context);
      if (context.pathInfo.param !== undefined) {
        if (context.pathInfo.param === true) {
          this.selectedIndex = 1
          this.isShowMap = true
        } else {
          await this.stopDetailPush(context);
        }
      }

    })
    .onBackPressed(() => {
      return this.vm.onBackPressed();
    })
  }

  private async stopDetailPush(context: NavDestinationContext) {
    let record = context.pathInfo.param as Record<string, Object>;
    let stopNavigation = record.stopNavigation as StopNavigation;
    if (stopNavigation) {
      // 站点详情跳转
      let location: mapCommon.LatLng = await LocationUtils.getGCJ02CurrentLocation();
      if (stopNavigation.chooseType === MapChooseType.TARGET) {
        this.address = '我的位置';
        this.latitude = location.latitude;
        this.longitude = location.longitude;
        this.selectAddress = stopNavigation.stopDetail?.name;
        this.selectedLatitude = stopNavigation.stopDetail?.latitude;
        this.selectedLongitude = stopNavigation.stopDetail?.longitude;
      } else {
        this.selectAddress = '你要去哪';
        this.selectedLatitude = undefined;
        this.selectedLongitude = undefined;
        this.address = stopNavigation.stopDetail?.name;
        this.latitude = stopNavigation.stopDetail?.latitude;
        this.longitude = stopNavigation.stopDetail?.longitude;
      }
      this.isShowPlanning = true;
      this.selectedIndex = 1;
    }
  }
}
