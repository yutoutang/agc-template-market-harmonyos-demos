import { CommonConstants, UserInfoModel, WindowModel } from 'lib_common';
import { CouponItem, CouponsServiceApi, StoreEnum } from 'lib_takeaway_api';
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { CouponCard } from './CouponCardComp';

@Builder
export function SelectCouponBuilder(selected: string, categoryGroup: StoreEnum | undefined, totalPrice: number,
  confirmCouponItem: (couponItem: CouponItem | undefined) => void) {
  SelectCoupon({
    categoryGroup: categoryGroup,
    selected: selected,
    totalPrice: totalPrice,
    confirmCouponItem: confirmCouponItem
  })
}

@ComponentV2
export struct SelectCoupon {
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  // 选中优惠券id
  @Param @Require selected: string;
  // 优惠券类型
  @Param @Require totalPrice: number;
  @Param @Require categoryGroup: StoreEnum;
  // 选中优惠券
  @Local selectedCoupon: CouponItem | undefined = undefined;
  @Local couponList: CouponItem[] = []
  @Event
  confirmCouponItem: (couponItem: CouponItem | undefined) => void = () => {
  }

  aboutToAppear() {
    let tempCouponList = CouponsServiceApi.getCanUseCoupons(this.categoryGroup);
    this.couponList = tempCouponList
    this.selectedCoupon = this.couponList.find(item => item.couponID === this.selected);
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: CommonConstants.SPACE_S }) {
          ForEach(this.couponList, (item: CouponItem) => {
            ListItem() {
              CouponCard({
                coupon: item,
                selectId: this.selected,
                isOrder: true,
                totalMoney: this.totalPrice,
                confirmCouponItem: (couponItem: CouponItem | undefined) => {
                  this.confirmCouponItem(couponItem)
                },
                isShowCheckBox: true
              })
            }.padding({})
          }, (item: CouponItem, index) => JSON.stringify(item) + '_' + index)
        }
      }
      .layoutWeight(1)
      .width(CommonConstants.FULL_PERCENT)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .padding({
      left: CommonConstants.PADDING_S,
      right: CommonConstants.PADDING_S,
      bottom: this.windowModel.windowBottomPadding,
      top: 10
    })
  }
}

