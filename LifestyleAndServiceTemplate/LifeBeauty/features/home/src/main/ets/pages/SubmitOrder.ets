import { common } from '@kit.AbilityKit';
import { paymentService } from '@kit.PaymentKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import {
  BreakpointModel,
  CommonUtils,
  GetUserInfoResp,
  ISubmitOrderRequest,
  preOrder,
  RouterMap,
  RouterModule,
  SimpleGoodInfo,
  SimpleOrderInfo,
  StoreInfoModel,
  UIOrderPart,
} from 'foundation';
import { NumberStepper } from '../components/NumberStepper';


@Builder
export function SubmitOrderBuilder() {
  SubmitOrder()
}

const TAG = '[SubmitOrder]';

@ComponentV2
export struct SubmitOrder {
  context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Local goodInfo: SimpleGoodInfo = new SimpleGoodInfo();
  @Local name: string = '';
  @Local phone: string = '';
  @Local remark: string = '';
  @Local number: number = 1;
  @Local numStr: string = '1';
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Local userInfo: GetUserInfoResp = PersistenceV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;
  @Local orderNo: string = '';

  aboutToAppear(): void {
    const paramList: Array<SimpleGoodInfo> = RouterModule.getNavParam({ url: RouterMap.SUBMIT_ORDER });
    if (paramList.length) {
      this.goodInfo = paramList[paramList.length - 1];
    }
    this.phone = this.userInfo.mobile;
  }

  @Computed
  get totalPrice() {
    return this.number * this.goodInfo.price;
  }

  @Computed
  get totalPay() {
    return this.number * this.goodInfo.vipPrice;
  }

  // 优惠
  @Computed
  get discount() {
    const diff = this.goodInfo.price - this.goodInfo.vipPrice;
    const temp = this.number * diff
    return CommonUtils.handleCash(temp)
  }

  submit() {
    const data = this.buildParam();
    preOrder(data).then((resp) => {
      this.orderNo = resp
      this.requestPaymentPromise().then(() => {
        this.onPayFail()
      });
    });
  }

