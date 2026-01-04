import { CouponItem, StoreEnum } from 'lib_takeaway_api';
import { ReductionTypes, ScenarioStatus } from '../types/Types';
import { getReduceDays, getReduceDesc, getScenarioStatus } from '../utils/CouponsUtils';

@ComponentV2
export struct CouponCard {
  /** 接收参数 **/
  // 优惠券信息
  @Require @Param coupon: CouponItem;
  // 是否来源订单页;
  @Param isOrder: boolean = false;
  // 订单总金额;
  @Param totalMoney: number = 0;
  // 已选择优惠券ID;
  @Param selectId: string = '';
  // 是否展示勾选框;
  @Param isShowCheckBox: boolean = false;
  /** 本地参数 **/
  @Local showInstruction: boolean = false;
  private status: ScenarioStatus = ScenarioStatus.NOW_USE;

  // 选中优惠券回调
  @Event clickCoupon: (coupon: CouponItem) => void = () => {
  };

  @Event
  confirmCouponItem: (couponItem: CouponItem | undefined) => void = () => {
  }

  aboutToAppear() {
    this.status = getScenarioStatus(this.coupon, this.totalMoney);
  }

  build() {
    Column() {
      // 主体部分
      Row() {
        // 左
        Column({ space: 2 }) {
          Row({ space: 2 }) {
            if (this.coupon.amountRule.discountType === ReductionTypes.DISCOUNT_REDUCTION) {
              Text((Number(this.coupon.amountRule.discountCoefficient) * 10).toFixed(1)).leftMainNumberStyle()
              Text($r('app.string.discount')).leftMainUnitStyle().margin({ bottom: $r('app.string.margin_4') })
            } else {
              Text($r('app.string.currency_symbol')).leftMainUnitStyle().margin({ bottom: $r('app.string.margin_4') })
              Text(this.coupon.amountRule.discountAmount).leftMainNumberStyle()
            }
          }.alignItems(VerticalAlign.Bottom)

          if (this.coupon.amountRule.discountType === ReductionTypes.FULL_REDUCTION) {
            Text($r('app.string.full_available', `${Number(this.coupon.amountRule.fullAmount)}`)).leftSubStyle()
          } else if (this.coupon.amountRule.discountType === ReductionTypes.DISCOUNT_REDUCTION) {
            Text($r('app.string.discount_available', '新品')).leftSubStyle()
          } else {
            Text($r('app.string.no_threshold')).leftSubStyle()
          }
        }
        .justifyContent(FlexAlign.Center)
        .width(120)

        // 右
        Column({ space: 4 }) {
          Text(this.coupon.couponName)
            .maxLines(1)
            .fontColor('rgba(0, 0, 0, 0.9)')
            .lineHeight($r('app.string.line_height_21'))
            .fontWeight(FontWeight.Medium)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(getDesc(this.coupon))
            .rightSubStyle()
            .margin({ top: $r('app.string.margin_2') })

          Text(`${this.coupon.endTime + ' 23:59'} 到期`).rightSubStyle()

          if (this.isOrder &&
            (this.status === ScenarioStatus.FUTURE_USE || this.status === ScenarioStatus.LESS_FULL)) {
            Row({ space: 4 }) {
              Image($r('app.media.about_us')).width(12)
              if (this.status === ScenarioStatus.LESS_FULL) {
                Text($r('app.string.below_threshold',
                  (Number(this.coupon.amountRule.fullAmount) - this.totalMoney).toFixed(2))).rightReminderStyle()
              } else {
                Text($r('app.string.below_startTime', getReduceDays(this.coupon))).rightReminderStyle()
              }
            }
          }
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
        .padding({ left: $r('app.string.padding_12') })
        .border({ width: { left: 1 }, style: BorderStyle.Dashed, color: 'rgba(238, 59, 85, 0.2)' })

        if (this.isShowCheckBox && this.status === ScenarioStatus.NOW_USE) {
          Checkbox({ name: 'channelCheckBox', group: 'checkboxGroup' })
            .select(this.selectId === this.coupon.couponID)
            .shape(CheckBoxShape.CIRCLE)
            .onChange((value: boolean) => {
              if (value) {
                this.confirmCouponItem(this.coupon)
              } else {
                this.confirmCouponItem(undefined)
              }
            })
            .position({ top: 20, right: 15 })
        }

      }
      .clip(true)
      .width('100%')
      .borderRadius($r('app.string.border_radius_16'))
      .backgroundColor($r('app.color.sys_background_white'))
      .opacity(this.status === ScenarioStatus.NOW_USE ||
        (!this.isOrder && (this.status === ScenarioStatus.FUTURE_USE || this.status === ScenarioStatus.LESS_FULL)) ?
        1 : 0.4)
      .padding({ top: $r('app.string.padding_16'), bottom: $r('app.string.padding_16') })

      // 隐藏说明
      if (this.showInstruction) {
        Column({ space: 6 }) {
          Text($r('app.string.instruction_label'))
            .fontSize($r('app.string.font_size_10'))
            .fontColor($r('sys.color.font_secondary'))
          Text(`优惠时间: ${this.coupon.startTime}零点至${this.coupon.endTime}午时`).descTextStyle()
          Text(`优惠方式: ${getReduceDesc(this.coupon)}`).descTextStyle()
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .padding({
          top: 8,
          bottom: 8,
          left: 20,
          right: 20,
        })
      }
    }.width('100%')
  }
}

@Extend(Text)
function leftMainNumberStyle() {
  .fontWeight(FontWeight.Medium)
  .fontColor($r('app.color.sys_brand_fuchsia'))
  .fontSize($r('app.string.font_size_24'))
}

@Extend(Text)
function leftMainUnitStyle() {
  .fontColor($r('app.color.sys_brand_fuchsia'))
  .fontSize($r('app.string.font_size_12'))
}

@Extend(Text)
function leftSubStyle() {
  .fontColor($r('app.color.sys_brand_fuchsia'))
  .fontSize($r('app.string.font_size_10'))
  .lineHeight($r('app.string.line_height_13'))
}

@Extend(Text)
function rightSubStyle() {
  .fontSize($r('app.string.font_size_12'))
  .lineHeight($r('app.string.line_height_16'))
  .fontColor($r('app.color.sys_brand_fuchsia'))
}

@Extend(Text)
function rightReminderStyle() {
  .fontSize($r('app.string.font_size_12'))
  .fontColor($r('app.color.sys_brand_fuchsia'))
  .fontWeight(500)
}

@Extend(Text)
function descTextStyle() {
  .fontSize($r('app.string.font_size_8'))
  .fontColor($r('sys.color.font_secondary'))
}

function getDesc(coupon: CouponItem) {
  if (coupon.categoryGroup === StoreEnum.FOOD) {
    return $r('app.string.coupon_type_food')
  } else if (coupon.categoryGroup === StoreEnum.SUPERMARKET) {
    return $r('app.string.coupon_type_supermarket')
  } else if (coupon.categoryGroup === StoreEnum.FRUIT) {
    return $r('app.string.coupon_type_fruit')
  } else if (coupon.categoryGroup === StoreEnum.PHARMACY) {
    return $r('app.string.coupon_type_pharmacy')
  } else if (coupon.categoryGroup === StoreEnum.ALL) {
    return $r('app.string.coupon_type_common')
  }
  return $r('app.string.coupon_type_common')
}