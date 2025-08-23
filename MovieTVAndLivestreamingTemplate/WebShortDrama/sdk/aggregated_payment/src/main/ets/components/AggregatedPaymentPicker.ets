import { Channel, ChannelType, PAYMENT_CHANNEL, PickerType, WxExtraInfo } from '../common/Constant';
import { OnWXResp, wxEventHandler } from '../model/WXApiWrap';
import { AggregatedPaymentVM } from '../viewmodel/AggregatedPaymentVM';
import { common } from '@kit.AbilityKit';
import { ChannelInfo } from '../model/Index';

@ComponentV2
export struct AggregatedPaymentPicker {
  vm: AggregatedPaymentVM = AggregatedPaymentVM.instance;
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  @Local isShow: boolean = false;
  @Local checkedType: number = 0;
  @Local wxPayResultText: string = '';
  @Local preOrderInfo: string | WxExtraInfo = '';
  @Local appId: string = '';
  @Param @Require title: string
  @Param @Require amount: number
  /**
   * 支付渠道及支付渠道信息
   */
  @Param channelInfo: ChannelInfo[] = [];
  /**
   * 支付宝支付成功跳转页面Name
   */
  @Param paySuccessEvent: (type: ChannelType) => void = () => {
  };
  private wxEventHandler = wxEventHandler;
  private onWXResp: OnWXResp = (resp) => {
    this.wxPayResultText = JSON.stringify(resp ?? {}, null, 2);
  };

  aboutToAppear(): void {
    this.wxEventHandler.registerOnWXRespCallback(this.onWXResp);
    this.checkedType = this.channelInfo[0].channelType;
  }

  aboutToDisappear(): void {
    this.wxEventHandler.unregisterOnWXRespCallback(this.onWXResp);
  }

  @Builder
  paymentChannelPicker() {
    Column() {
      Row()
        .width(48)
        .height(4)
        .margin({ top: 8 })
        .borderRadius(2)
        .backgroundColor($r('sys.color.icon_fourth'))

      Text(this.title)
        .fontSize(14)
        .fontColor($r('sys.color.font_secondary'))
        .lineHeight(19)
        .margin({ top: 68 })

      Text() {
        Span(`¥`)
          .fontSize(24)
        Span(`${this.amount.toFixed(2)}`)
          .fontSize(38)
      }
      .fontWeight(700)
      .fontColor('rgba(0, 0, 0, 0.9)')
      .height(50)
      .margin({ bottom: 19 })

      ForEach(this.channelInfo, (item: ChannelInfo) => {
        Row() {
          Row({ space: 16 }) {
            Image(item.icon).size({ width: 24, height: 24 });
            Text(item.name).fontWeight(500);
          };

          Radio({ value: item.channelType.toString(), group: 'checkboxGroup' })
            .checked(this.checkedType === item.channelType)
            .radioStyle({ checkedBackgroundColor: 0xed6f21 })
            .onChange((value: boolean) => {
              if (value) {
                this.checkedType = item.channelType;
                this.preOrderInfo = item.preOrderInfo;
                if (item.appId) {
                  this.appId = item.appId;
                }
              }
            });
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding(12);
      }, (item: ChannelInfo) => JSON.stringify(item));

      Button('确定付款')
        .width('100%')
        .margin({ top: 24 })
        .backgroundColor('#EC6E45')
        .onClick(() => {
          if (this.checkedType === ChannelType.ALI_PAY) {
            this.vm.aliPay(this.paySuccessEvent, this.preOrderInfo);
          } else if (this.checkedType === ChannelType.WECHAT_PAY) {
            let channel = this.channelInfo.find((item) => item.channelType === ChannelType.WECHAT_PAY);
            if (channel?.event) {
              channel.event();
            }
            this.vm.weChatPay(this.preOrderInfo, this.appId);
          } else {
            this.vm.huaweiPay(this.context, this.preOrderInfo, this.paySuccessEvent);

          }
        });
    }
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: 8
    })
  }

  build() {
    this.paymentChannelPicker();
  }
}