  // 调用华为支付客户端
  requestPaymentPromise(): Promise<void> {
    // todo: 补充订购信息
    const orderStr = '{}';
    return paymentService.requestPayment(this.context, orderStr)
      .then(() => {
        Logger.info(TAG, 'succeeded in paying');
      })
      .catch((error: BusinessError) => {
        Logger.error(TAG, `failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
      });
  }

  onPayFail() {
    ToastDialog.showToast({
      message: '元服务的支付服务暂不可用，mock一个支付成功记录。',
    })
    const param = this.buildRouteParam();
    RouterModule.push({
      url: RouterMap.SUCCESS_PAY, param: param,
    });
  }

  buildParam() {
    const data: ISubmitOrderRequest = {
      projectId: this.goodInfo.id,
      type: this.goodInfo.type,
      contactName: this.name,
      contactPhone: this.phone,
      remark: this.remark,
      numbers: this.number,
      actualPay: this.totalPay,
      groupStoreId: this.storeModel.storeId,
    };

    return data;
  }

  buildRouteParam() {
    const param = new SimpleOrderInfo();
    param.type = this.goodInfo.type;
    param.title = this.goodInfo.title;
    param.subTitle = this.goodInfo.subTitle;
    param.vipPrice = this.goodInfo.vipPrice * this.number;
    param.price = this.goodInfo.price * this.number;
    param.image = this.goodInfo.image;
    param.contactName = this.name;
    param.contactPhone = this.phone;
    param.remark = this.remark;
    param.numbers = this.number;
    param.actualPay = this.totalPay;
    param.availableNum = (this.goodInfo.availableNum || 0) * this.number;
    param.goodId = this.goodInfo.id;
    param.orderNo = this.orderNo;
    return param;
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column({ space: 10 }) {
            this.FormCard1()
            this.FormCard2()
            this.FormCard3()
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .padding({
          left: this.breakPointModel.pagePadding,
          right: this.breakPointModel.pagePadding,
          top: 10,
          bottom: 10
        })
        .align(Alignment.Top)

        this.BottomOperate()
      }
      .width('100%')
    }
    .title('下单')
    .backgroundColor($r('app.color.common_page_bg'))
  }

  @Builder
  FormCard1() {
    Column() {
      UIOrderPart({ goodInfo: this.goodInfo })
      Divider().color($r('sys.color.comp_divider')).margin({top: 16})
      Row() {
        NumberStepper({
          value: this.number,
          min: 1,
          max: 1000,
          buttonType: ButtonType.Circle,
          isBorder: false,
          onChange: (value) => {
            if (value <= 0) {
              return;
            }
            if (value > 1000) {
              return;
            }
            this.number = value;
          },
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .margin({top: 12})
    }
    .width('100%')
    .padding(12)
    .borderRadius(16)
    .backgroundColor(Color.White)
  }

  @Builder
  FormCard2() {
    Column() {
      Row() {
        Text('商品总价')
        Text('(' + this.number + '件)').margin({left: 6}).fontSize(12).fontWeight(400)
          .fontColor($r('sys.color.font_secondary'))
        Blank()
        Text('￥' + CommonUtils.handleCash(this.totalPrice)).fontSize(16).fontWeight(500)
      }
      .width('100%')
      .alignItems(VerticalAlign.Bottom)

      if (this.discount) {
        Row() {
          Image($r('app.media.ic_discount_sales')).width(24).height(24)
          Text('已享优惠').margin({left: 16}).fontSize(16).fontWeight(500)

          Blank()
          Text('-￥' + this.discount).fontSize(14).fontWeight(500).fontColor($r('sys.color.warning'))
        }
        .width('100%')
        .margin({top: 28})

        Divider().color($r('sys.color.comp_divider')).margin({top: 12, bottom: 12})
      }

      Row() {
        Text('小计').fontSize(14).fontWeight(500)
        Text('￥').fontSize(10).fontWeight(500).fontColor($r('sys.color.warning'))
        Text('' + CommonUtils.handleCash(this.totalPay))
          .fontSize(14)
          .fontWeight(500)
          .fontColor($r('sys.color.warning'))
        if (this.goodInfo.availableNum) {
          Text('/' + (this.number * this.goodInfo.availableNum) + '次')
            .fontSize(10)
            .fontWeight(500)
            .fontColor($r('sys.color.warning'))
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Bottom)
    }
    .width('100%')
    .padding(12)
    .borderRadius(16)
    .backgroundColor(Color.White)
  }

  @Builder
  FormCard3() {
    Column() {
      Text('购买须知').fontSize(18).fontWeight(700).margin({ top: 14, bottom: 10 })
      Column({space: 12}) {
        Row({space: 12}) {
          Image($r('app.media.icon_public_clock')).width(16).height(16)

          Column({space: 4}) {
            Text('使用时间').fontSize(12).fontWeight(400)
            Text('营业时间内可用').fontSize(10).fontWeight(400)
          }
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)

        Divider().color($r('sys.color.comp_divider')).margin({left: 22})

        Row({space: 12}) {
          Image($r('app.media.icon_public_doc')).width(16).height(16)

          Column({ space: 4 }) {
            Text('使用规则').fontSize(12).fontWeight(400)
            Text('1、提前一个小时预约').fontSize(10).fontWeight(400)
            Text('2、未核销的预约逾期自动返还次数').fontSize(10).fontWeight(400)
          }
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }
      .width('100%')
      .padding(12)
      .borderRadius(16)
      .backgroundColor(Color.White)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  BottomOperate() {
    Row() {
      Button('立即支付', { type: ButtonType.Capsule, stateEffect: true })
        .width('100%')
        .backgroundColor($r('app.color.common_theme_color'))
        .fontColor($r('sys.color.font_on_primary'))
        .onClick(() => {
          this.submit();
        })
    }
    .width('100%')
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
      bottom: 12,
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
