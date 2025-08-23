import { getMedia, getString } from '@agctemplate/resources'
import { SignInClass } from '../model/SignInModel'
import { promptAction } from '@kit.ArkUI'


@ComponentV2
export struct LookAD {
  @Local list: SignInClass[] = [
    new SignInClass(100),
    new SignInClass(100),
    new SignInClass(100)]
  @Consumer('balance') balance: number = 0
  @Event addOne: () => void
  @Consumer('leftCount') claimedCount: number = 0


  build() {
    Row() {
      ForEach(this.list, (item: SignInClass, index: number) => {
        Column() {
          Stack({ alignContent: Alignment.Start }) {
            Image(getMedia(item.isClaim ? 'app.media.award_gift_d' : 'app.media.award_gift_l'))
              .width(48)
              .aspectRatio(1)
            if (!item.isClaim) {
              Image(getMedia('app.media.award_coin100'))
                .width(45)
                .height(16)
                .offset({ x: 32, y: -16 })
            }
          }
          .margin({ bottom: 12 })

          Button(item.isClaim ? getString('app.string.completed') : getString('app.string.earn_points'))
            .enabled(!item.isClaim)
            .fontWeight(FontWeight.Medium)
            .fontColor(item.isClaim ? $r('sys.color.font_tertiary') : '#EC6E45')
            .width(72)
            .height(28)
            .backgroundColor(item.isClaim ? $r('sys.color.comp_background_tertiary') : 'rgba(236,110,69,0.1)')
            .onClick(() => {
              this.handleButtonClick(item, index)
            })
        }
      }, (item: SignInClass) => item.coinNumber.toString())

    }
    .width('100%')
    .margin({ top: 17 })
    .justifyContent(FlexAlign.SpaceAround)
  }

  /**
   * 按钮点击事件
   */
  handleButtonClick(item: SignInClass, index: number) {
    if (!item.isLookAD) {
      this.toAD(item, index)
    } else {
      this.updateBalanceAndClaimStatus(item)
    }
  }

  /**
   * 去看广告
   */
  toAD(item: SignInClass, index: number) {
    promptAction.showToast({ message: `去看广告${index + 1}` })
    item.isLookAD = true
  }

  /**
   * 更新数据
   */
  updateBalanceAndClaimStatus(item: SignInClass) {
    this.balance += item.coinNumber
    item.isClaim = true
    this.claimedCount += 1
  }
}