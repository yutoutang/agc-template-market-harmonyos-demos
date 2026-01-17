import { window } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { Coupons } from './SelectCouponsView';
import { CouponCardComp } from '../components/CouponCardComp';
import { TabComp } from '../components/TabComp';
import { CommonConstants, LOG_TAG, MY_TAB_BAR } from '../constants/Contants';
import { CouponItem } from '../network/types/responseTypes/GetCouponsResp';
import { getCouponList, getScenarioStatus } from '../utils/Service';
import { FullLoading } from '../utils/FullLoading';
import { WindowUtil } from '../utils/WindowUtil';
import { ScenarioStatus } from '../types/Types';

@ComponentV2
export struct MyCouponsView {
  @Local myCouponsAll: CouponItem[] = [];
  @Event useNow: (couponId: string) => void;
  private _tabBar: string[] = [];
  private _currentIndex: number = 0;

  @Computed
  get contentData() {
    const data: CouponItem[][] = [[], [], [], []];
    this.myCouponsAll.forEach(item => {
      const status = getScenarioStatus(item, 0);
      if (status === ScenarioStatus.EXPIRE) {
        data[3].push(item);
      } else if (status === ScenarioStatus.HAS_USED) {
        data[2].push(item);
      } else {
        data[1].push(item);
      }
    });
    data[0] = [...data[1], ...data[2], ...data[3]];
    return data;
  }

  async aboutToAppear() {
    this._tabBar = MY_TAB_BAR;
    try {
      if (!Coupons.uiContext) {
        let uiContext = this.getUIContext();
        let windowClass = await window.getLastWindow(uiContext.getHostContext());
        Coupons.uiContext = uiContext;
        FullLoading.init(uiContext);
        if (windowClass) {
          WindowUtil.init(windowClass, uiContext);
        }
      }
    } catch (err) {
      UtilLog.error(LOG_TAG, 'init context failed. error: ' + JSON.stringify(err))
    }
    const res = await getCouponList();
    this.myCouponsAll = res;
  }

  build() {
    TabComp({
      tabBar: this._tabBar,
      space: 40,
      index: this._currentIndex,
      contentUi: (index: number) => {
        this.tabContentBuilder(index);
      },
    })
  }

  @Builder
  tabContentBuilder(index: number) {
    List({ space: 8 }) {
      ForEach(this.contentData[index], (item: CouponItem) => {
        ListItem() {
          CouponCardComp({ coupon: item, clickCoupon: coupon => this.useNow(coupon.couponID) })
        }
      }, (item: CouponItem, index) => JSON.stringify(item) + '_' + index)
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.FULL_HEIGHT)
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
    .padding({ left: $r('app.string.padding_12'), right: $r('app.string.padding_12') })
  }
}