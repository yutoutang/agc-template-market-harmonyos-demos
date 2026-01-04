import { AppStorageV2 } from '@kit.ArkUI';
import { NavHeaderBar } from 'lib_widget';
import { CouponItem, StoreEnum } from 'lib_takeaway_api';
import { CouponCard } from '../components/CouponCardComp';
import { TabComp } from 'lib_native_components';
import { MY_TAB_BAR_COUPONS, WindowModel } from 'lib_common';
import { getCouponList } from '../utils/CouponsUtils';

@ComponentV2
struct MyCouponsPage {
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local myCouponsAll: CouponItem[] = [];
  @Local refreshing: boolean[] = [];
  @Local refresh: boolean = false
  private tabBar: string[] = [];
  private currentIndex: number = 0;

  @Computed
  get contentData() {
    const data: CouponItem[][] = [[], [], [], [], []];
    this.myCouponsAll.forEach(item => {

      if (item.categoryGroup === StoreEnum.FOOD) {
        data[0].push(item);
      } else if (item.categoryGroup === StoreEnum.SUPERMARKET) {
        data[1].push(item);
      } else if (item.categoryGroup === StoreEnum.FRUIT) {
        data[2].push((item));
      } else if (item.categoryGroup === StoreEnum.PHARMACY) {
        data[3].push((item));
      } else if (item.categoryGroup === StoreEnum.ALL) {
        data[0].push((item));
        data[1].push((item));
        data[2].push((item));
        data[3].push((item));
        data[4].push((item));
      }
    })
    return data;
  }

  aboutToAppear() {
    this.tabBar = MY_TAB_BAR_COUPONS;
    this.refreshing = Array.from<boolean>({ length: this.tabBar.length }).fill(false);
    this.refresh = false
    getCouponList().then((res) => {
      this.myCouponsAll = res;
    })
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: '红包卡券' })

      TabComp({
        tabBar: this.tabBar,
        index: this.currentIndex,
        contentUi: (index: number) => {
          this.tabContentBuilder(index);
        },
      })
    }
    .padding({ bottom: this.windowModel.windowBottomPadding })
    .hideTitleBar(true)
  }

  @Builder
  tabContentBuilder(index: number) {
    Refresh({ refreshing: $$this.refresh }) {
      List({ space: 8 }) {
        ForEach(this.contentData[index], (item: CouponItem) => {
          ListItem() {
            CouponCard({ coupon: item })
          }
        }, (item: CouponItem, index) => JSON.stringify(item) + '_' + index)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
    }
    .onStateChange(status => {
      if (status === RefreshStatus.Refresh) {
        this.refreshing[index] = true;
      }
    })
    .onRefreshing(async () => {
      let myCoupons: CouponItem[] = await getCouponList()
      this.myCouponsAll = myCoupons;
      this.refreshing[index] = false;
      this.refresh = false
    })
    .align(Alignment.Top)
    .padding({
      top: 8,
      left: 12,
      right: 12,
      bottom: this.windowModel.windowBottomPadding
    })
  }
}

@Builder
export function MyCouponsPageBuilder() {
  MyCouponsPage()
}
