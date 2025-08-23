import { promptAction } from '@kit.ArkUI'

@ComponentV2
export struct VipOpen {
  @Local isAgreed: boolean = false
  @Local showMemberServiceAgreementSheet: boolean = false
  @Event onVipOpen: () => void = () => {
  }
  @Event onMemberServiceAgreementSheetOpen: () => void = () => {
  }
  @Event onAutomaticRenewalAgreementDialogOpen: () => void = () => {
  }
  @Param pageInfo: NavPathStack = new NavPathStack()
  @Param isVip: boolean = false

  build() {
    Column({ space: 16 }) {
      Row() {
        Checkbox({ name: 'checkbox1', group: 'checkboxGroup' })
          .select(this.isAgreed)
          .selectedColor('#EC6E45')
          .onChange((value) => {
            this.isAgreed = value
          })
          .width(20)
          .aspectRatio(1)
        Text() {
          Span('同意')
            .fontColor($r('sys.color.font_secondary'))
          Span('《会员服务协议》')
            .fontColor('#BD9164')
            .onClick(() => {
              this.onMemberServiceAgreementSheetOpen()
            })
          Span('和')
            .fontColor($r('sys.color.font_secondary'))
          Span('《自动续费协议》')
            .fontColor('#BD9164')
            .onClick(() => {
              this.onAutomaticRenewalAgreementDialogOpen()
            })
        }
        .fontWeight(FontWeight.Medium)
        .fontSize(12)
      }

      Button(this.isVip ? '立即升级' : '立即开通')
        .backgroundColor('#BD9164')
        .fontColor($r('sys.color.font_on_primary'))
        .fontWeight(FontWeight.Medium)
        .fontSize(16)
        .width('100%')
        .enabled(this.isAgreed)
        .onClick(() => {
          this.onVipOpen()
        })
    }
  }
}