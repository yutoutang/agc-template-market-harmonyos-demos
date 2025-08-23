import { getMedia, getString } from '@agctemplate/resources'
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
  @Local isClaim: boolean = false
  @Consumer('balance') balance: number = 0
  button: () => void = () => {
  }

  build() {
    Row() {
      Row() {
        Image(getMedia(this.leftIcon))
          .height(40)
          .aspectRatio(1)

        Column() {
          Row() {
            Text(this.title)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))

            Image(getMedia(this.coinIcon))
              .width(46)
              .height(16)
              .margin({ left: 4 })
          }

          Text(getString('app.string.daily_point_limit'))
            .fontWeight(FontWeight.Regular)
            .fontSize(12)
            .fontColor($r('sys.color.font_tertiary'))
            .margin({ top: 2 })

        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
      }

      Button(this.isWatchShows ? getString('app.string.watch_drama') : (this.isClaim ? getString('app.string.completed') : getString('app.string.receive')))
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
        promptAction.showToast({ message: StrConstants.WATCH_REWARD })
        this.button()
        break
      case StrConstants.LOTTERY_EVENT:
        promptAction.showToast({ message: StrConstants.LOTTERY_EVENT })
        this.updateBalanceAndClaim()
        break
      case StrConstants.TREASURE_BOX:
        promptAction.showToast({ message: StrConstants.TREASURE_BOX })
        this.updateBalanceAndClaim()
        break
      case StrConstants.SHARE_SHOW:
        promptAction.showToast({ message: StrConstants.SHARE_SHOW })
        this.updateBalanceAndClaim()
        break
      default:
        console.warn(WARN_TEXT, this.title)
        break
    }
  }

  updateBalanceAndClaim() {
    this.balance += 100
    this.isClaim = true
    this.button()
  }
}