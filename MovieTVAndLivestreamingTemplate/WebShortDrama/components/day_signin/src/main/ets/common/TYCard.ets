@ComponentV2
export struct TYCard {
  @Param topPadding: number = 16
  @Param bottomPadding: number = 16
  @Param leftPadding: number = 12
  @Param rightPadding: number = 12
  @Param liftTitle: ResourceStr = $r('app.string.daily_check_in_reward')
  @Param rightTitle: ResourceStr = ''
  @Param bottomMargin: number = 0
  @Param totalday: number = 7
  @BuilderParam content: () => void
  @Consumer('leftCount') leftCount: number = 0
  @Consumer('rightCount') rightCount: number = 1

  @Builder
  renderLeftText() {

    Text(this.liftTitle)
      .fontWeight(FontWeight.Bold)
      .fontColor($r('sys.color.font_primary'))
      .fontSize(16)

  }

  @Builder
  renderRightText() {
    Text() {
      Span('已打卡')
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
      Span(this.rightCount + '')
        .fontSize(12)
        .fontColor('#EC6E45')
      Span('/'+this.totalday+'天')
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
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
    .backgroundImage($r('app.media.award_bg_linearGradient'))
    .backgroundImageSize(ImageSize.FILL)

  }
}