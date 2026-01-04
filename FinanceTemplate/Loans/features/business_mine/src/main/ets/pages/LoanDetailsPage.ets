import { CommonConstants, RouterMap, RouterUtils, WindowModel } from 'lib_common';
import { LoanProduct, LoanStatusEnum } from 'lib_loan_api';
import { AppStorageV2 } from '@kit.ArkUI';
import { LoanViewModel } from '../viewmodels/LoanRecordVm';
import { NavHeaderBar } from 'lib_widget';

@Builder
export function LoanDetailsPageBuilder() {
  LoanDetailsPage()
}

@ComponentV2
struct LoanDetailsPage {
  @Local vm: LoanViewModel = new LoanViewModel();
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Param backImg: ResourceStr = $r('app.media.ic_back');
  @Param bgColor: ResourceColor = '#00000000';
  @Consumer() isCommentInModalDialog: boolean = false
  @BuilderParam rightPartBuilder: () => void;
  @Local paidTerms: number = 0; //已还期数
  @Local repaidAmount: number = 0; //已还本金
  @Local paidInterestAmount: number = 0; //已还
  @Local remainAmount: number = 0; //剩余待还
  @Event onBack: () => void = () => {
    RouterUtils.pop()
  };

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '贷款详情',
          showBackBtn: true,
          onBack: () => {
            this.onBack();
          }
        })

        Scroll() {
          Column({ space: CommonConstants.SPACE_M }) {

            // 贷款金额部分
            Column({ space: CommonConstants.SPACE_M }) {
              Text('贷款金额')
                .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
                .lineHeight(14 * this.vm.settingInfo.fontSizeRatio)
                .fontColor('#E6000000')
              if (this.vm.loanDetailsList) {
                Text(`￥${this.vm.loanDetailsList.loanAmount.toLocaleString('en-US',
                  { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`)
                  .fontSize(28 * this.vm.settingInfo.fontSizeRatio)
                  .fontWeight(FontWeight.Bold)
                  .lineHeight(33 * this.vm.settingInfo.fontSizeRatio)
              }

            }
            .width(CommonConstants.FULL_PERCENT)
            .alignItems(HorizontalAlign.Center)
            .padding({
              left: CommonConstants.PADDING_M,
              right: CommonConstants.PADDING_M,
              top: CommonConstants.PADDING_M,
              bottom: CommonConstants.PADDING_M
            })

            if (this.vm.loanDetailsList) {
              Column({ space: CommonConstants.SPACE_L }) {
                //贷款明细
                Column() {
                  this.TitleBuilder('贷款明细')
                  Column() {
                    // 贷款明细项，每行一个 Row 显示标签和值
                    this.ContentBuilder('贷款金额', `￥${this.vm.loanDetailsList.loanAmount.toLocaleString('en-US',
                      { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`)
                    this.ContentBuilder('贷款年利率',
                      `${(this.vm.loanDetailsList.annualInterestRate * 100).toFixed(2)}%`)
                    this.ContentBuilder('贷款期数', `${this.vm.loanDetailsList.loanTerms}`)
                    this.ContentBuilder('还款方式', this.vm.loanDetailsList.repaymentMethod)
                    this.ContentBuilder('收款账户', this.vm.loanDetailsList.paymentAccount.slice(0, 4) +
                      `(${this.vm.loanDetailsList.paymentAccount.slice(-4)})`)
                  }
                }
                .width(CommonConstants.FULL_PERCENT)
                .padding({
                  left: CommonConstants.PADDING_M,
                  right: CommonConstants.PADDING_M
                })
                .borderRadius(CommonConstants.SPACE_L)
                .backgroundColor(Color.White)

                // 还款明细部分
                Column() {
                  this.TitleBuilder('还款明细')
                  Column() {
                    ContentBuilderCom({
                      title: '已还期数',
                      text: `${this.paidTerms || 0}/${this.vm.loanDetailsList?.loanTerms}期`
                    })

                    ContentBuilderCom({
                      title: '已还本金',
                      text: `￥${(this.repaidAmount || 0).toLocaleString('en-US',
                        { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
                    })
                    // 待还信息
                    if (this.vm.loanDetailsList) {
                      ContentBuilderCom({
                        title: '待还本金',
                        text: `￥${(this.remainAmount < 0 ? 0 : this.remainAmount).toLocaleString('en-US',
                          { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
                      })
                    }
                    ContentBuilderCom({
                      title: '已还息费',
                      text: `￥${(this.paidInterestAmount || 0).toLocaleString('en-US',
                        { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
                    })
                  }
                }
                .visibility((this.vm.loanDetailsList?.loanStatus === 3 || this.vm.loanDetailsList?.loanStatus === 4) ?
                Visibility.Visible : Visibility.None)
                .width(CommonConstants.FULL_PERCENT)
                .padding({
                  left: CommonConstants.PADDING_M,
                  right: CommonConstants.PADDING_M
                })
                .borderRadius(CommonConstants.SPACE_L)
                .backgroundColor(Color.White)

                // 审批信息部分（带边框）
                Column() {
                  this.TitleBuilder('审批信息')
                  Column() { // 审批信息项
                    ContentBuilderCom({
                      title: '审批状态',
                      text: this.vm.loanDetailsList ? this.vm.getStatusName(this.vm.loanDetailsList.loanStatus) : ''
                    })
                    if (this.vm.loanDetailsList && this.vm.loanDetailsList.rejectReason) {
                      this.ContentBuilder('未通过原因', this.vm.loanDetailsList.rejectReason)
                    }
                    this.ContentBuilder('提交时间', `${this.vm.loanDetailsList.createTime}`)
                    // 审核完成时间
                    this.ContentBuilder('审核完成',
                      this.vm.loanDetailsList.reviewCompletedTime &&
                        this.vm.loanDetailsList.loanStatus !== LoanStatusEnum.Auditing ?
                      this.vm.loanDetailsList.reviewCompletedTime :
                        '--')
                    // 放款时间
                    this.ContentBuilder('放款时间',
                      this.vm.loanDetailsList.loanTime &&
                        (this.vm.loanDetailsList.loanStatus === LoanStatusEnum.Repaying ||
                          this.vm.loanDetailsList.loanStatus === LoanStatusEnum.Settled) ?
                      this.vm.loanDetailsList.loanTime :
                        '--')
                  }
                }
                .width(CommonConstants.FULL_PERCENT)
                .padding({
                  left: CommonConstants.PADDING_M,
                  right: CommonConstants.PADDING_M
                })
                .backgroundColor(Color.White)
                .borderRadius(CommonConstants.SPACE_L)

              }
              .width(CommonConstants.FULL_PERCENT)
              .padding({
                left: CommonConstants.PADDING_L,
                right: CommonConstants.PADDING_L,
                top: CommonConstants.PADDING_M,
                bottom: CommonConstants.PADDING_M
              })
            }
          }
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })

        Column() {
          Button(this.vm.loanDetailsList ?
            (this.vm.loanDetailsList.loanStatus === 0 ? '查看审核进度' :
              this.vm.loanDetailsList.loanStatus === 1 ? '' :
                this.vm.loanDetailsList.loanStatus === 2 ? '重新提交审核' :
                  this.vm.loanDetailsList.loanStatus === 3 ? '我要还款' : '已结清') :
            '')
            .backgroundColor('#FF317AF7')
            .width(CommonConstants.FULL_PERCENT)
            .height(44)
            .fontColor($r('sys.color.font_on_primary'))
            .margin({ top: CommonConstants.SPACE_L, bottom: CommonConstants.SPACE_L })
            .visibility(this.vm.loanDetailsList && this.vm.loanDetailsList.loanStatus === 1 ||
              this.vm.loanDetailsList && this.vm.loanDetailsList.loanStatus === 4 ? Visibility.None :
            Visibility.Visible)
            .onClick(() => {
              if (this.vm.loanDetailsList) {
                // 审核中和审核未通过跳转到额度申请页面
                if (this.vm.loanDetailsList.loanStatus === 0 || this.vm.loanDetailsList.loanStatus === 2) {
                  const param: Record<string, Object> = {
                    'repayment': this.vm.loanDetailsList
                  }
                  RouterUtils.pushPathByName(RouterMap.VERIFY_PAGE, param)
                } else if (this.vm.loanDetailsList.loanStatus === 3) {
                  // 到待还款账单页
                  const param: Record<string, Object> = {
                    'repayment': this.vm.loanDetailsList!.repaymentSchedule!.filter(schedule => !schedule!.isPaid)
                  }
                  RouterUtils.pushPathByName(RouterMap.PENDING_REPAYMENT, param)
                }
              }
            })
        }
        .width(CommonConstants.FULL_PERCENT)
        .padding({
          left: CommonConstants.PADDING_L,
          right: CommonConstants.PADDING_L,
        })

      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundImage(this.vm.getBackImg(this.vm.loanDetailsList))
      .backgroundImageSize(ImageSize.Contain) // 背景图片适配模式
    }
    .onReady(async (context: NavDestinationContext) => {
      if (context.pathInfo.param) {
        const params = context.pathInfo.param as Record<string, Object>;
        let currentLoanDetail = params.question as LoanProduct;
        this.vm.getLoanDetailByLoanId(currentLoanDetail.id, (loanDetail) => {
          this.vm.loanDetailsList = loanDetail;
          this.paidTerms = loanDetail.paidTerms as number;
          this.repaidAmount = loanDetail.repaidAmount as number;
          this.paidInterestAmount = loanDetail.interestAmount as number;
          this.remainAmount = loanDetail.loanAmount - ((loanDetail.repaidAmount as number) ||
            0 + (loanDetail.interestAmount as number) || 0)
        })
      }
    })
    .onShown(() => {
      if (this.vm.loanDetailsList?.id) {
        this.vm.getLoanDetailByLoanId(this.vm.loanDetailsList.id, (loanDetail) => {
          this.vm.loanDetailsList = null
          this.vm.loanDetailsList = loanDetail;
          this.paidTerms = this.vm.loanDetailsList.paidTerms as number;
          this.repaidAmount = this.vm.loanDetailsList.repaidAmount as number;
          this.paidInterestAmount = this.vm.loanDetailsList.interestAmount as number;
          this.remainAmount = this.vm.loanDetailsList.loanAmount -
            ((this.vm.loanDetailsList.repaidAmount as number) ||
              0 + (this.vm.loanDetailsList.interestAmount as number) || 0)
        })
      }
    })
    .padding({ bottom: this.windowModel.windowBottomPadding })
    // 设置背景图片资源
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  TitleBuilder(text: string) {
    Column() {
      Text(text)
        .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
        .lineHeight(20 * this.vm.settingInfo.fontSizeRatio)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)
    }
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: CommonConstants.PADDING_L,
      bottom: CommonConstants.PADDING_L,
    })
  }

  @Builder
  ContentBuilder(title: string, text: string) {
    Row() {
      Text(title)
        .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
        .fontColor('#99000000')
        .lineHeight(16 * this.vm.settingInfo.fontSizeRatio)
      Text(text)
        .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
        .fontColor('#99000000')
        .lineHeight(16 * this.vm.settingInfo.fontSizeRatio)
        .layoutWeight(1)
        .textAlign(TextAlign.End)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      top: CommonConstants.PADDING_SL,
      bottom: CommonConstants.PADDING_SL,
    })
  }
}

@ComponentV2
struct ContentBuilderCom {
  @Param title: string = ''
  @Param text: string = ''
  @Param vm: LoanViewModel = new LoanViewModel()

  build() {
    Row() {
      Text(this.title)
        .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
        .fontColor('#99000000')
        .lineHeight(16 * this.vm.settingInfo.fontSizeRatio)
      Text(this.text)
        .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
        .fontColor('#99000000')
        .lineHeight(16 * this.vm.settingInfo.fontSizeRatio)
        .layoutWeight(1)
        .textAlign(TextAlign.End)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      top: CommonConstants.PADDING_SL,
      bottom: CommonConstants.PADDING_SL,
    })
  }
}

