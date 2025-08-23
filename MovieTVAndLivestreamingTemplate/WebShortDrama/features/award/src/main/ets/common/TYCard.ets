import { getMedia, getString } from '@agctemplate/resources'

@ComponentV2
export struct TYCard {
  @Param topPadding: number = 16
  @Param bottomPadding: number = 16
  @Param leftPadding: number = 12
  @Param rightPadding: number = 12
  @Param liftTitle: ResourceStr = getString('app.string.daily_check_in_reward')
  @Param rightTitle: ResourceStr = ''
  @Param bottomMargin: number = 0
  @BuilderParam content: () => void
  @Param isLeftCounting: boolean = false
  @Consumer('leftCount') leftCount:number = 0
  @Param isRightCounting: boolean = false
  @Consumer('rightCount') rightCount:number = 1


  @Builder
  renderLeftText() {
    if (this.isLeftCounting) {
      Text() {
        Span('看广告领看点(')
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(16)
        Span(this.leftCount + '')
          .fontWeight(FontWeight.Bold)
          .fontSize(16)
          .fontColor('#EC6E45')
        Span('/3)')
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(16)
      }
    } else {
      Text(this.liftTitle)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .fontSize(16)
    }
  }

  @Builder
  renderRightText() {
    if (this.isRightCounting) {
      Text() {
        Span('已打卡')
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
        Span(this.rightCount + '')
          .fontSize(12)
          .fontColor('#EC6E45')
        Span('/7天')
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
      }
    } else {
      if (this.rightTitle !== '') {
        Text(this.rightTitle)
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
      }
    }
  }

  build() {
    Column() {
      Row() {
        this.renderLeftText()
        this.renderRightText()
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')

      if (this.content) {
        this.content()
      }

    }
    .width('100%')
    .margin({ top: 12, bottom: this.bottomMargin })
    .padding({
      top: this.topPadding,
      bottom: this.bottomPadding,
      left: this.leftPadding,
      right: this.rightPadding
    })
    .borderRadius(12)
    .backgroundImage(getMedia('app.media.award_bg_linearGradient'))
    .backgroundImageSize(ImageSize.FILL)

  }
}