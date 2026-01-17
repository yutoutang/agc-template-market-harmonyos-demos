import { ComponentContent, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit'
import { UtilLog } from '@hw-agconnect/util-log';
import { CouponCardComp } from '../components/CouponCardComp';
import { TabComp } from '../components/TabComp';
import { CommonConstants, LOG_TAG, SELECT_TAB_BAR } from '../constants/Contants';
import { CouponItem } from '../network/types/responseTypes/GetCouponsResp';
import { OnPopParams, ScenarioStatus, SelectCouponParams } from '../types/Types';
import { getCouponList, getReduceAmount, getScenarioStatus } from '../utils/Service';
import { WindowUtil } from '../utils/WindowUtil';
import { FullLoading } from '../utils/FullLoading';

@ComponentV2
struct SelectCouponView {
  @Local myCouponsAll: CouponItem[] = [];
  @Local currentIndex: number = 0;
  @Local reduce: number = 0;
  @Once @Param selectId: string = '';
  @Once @Param totalMoney: number = 0;
  @Event confirm: (onPopParams: OnPopParams) => void;
  private _tabBar: string[] = [];

  @Computed
  get contentData() {
    const data: CouponItem[][] = [[], []];
    this.myCouponsAll.forEach(item => {
      if (item.couponID === this.selectId) {
        this.reduce = getReduceAmount(item, this.totalMoney);
      }
      const status = getScenarioStatus(item, this.totalMoney);
      switch (status) {
        case ScenarioStatus.NOW_USE:
          data[0].push(item);
          break;
        case ScenarioStatus.LESS_FULL:
        case ScenarioStatus.FUTURE_USE:
          data[1].push(item);
          break;
        default:
          break;
      }
    });
    // 减免多 => 减免少
    data[0].sort((a, b) => getReduceAmount(b, this.totalMoney) - getReduceAmount(a, this.totalMoney));
    // 满额不足 => 活动未开始
    data[1].sort((a, b) => getScenarioStatus(a, this.totalMoney) - getScenarioStatus(b, this.totalMoney));
    return data;
  }

  async aboutToAppear() {
    this._tabBar = SELECT_TAB_BAR;
    getCouponList().then((res) => {
      this.myCouponsAll = res;
    });
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
  }

  build() {
    Column() {
      TabComp({
        tabBar: this._tabBar,
        space: 150,
        index: this.currentIndex!!, // 双向绑定
        contentUi: (index: number) => {
          this.tabContentBuilder(index);
        },
      })

      if (!this.currentIndex) {
        this.bottomBuilder();
      }
    }
    .padding({ bottom: WindowUtil.getAvoidArea().bottom })
  }

  @Builder
  tabContentBuilder(index: number) {
    List({ space: 8 }) {
      ForEach(this.contentData[index], (item: CouponItem) => {
        ListItem() {
          CouponCardComp({
            coupon: item,
            isOrder: true,
            selectId: this.selectId,
            totalMoney: this.totalMoney,
            clickCoupon: (coupon: CouponItem) => {
              if (this.selectId === coupon.couponID) {
                this.selectId = '';
                this.reduce = 0;
              } else {
                this.selectId = coupon.couponID;
                this.reduce = getReduceAmount(coupon, this.totalMoney);
              }
            },
          })
        }
      }, (item: CouponItem, index) => JSON.stringify(item) + '_' + index)
    }
    .edgeEffect(EdgeEffect.None)
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.FULL_HEIGHT)
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
    .padding({ left: $r('app.string.padding_12'), right: $r('app.string.padding_12') })
  }

  @Builder
  bottomBuilder() {
    Row() {
      Text($r('app.string.selected_coupon', `${this.selectId ? 1 : 0}`))
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Caption_M'))
        .lineHeight($r('app.string.line_height_14'))

      Row() {
        Text($r('app.string.currency_symbol'))
          .fontColor($r('sys.color.multi_color_09'))
          .fontSize($r('app.string.font_size_8'))
          .fontWeight(FontWeight.Medium)
          .lineHeight($r('app.string.line_height_12'))
          .margin({ bottom: 1 })
        Text(this.reduce.toFixed(2))
          .fontColor($r('app.color.sys_brand_fuchsia'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .lineHeight($r('app.string.line_height_18'))
      }
      .margin({ left: $r('app.string.margin_6') })
      .alignItems(VerticalAlign.Bottom)

      Button($r('app.string.confirm'))
        .fontColor($r('sys.color.comp_background_list_card'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Bold)
        .height(32)
        .backgroundColor($r('app.color.sys_brand_fuchsia'))
        .padding({
          top: 8,
          left: 32,
          right: 32,
          bottom: 8,
        })
        .margin({ left: $r('app.string.margin_12') })
        .onClick(() => {
          this.confirm({ selectId: this.selectId, reduce: this.reduce });
          Coupons.close();
        })
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(56)
    .padding(16)
    .justifyContent(FlexAlign.End)
    .transition(TransitionEffect.translate({ y: '100%' }).animation({ duration: 100, curve: Curve.Smooth }))
  }
}

@Builder
export function selectCouponViewBuilder(params: SelectCouponParams) {
  SelectCouponView({ totalMoney: params.totalMoney, selectId: params.selectId, confirm: params.confirm })
}

export class Coupons {
  public static uiContext: UIContext;
  private static _sheetOption: SheetOptions = {
    title: { title: '选择优惠券' },
    showClose: false,
    height: '80%',
  };
  private static _contentNode: ComponentContent<SelectCouponParams>;

  public static initContext(uiContext: UIContext) {
    if (!Coupons.uiContext) {
      Coupons.uiContext = uiContext;
    }
  }

  public static async select(params: SelectCouponParams) {
    Coupons._contentNode = new ComponentContent(Coupons.uiContext, wrapBuilder(selectCouponViewBuilder), params);
    Coupons.uiContext.openBindSheet(Coupons._contentNode, Coupons._sheetOption).catch((err: BusinessError) => {
      UtilLog.error(LOG_TAG, 'open bind sheet failed. error: ' + JSON.stringify(err))
    })
  }

  public static close() {
    Coupons.uiContext.closeBindSheet(Coupons._contentNode).catch((err: BusinessError) => {
      UtilLog.error(LOG_TAG, 'close bind sheet failed. error: ' + JSON.stringify(err))
    })
  }
}

