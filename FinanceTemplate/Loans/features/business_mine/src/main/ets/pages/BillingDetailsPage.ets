import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { CommonConstants, DoneConfirmDialog, RouterUtils, WindowModel } from 'lib_common';
import { RepaymentSchedule } from 'lib_loan_api';
import { NavHeaderBar } from 'lib_widget';
import { AggregatedPaymentPicker, ChannelType, WxExtraInfo } from 'aggregated_payment';
import { RepaymentViewModel } from '../viewmodels/RepaymentVM';

@Builder
export function BillingDetailsBuilder() {
  BillingDetailsPage()
}

@ComponentV2
struct BillingDetailsPage {
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local vm: RepaymentViewModel = new RepaymentViewModel();
  @Local hwOrderStr: string = '';
  @Local aliOrderStr: string = '';
  @Local currentIndex: number = 0;
  wxAppId: string = 'wx05b3e2e9fc730840' // todo: 替换自己申请的微信appid
  @Local isShow: boolean = false
  private loanPending: RepaymentSchedule | null = null;
  private wxOrderReq: WxExtraInfo = new WxExtraInfo();

  @Builder
  paymentChannelSheet() {
    Column() {
      AggregatedPaymentPicker({
        price: this.loanPending?.total.toLocaleString('en-US',
          { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
        goodsName: '还款',
        channelInfo: [{
          channelType: ChannelType.HUAWEI_PAY,
          name: '华为支付',
          icon: $r('app.media.hwpay'),
          preOrderInfo: this.hwOrderStr,
        },
          {
            channelType: ChannelType.ALI_PAY,
            name: '支付宝支付',
            icon: $r('app.media.alipay'),
            preOrderInfo: this.aliOrderStr,
          },
          {
            channelType: ChannelType.WECHAT_PAY,
            preOrderInfo: this.wxOrderReq,
            appId: this.wxAppId,
            icon: $r('app.media.wechat'),
            name: '微信支付',
          }],
        paySuccessEvent: (type: ChannelType) => {
          this.vm.repayment(this.loanPending?.loadId ?? this.vm.rePayment[0].loadId,
            this.loanPending?.term ?? this.vm.rePayment[0].term, () => {
              this.isShow = false;
              DoneConfirmDialog.show({
                primaryTitle: '还款成功',
                priBtnV: '继续还款',
                content: `已成功还款第${this.loanPending?.term}期` + '\n请继续保持良好的还款记录哦~',
                confirm: () => {
                  RouterUtils.pop()
                }
              })
            })
        },
        payFailEvent: (type: ChannelType) => {
          promptAction.showToast({ message: '还款失败' })
          this.isShow = false;
        }
      });
    }
    .padding({ bottom: this.windowModel.windowBottomPadding })
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '账单详情',
        })
        Scroll() {
          Column({ space: CommonConstants.SPACE_M }) {
            this.currentPaymentTerm()
            // 贷款明细部分
            this.LoanTermDetailBuilder()

            Blank()
              .layoutWeight(1)
            Text('我要还款')
              .backgroundColor('#317AF7')
              .fontColor(Color.White)
              .fontSize(16)
              .lineHeight(19)
              .width('100%')
              .height(40)
              .padding({ top: 10, bottom: 10 })
              .textAlign(TextAlign.Center)
              .visibility(this.currentIndex === 0 ? Visibility.Visible : Visibility.None)
              .borderRadius(20)
              .onClick(async () => {
                this.isShow = true;
              })
              .bindSheet(this.isShow, this.paymentChannelSheet(),
                {
                  height: SheetSize.FIT_CONTENT,
                  preferType: SheetType.CENTER,
                  onDisappear: () => {
                    this.isShow = false;
                  }
                });
          }
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .padding({
          left: CommonConstants.PADDING_PAGE,
          right: CommonConstants.PADDING_PAGE,
          top: CommonConstants.SPACE_M,
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ bottom: this.windowModel.windowBottomPadding })
    .onReady((context: NavDestinationContext) => {
      if (context.pathInfo.param) {
        const params = context.pathInfo.param as Record<string, Object>;
        this.loanPending = params.repayment as RepaymentSchedule;
        this.currentIndex = params.index as number;
      }
    })
  }

  @Builder
  currentPaymentTerm() {
    Column({ space: CommonConstants.SPACE_M }) {

      Text(this.loanPending?.dueDate + '前应还')
        .fontSize(14)
        .lineHeight(16)
        .fontColor($r('sys.color.font_primary'));
      Text('¥' + this.loanPending?.total.toLocaleString('en-US',
        { minimumFractionDigits: 2, maximumFractionDigits: 2 }))
        .fontSize(32)
        .lineHeight(28)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold);
    }
    .align(Alignment.Top)
    .borderRadius(16)
    .padding({
      left: CommonConstants.PADDING_XXL,
      right: CommonConstants.PADDING_XXL,
      top: CommonConstants.PADDING_PAGE,
      bottom: CommonConstants.PADDING_PAGE
    })
  }

  @Builder
  LoanTermDetailBuilder() {
    // 贷款明细部分
    Column({ space: CommonConstants.SPACE_M }) {
      this.TitleBuilder('账单详情');
      Column({ space: CommonConstants.SPACE_M }) {
        if (this.loanPending) {
          this.ContentBuilder('当前期数', `${this.loanPending?.term}/${this.loanPending?.totalTerms}`);
          this.ContentBuilder('应还本金', this.loanPending?.principal);
          this.ContentBuilder('应还利息', this.loanPending?.interest);
          this.ContentBuilder('应还总额', this.loanPending?.total);
        }

        Row({ space: CommonConstants.SPACE_S }) {
          Image($r('app.media.tips_icon'))
            .width(16)
            .height(16);
          Text(`还款截止日期${this.loanPending?.dueDate}`)
            .fontSize(12)
            .lineHeight(14)
            .fontColor($r('sys.color.font_secondary'));
        }
        .width(CommonConstants.FULL_PERCENT)
        .borderRadius(8)
        .padding(CommonConstants.PADDING_S)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('sys.color.ohos_id_color_list_separator'));
      };
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding(CommonConstants.PADDING_M)
    .margin({ top: CommonConstants.SPACE_M })
    .borderRadius(16)
    .backgroundColor('#FFFFFF')
  }

  @Builder
  TitleBuilder(text: string) {

    Text(text)
      .fontSize(18)
      .lineHeight(21)
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Start)
      .width(CommonConstants.FULL_PERCENT)

  }

  @Builder
  ContentBuilder(title: string, text: string | number) {
    Row() {
      Text(title)
        .fontSize(14)
        .lineHeight(16)
        .fontColor($r('sys.color.font_secondary'))
      if (typeof text === 'number') {
        Text('¥' + text.toLocaleString('en-US',
          { minimumFractionDigits: 2, maximumFractionDigits: 2 }))
          .layoutWeight(1)
          .textAlign(TextAlign.End)
          .fontSize(14)
          .lineHeight(16)
          .fontColor($r('sys.color.font_secondary'))
      } else {
        Text(text)
          .layoutWeight(1)
          .textAlign(TextAlign.End)
          .fontSize(14)
          .lineHeight(16)
          .fontColor($r('sys.color.font_secondary'))
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({ top: CommonConstants.SPACE_S, bottom: CommonConstants.SPACE_S })
  }
}