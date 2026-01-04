import { CommonConstants, RouterMap, RouterUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { LoanViewModel } from '../viewmodels/LoanRecordVm';
import { LoanRecordLite, LoanStatusEnum } from 'lib_loan_api';

@Builder
export function LoanRecordPageBuilder() {
  loanRecordPage()
}

@ComponentV2
struct loanRecordPage {
  @Local vm: LoanViewModel = new LoanViewModel();

  aboutToDisappear(): void {
    this.vm.clearRefreshTimer();
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '贷款记录',
        })
        Scroll() {
          Column({ space: CommonConstants.SPACE_M }) {
            List({ space: CommonConstants.SPACE_M }) {
              ForEach(this.vm.loanRecordListLite, (item: LoanRecordLite, index: number) => {
                ListItem() {
                  Row() {
                    Column({
                      space: CommonConstants.SPACE_XS
                    }) {
                      Text(`￥${(item.loanAmount ?? 0).toLocaleString('en-US',
                        { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`)
                        .fontWeight(FontWeight.Bold)
                        .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
                        .lineHeight(21)
                        .fontColor($r('sys.color.font_primary'))
                      Row() {
                        Text(`${item.createTime}`)
                          .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
                          .fontColor($r('sys.color.font_tertiary'))
                          .lineHeight(14)
                        Blank()
                        Text('借款')
                          .fontColor($r('sys.color.font_tertiary'))
                          .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
                          .lineHeight(14)
                      }
                    }
                    .alignItems(HorizontalAlign.Start)

                    Row() {
                      Column({ space: CommonConstants.SPACE_M }) {

                        Text(this.vm.getStatusName(item.loanStatus ?? 0))
                          .textAlign(TextAlign.End)
                          .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
                          .lineHeight(16)
                          .fontColor(item.loanStatus === 2 ? $r('sys.color.warning') : '#99000000')
                        if (item.loanStatus === LoanStatusEnum.Repaying && item.returnedAmount) {
                          Text(`待还本金:${item.returnedAmount.toLocaleString('en-US',
                            { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`)
                            .textAlign(TextAlign.End)
                            .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
                            .lineHeight(14)
                        }
                        if (item.rejectReason && item.loanStatus === LoanStatusEnum.Rejected) {
                          Text(`${item.rejectReason}`)
                            .textAlign(TextAlign.End)
                            .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
                            .lineHeight(14)
                            .fontColor($r('sys.color.font_tertiary'))
                        }
                      }
                      .alignItems(HorizontalAlign.End)
                      .padding({ right: CommonConstants.SPACE_XS })

                      Image($r('app.media.ic_right'))
                        .width($r('app.float.arrow_right_w'))
                    }
                    .alignItems(VerticalAlign.Center)
                  }
                  .width(CommonConstants.FULL_PERCENT)
                  .justifyContent(FlexAlign.SpaceBetween)
                  .onClick(() => {
                    const param: Record<string, Object> = {
                      'question': this.vm.loanRecordList[index]
                    }
                    RouterUtils.pushPathByName(RouterMap.LOAN_DETAILS_PAGE, param);
                  })
                }
                .width(CommonConstants.FULL_PERCENT)
                .padding({
                  top: CommonConstants.SPACE_L,
                  bottom: CommonConstants.SPACE_L,
                })
              }, (item: LoanRecordLite) => item.id + ('_') + item.returnedAmount)
            }
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
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
    .onShown(() => {
      this.vm.init();
    })
  }
}