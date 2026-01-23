import { common } from '@kit.AbilityKit';
import { ChannelInfo } from '../model/Channel';
import { promptAction } from '@kit.ArkUI';
import { paymentService } from '@kit.PaymentKit';
import { RouterModule } from 'commonlib';
import { UserInfoRouter } from '../model/UserInfoModel';

@ComponentV2
export struct AggregatedPaymentPicker {
  context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Param isShow: boolean = false;
  @Event onShowedChange:(value:boolean) => void
  @Local checkedType: number = 0;
  @Local preOrderInfo: string = '';
  @Local appId: string = '';
  @Local userInfoRouter: UserInfoRouter = UserInfoRouter.instance

  /**
   * 支付渠道及支付渠道信息
   */
  @Param channelInfo: ChannelInfo[] = [];

  aboutToAppear(): void {
    this.checkedType = this.channelInfo[0].channelType;
  }

  @Builder
  paymentChannelPicker() {
    Column() {
      ForEach(this.channelInfo, (item: ChannelInfo) => {
        Row() {
          Row({ space: 16 }) {
            Image(item.icon).size({ width: 24, height: 24 });
            Text(item.name).fontWeight(500);
          };

          Checkbox({ name: 'channelCheckBox', group: 'checkboxGroup' })
            .select(this.checkedType === item.channelType)
            .selectedColor(0xed6f21)
            .shape(CheckBoxShape.CIRCLE)
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
      },(item: ChannelInfo) => JSON.stringify(item));
      Button('确定付款').width('100%').backgroundColor(Color.Red).onClick(() => {
        this.huaweiPay(this.context, this.preOrderInfo);
      });
    }.padding(12);
  }

  build() {
    this.paymentChannelPicker();
  }

  huaweiPay(context: common.UIAbilityContext, orderStr: string) {
    paymentService.requestPayment(context, String(orderStr)).then(() => {
      this.paySuccess();
    }).catch(() => {
      this.paySuccess();
    });
  }

  paySuccess() {
    this.getUIContext().getPromptAction().showToast({ message: '开通成功' })
    this.onShowedChange(false)
    this.userInfoRouter.isVip = true
    RouterModule.pop()
  }
}
