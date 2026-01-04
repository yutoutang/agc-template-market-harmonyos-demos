import { BreakpointNameEnum, CommonConstants } from 'lib_common'
import { VerifyVM } from '../../viewmodels/VerifyVM'

@ComponentV2
export struct HomeIntroduceCard {
  @Param moneyEDu: number = 0
  @Param loanRate: number = -1
  @Param loanPerDay: number = -1
  @Local verifyVM: VerifyVM = new VerifyVM();

  @Event ClickFunc: () => void = () => {
  }

  build() {
    Column({ space: CommonConstants.SPACE_XXL }) {
      Column({ space: CommonConstants.SPACE_S }) {
        Text('最多可借（元）')
          .fontSize(14)
          .lineHeight(16)
          .fontColor('rgba(0, 0, 0, 0.90)')
        Text(this.moneyEDu.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }))
          .fontWeight(600)
          .fontSize(40)
          .lineHeight(47)
          .fontColor('rgba(0, 0, 0, 0.90)')
        Text(`年利率${(this.verifyVM.fixedAnnualRate * 100).toFixed(2)}%，1,000用1天只需${this.loanPerDay}`)
          .fontSize(14)
          .lineHeight(16)
          .fontColor('rgba(0, 0, 0, 0.60)')
      }

      Text('去借钱')
        .backgroundColor($r('app.color.app_theme'))
        .fontColor(Color.White)
        .fontSize(16)
        .lineHeight(19)
        .width('100%')
        .height(40)
        .padding({ top: 10, bottom: 10 })
        .textAlign(TextAlign.Center)
        .borderRadius(20)
        .onClick(() => this.ClickFunc())
    }
    .width('100%')
    .padding({
      left: this.verifyVM.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ?
      CommonConstants.PADDING_XXL : CommonConstants.PADDING_LG,
      right: this.verifyVM.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ?
      CommonConstants.PADDING_XXL : CommonConstants.PADDING_LG,
      top: CommonConstants.PADDING_XXL,
      bottom: CommonConstants.PADDING_L
    })
    .backgroundColor('#FFFFFF')
    .borderRadius(CommonConstants.PADDING_L)
  }
}