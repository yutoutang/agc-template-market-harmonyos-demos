import { CommonConstants, RouterMap, RouterUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { RepaymentViewModel } from '../viewmodels/RepaymentVM';
import { RepaymentSchedule } from 'lib_loan_api';

@Builder
export function RepaymentPageBuilder() {
  RepaymentPage()
}

@ComponentV2
struct RepaymentPage {
  @Local vm: RepaymentViewModel = new RepaymentViewModel();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '我要还款',
        })
        Column({ space: CommonConstants.SPACE_M }) {
          this.RepaymentDetails()
          this.NoDataBuilder()
        }
        .layoutWeight(1)
        .align(Alignment.Top)
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
    .padding({ bottom: CommonConstants.PADDING_PAGE })
    .onShown(() => {
      this.vm.init();
    })
  }

  @Builder
  NoDataBuilder() {
    if (this.vm.loanWaitPayList.length === 0) {
      Column() {
        Image($r('app.media.no_data'))
          .height(120)
          .width(120);
        Text('暂无还款计划')
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
  }

  @Builder
  RepaymentDetails() {
    List({ space: CommonConstants.SPACE_M }) {
      ForEach(this.vm.loanWaitPayList, (item: RepaymentSchedule[]) => {
        ListItem() {
          Row() {
            Column({ space: CommonConstants.SPACE_M }) {
              Text(`待还本金：¥${(item[0]?.remainingPrincipal ?? 0).toLocaleString('en-US',
                { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .lineHeight(21)
                .fontColor($r('sys.color.font_primary'))
                .width(CommonConstants.FULL_PERCENT)
                .textAlign(TextAlign.Start)


              Text(`本期应还：¥${(item[0].total ?? 0).toLocaleString('en-US',
                { minimumFractionDigits: 2, maximumFractionDigits: 2 })} | 还款日：${item[0].dueDate}`)
                .fontSize(12)
                .lineHeight(14)
                .fontColor($r('sys.color.font_tertiary'))
                .width(CommonConstants.FULL_PERCENT)
                .textAlign(TextAlign.Start)
              Text(`贷款总额：¥${item[0].loanAmount.toLocaleString('en-US',
                {
                  minimumFractionDigits: 2,
                  maximumFractionDigits: 2
                })} | 剩余期数：${item.length}/${item[0].totalTerms}`)
                .fontSize(12)
                .lineHeight(14)
                .fontColor($r('sys.color.font_tertiary'))
                .width(CommonConstants.FULL_PERCENT)
                .textAlign(TextAlign.Start)
            }
            .layoutWeight(1)

            Image($r('app.media.ic_right'))
              .width($r('app.float.arrow_right_w'))
          }
          .width(CommonConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            const param: Record<string, Object> = {
              'repayment': item
            }
            RouterUtils.pushPathByName(RouterMap.PENDING_REPAYMENT, param);
          })
        }
        .width(CommonConstants.FULL_PERCENT)
        .backgroundColor(Color.White)
        .borderRadius(16)
        .padding({
          left: CommonConstants.SPACE_M,
          right: CommonConstants.SPACE_M,
          top: CommonConstants.SPACE_M,
          bottom: CommonConstants.SPACE_M,
        })
      },
        (item: RepaymentSchedule[], index: number) => JSON.stringify(item) + index)
    }
    .edgeEffect(EdgeEffect.Spring,{alwaysEnabled:true})
  }
}