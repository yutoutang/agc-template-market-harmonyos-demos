import { promptAction } from '@kit.ArkUI'

@ComponentV2
export struct VipOpen {
  @Local isAgreed: boolean = false
  @Param isVip: boolean = false // vip
  @Event onVipOpen: () => void = () => {
  }
  // 取消vip回调
  @Event onCancelVip: () => void = () => {
  }
  @Param pageInfo: NavPathStack = new NavPathStack()

  build() {
    Column({ space: 16 }) {
      // 协议未开通显示
      Row() {
        Checkbox({ name: 'checkbox1', group: 'checkboxGroup' })
          .select(this.isAgreed)
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .onChange((value) => {
            this.isAgreed = value
          })
          .width(14)
          .height(14)
        Text() {
          Span('开通前请阅读并同意')
            .fontColor($r('sys.color.font_secondary'))
          Span('《会员服务协议》')
            .fontColor('#562E15')
            .onClick(() => {
              this.pageInfo.pushPathByName('ServiceAgreement', null)
            })
        }
        .fontWeight(FontWeight.Medium)
        .fontSize(12)
      }
      .visibility(this.isVip ? Visibility.None : Visibility.Visible) // 开通隐藏协议

      Button(this.isVip ? '取消自动续费' : '立即开通')
        .backgroundColor(this.isVip ? '#F3F3F3' : '#F1D1A5')
        .fontColor(this.isVip ? $r('sys.color.font_secondary') : $r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .width('100%')
        .onClick(() => {
          if (!this.isVip && !this.isAgreed) {
            promptAction.showToast({ message: '请阅读并勾选协议' })
            return
          }
          if (this.isVip) {
            promptAction.showToast({ message: '取消自动续费成功' })
            this.onCancelVip()
            return
          } else {
            this.onVipOpen()
          }
        })
    }
    .padding({ left: 16, right: 16 })
    .margin({ top: '30%' })
  }
}