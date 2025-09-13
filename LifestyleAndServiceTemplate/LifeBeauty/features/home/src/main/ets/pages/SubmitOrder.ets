import { common } from '@kit.AbilityKit';
import { paymentService } from '@kit.PaymentKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  CommonUtils,
  ISubmitOrderRequest,
  Logger,
  PHONE_REG,
  preOrder,
  RouterMap,
  RouterModule,
  SimpleGoodInfo,
  SimpleOrderInfo,
  UIOrderPart,
} from 'foundation';
import { ConstantsHome } from '../common/Constant';

@Builder
export function SubmitOrderBuilder() {
  SubmitOrder()
}

@Extend(Column)
function cardContainer() {
  .width('100%')
  .padding({
    top: 9,
    bottom: 9,
    left: 12,
    right: 12,
  })
  .borderRadius(8)
  .backgroundColor(Color.White)
}

const TAG = '[SubmitOrder]';

@ComponentV2
export struct SubmitOrder {
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  @Local goodInfo: SimpleGoodInfo = new SimpleGoodInfo();
  @Local name: string = '';
  @Local phone: string = '';
  @Local remark: string = '';
  number: number = 1;
  // todo: 实际商户条件具备后，修改为false
  private ignoreRequestPayment: boolean = true;

  aboutToAppear(): void {
    const paramList: Array<SimpleGoodInfo> = RouterModule.getNavParam({ url: RouterMap.SUBMIT_ORDER });
    if (paramList.length) {
      this.goodInfo = paramList[paramList.length - 1];
    }
  }

  submit() {
    const isValid = this.validate();
    if (!isValid) {
      return;
    }
    const data = this.buildParam();
    preOrder(data).then(() => {
      this.requestPaymentPromise().then(() => {
        const param = this.buildRouteParam();
        RouterModule.push({
          url: RouterMap.SUCCESS_PAY, param: param,
        });
      });
    });
  }

  // 调用华为支付客户端
  requestPaymentPromise(): Promise<void> {
    if (this.ignoreRequestPayment) {
      return new Promise((resolve) => resolve());
    }
    // todo: 补充订购信息
    const orderStr = '{}';
    return paymentService.requestPayment(this.context, orderStr)
      .then(() => {
        Logger.info(TAG, 'succeeded in paying');
      })
      .catch((error: BusinessError) => {
        Logger.error(TAG, `failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
        this.getUIContext().getPromptAction().showToast({ message: '拉起支付失败' });
      });
  }

  validate() {
    if (!this.name) {
      this.getUIContext().getPromptAction().showToast({ message: '请填写姓名' });
      return false;
    }

    if (!this.phone) {
      this.getUIContext().getPromptAction().showToast({ message: '请填写联系方式' });
      return false;
    }

    if (!PHONE_REG.test(this.phone)) {
      this.getUIContext().getPromptAction().showToast({ message: '电话号码不正确' });
      return false;
    }

    return true;
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
    };

    return data;
  }

  buildRouteParam() {
    const param = new SimpleOrderInfo();
    param.title = this.goodInfo.title;
    param.subTitle = this.goodInfo.subTitle;
    param.vipPrice = this.goodInfo.vipPrice;
    param.image = this.goodInfo.image;
    param.contactName = this.name;
    param.contactPhone = this.phone;
    param.remark = this.remark;
    param.numbers = this.number;
    param.actualPay = this.totalPay;
    return param;
  }

  @Builder
  FormCard1() {
    Column() {
      Row() {
        Row({ space: 4 }) {
          Text('*').fontColor(Color.Red).fontSize(16).fontWeight(500)
          Text('姓名').fontSize(16).fontWeight(500)
        }

        Blank()
        TextInput({ text: $$this.name, placeholder: '请填写姓名' })
          .padding(0)
          .borderRadius(0)
          .backgroundColor(Color.Transparent)
          .width('70%')
          .textAlign(TextAlign.End)
      }.width('100%').height(48)

      Divider().margin({ bottom: 8 })

      Row() {
        Row({ space: 4 }) {
          Text('*').fontColor(Color.Red).fontSize(16).fontWeight(500)
          Text('电话').fontSize(16).fontWeight(500)
        }

        Blank()
        TextInput({ text: $$this.phone, placeholder: '请填写联系方式' })
          .type(InputType.PhoneNumber)
          .backgroundColor(Color.Transparent)
          .width('70%')
          .textAlign(TextAlign.End)
          .padding(0)
          .borderRadius(0)
      }.width('100%').height(48)

    }.cardContainer()
  }

  @Computed
  get totalPay() {
    return this.number * this.goodInfo.vipPrice;
  }

  @Builder
  FormCard2() {
    Row() {
      UIOrderPart({ goodInfo: this.goodInfo })
    }
    .width('100%')
    .padding({
      top: 10,
      bottom: 10,
      left: 7,
      right: 10,
    })
    .borderRadius(8)
    .backgroundColor(Color.White)
  }

  @Builder
  FormCard3() {
    Column() {
      Row() {
        Text('支付方式').fontSize(16).fontWeight(500)
        Blank()
        Row({ space: 6 }) {
          Image($r('app.media.ic_huawei_pay')).width(16).height(16).borderRadius(4)
          Text('华为支付')
        }
      }.width('100%').height(48)

      Divider().margin({ bottom: 8 })

      Column({ space: 10 }) {
        Text('备注').fontSize(16).fontWeight(500)
        TextArea({ placeholder: '请填写备注信息', text: $$this.remark })
          .maxLines(3)
          .height(70)
          .placeholderColor('#C7C7C7')
          .maxLength(ConstantsHome.MAX_REMARK_LENGTH)
          .showCounter(true, { highlightBorder: false })
          .backgroundColor(Color.Transparent)
          .borderRadius(0)
          .padding(0)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }.cardContainer()
  }

  @Builder
  BottomOperate() {
    Row() {
      Row({ space: 8 }) {
        Text('实付').fontSize(12).fontColor('#565656')
        Text('￥' + CommonUtils.handleCash(this.totalPay)).fontColor('#E84026').fontSize(20).fontWeight(500)
      }

      Blank()

      Button('提交订单')
        .padding({
          top: 9,
          bottom: 9,
          left: 16,
          right: 16,
        })
        .backgroundColor($r('app.color.common_theme_color'))
        .fontColor($r('sys.color.font_on_primary'))
        .onClick(() => {
          this.submit();
        })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding({
      left: 10,
      right: 10,
      top: 15,
      bottom: 10,
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
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
        .padding(10)
        .align(Alignment.Top)

        this.BottomOperate()
      }
      .width('100%')
    }
    .title('下单', { backgroundColor: Color.White })
    .backgroundColor($r('app.color.common_page_bg'))
  }
}
