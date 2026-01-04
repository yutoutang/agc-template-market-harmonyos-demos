import { CommonConstants, DoneConfirmDialog, Logger, RouterMap, RouterUtils, WindowModel } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { RepaymentSchedule } from 'lib_loan_api';
import { RepaymentViewModel } from '../viewmodels/RepaymentVM';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { AggregatedPaymentPicker, ChannelType, WxExtraInfo } from 'aggregated_payment';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Builder
export function PendingRepaymentBuilder() {
  PendingRepayment()
}

@ComponentV2
struct PendingRepayment {
  @Local hwOrderStr: string = '';
  @Local aliOrderStr: string = '';
  wxAppId: string = 'wx05b3e2e9fc730840' // todo: 替换自己申请的微信appid
  @Local isShow: boolean = false
  @Local vm: RepaymentViewModel = new RepaymentViewModel();
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local paramData: RepaymentSchedule[] = []
  private wxOrderReq: WxExtraInfo = new WxExtraInfo();

  @Builder
  paymentChannelSheet() {
    Column() {
      AggregatedPaymentPicker({
        price: this.vm.rePayment[0].total.toLocaleString('en-US',
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
          }
        ],
        paySuccessEvent: (type: ChannelType) => {
          this.vm.repayment(this.vm.rePayment[0].loadId, this.vm.rePayment[0].term, () => {
            this.isShow = false;
            DoneConfirmDialog.show({
              primaryTitle: '还款成功',
              priBtnV: '继续还款',
              content: `已成功还款第${this.vm.rePayment[0].term}期` + '\n请继续保持良好的还款记录哦~',
              confirm: () => {
                this.vm.getRepaymentSchedule(this.paramData[0].loadId)
              }
            })
          })
        },
        payFailEvent: (type: ChannelType) => {
          this.isShow = false;
          promptAction.showToast({ message: '还款失败' })
          Logger.error('AggregatedPaymentPicker-支付失败')
        }
      });
    }
    .padding({ bottom: this.windowModel.windowBottomPadding })
  }

  @Builder
  NoDataBuilder() {
    Column() {
      Image($r('app.media.no_data'))
        .height(120)
        .width(120);
      Text('暂无待还款账单')
        .fontSize(16)
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Medium)
        .lineHeight(19)
        .textAlign(TextAlign.Center)
        .width(CommonConstants.FULL_PERCENT);
    }
    .width(CommonConstants.FULL_PERCENT)
    .margin({ top: '20%' });
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '待还款账单',
      })
      Column({ space: CommonConstants.SPACE_L }) {
        if (this.vm.rePayment.length > 0) {
          this.currentPaymentTerm()
          this.PendingRepaymentDetails()
        } else {
          this.NoDataBuilder()
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .layoutWeight(1)
      .padding({ left: CommonConstants.PADDING_PAGE, right: CommonConstants.PADDING_PAGE })
    }
    .hideTitleBar(true)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ bottom: this.windowModel.windowBottomPadding })
    .onShown(() => {
      if (this.paramData.length > 0) {
        //获取id并查询
        this.vm.getRepaymentSchedule(this.paramData[0].loadId)
      }
    })
    .onReady(async (context: NavDestinationContext) => {
      if (context.pathInfo.param) {
        const params = context.pathInfo.param as Record<string, Object>;
        hilog.info(0, '待还款账单待还款账单1', JSON.stringify(params))
        this.paramData = params.repayment as RepaymentSchedule[];
      }
    })
  }

  @Builder
  currentPaymentTerm() {

    Column({ space: CommonConstants.SPACE_M }) {

      Text(this.vm.rePayment[0]?.dueDate ?? '' + '前应还')
        .fontSize(14)
        .lineHeight(16)
        .fontColor($r('sys.color.font_primary'));
      Text('¥' + this.vm.rePayment[0]?.total.toLocaleString('en-US',
        { minimumFractionDigits: 2, maximumFractionDigits: 2 }))
        .fontSize(32)
        .lineHeight(28)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold);


      Text('还款')
        .backgroundColor('#317AF7')
        .fontColor(Color.White)
        .fontSize(16)
        .lineHeight(19)
        .width('100%')
        .height(40)
        .padding({ top: 10, bottom: 10 })
        .textAlign(TextAlign.Center)
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
    .align(Alignment.Top)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .padding({
      left: CommonConstants.PADDING_XXL,
      right: CommonConstants.PADDING_XXL,
      top: CommonConstants.PADDING_PAGE,
      bottom: CommonConstants.PADDING_PAGE
    })

  }

  @Builder
  PendingRepaymentDetails() {
    List({ space: CommonConstants.SPACE_M }) {
      ForEach(this.vm.rePayment, (item: RepaymentSchedule, index: number) => {
        ListItem() {
          this.ScheduleItemBuilder(item, index)
        }
        .width(CommonConstants.FULL_PERCENT)
        .padding({
          left: CommonConstants.SPACE_M,
          right: CommonConstants.SPACE_M,
          top: CommonConstants.SPACE_M,
          bottom: CommonConstants.SPACE_M,
        })
      },
        (item: RepaymentSchedule) => item.dueDate
      )
    }
    .layoutWeight(1)
    .borderRadius(16)
    .scrollBar(BarState.Off)
    .backgroundColor('#FFFFFF')
    .edgeEffect(EdgeEffect.Spring,{alwaysEnabled:true})
  }

  @Builder
  ScheduleItemBuilder(item: RepaymentSchedule, index: number) {
    Row() {
      Column({ space: CommonConstants.SPACE_S }) {
        Text(`第${item.term}期`)
          .fontSize(14)
          .lineHeight(16)
          .fontColor($r('sys.color.font_primary'));
        Text(item.dueDate)
          .fontSize(14)
          .lineHeight(16)
          .fontColor($r('sys.color.font_tertiary'))
      }
      .alignItems(HorizontalAlign.Start);

      Row({ space: CommonConstants.SPACE_S }) {
        Text('¥' + item.total.toLocaleString('en-US',
          { minimumFractionDigits: 2, maximumFractionDigits: 2 }))
          .fontSize(16)
          .lineHeight(19)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium);
        Image($r('app.media.ic_right'))
          .width($r('app.float.arrow_right_w'));
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      const param: Record<string, Object> = {
        'repayment': item,
        'index': index
      };
      RouterUtils.pushPathByName(RouterMap.BILLING_DETAILS_PAGE, param);
    });
  }
}