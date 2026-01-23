import { promptAction } from '@kit.ArkUI'
import StrConstants from '../constants/StrConstants'

@ComponentV2
export struct TaskCard {
  @Param leftIcon: string = 'app.media.award_watch_shows'
  @Param title: ResourceStr = StrConstants.WATCH_REWARD
  @Param coinIcon: string = 'app.media.award_coin100'
  @Param isWatchShows: boolean = false
  @Param topMargin: number = 16
  @Param bottomMargin: number = 32
  @Param dailyPointLimit: string = '每天最多+500看点'
  @Local isClaim: boolean = false
  @Consumer('balance') balance: number = 0
  @Param button: () => void = () => {}
  @Param addAward: () => void = () => {}

  build() {
    Row() {
      Row() {
        Image($r(this.leftIcon))
          .height(40)
          .aspectRatio(1)

        Column() {
          Row() {
            Text(this.title)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))

            Image($r(this.coinIcon))
              .width(46)
              .height(16)
              .margin({ left: 4 })
          }

          Text(this.dailyPointLimit)
            .fontWeight(FontWeight.Regular)
            .fontSize(12)
            .fontColor($r('sys.color.font_tertiary'))
            .margin({ top: 2 })

        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
      }

      Button(this.isWatchShows ? $r('app.string.watch_drama') : (this.isClaim ? $r('app.string.completed') : $r('app.string.receive')))
        .fontWeight(FontWeight.Medium)
        .fontColor(this.isWatchShows ? '#EC6E45' :
          (this.isClaim ? $r('sys.color.font_tertiary') : $r('sys.color.font_on_primary')))
        .enabled(!this.isClaim)
        .width(72)
        .height(28)
        .backgroundColor(this.isWatchShows ? 'rgba(236,110,69,0.1)' :
          (this.isClaim ? $r('sys.color.comp_background_tertiary') : '#EC6E45'))
        .onClick(() => {
          this.buttonFun()
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .margin({ top: this.topMargin, bottom: this.bottomMargin })
  }


  async buttonFun() {
    let WARN_TEXT = '未识别的标题:'
    switch (this.title) {
      case StrConstants.WATCH_REWARD:
        this.getUIContext().getPromptAction().showToast({ message: StrConstants.WATCH_REWARD })
        this.button()
        break
      default:
        this.getUIContext().getPromptAction().showToast({ message: this.title })
        this.updateBalanceAndClaim()
        break
    }
  }

  updateBalanceAndClaim() {
    this.balance = 100
    this.isClaim = true
    this.button()
    this.addAward()
  }
}