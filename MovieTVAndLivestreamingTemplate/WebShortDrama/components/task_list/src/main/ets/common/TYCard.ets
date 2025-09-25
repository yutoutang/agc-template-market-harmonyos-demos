@ComponentV2
export struct TYCard {
  @Param topPadding: number = 16
  @Param bottomPadding: number = 16
  @Param leftPadding: number = 12
  @Param rightPadding: number = 12
  @Param liftTitle: ResourceStr = $r('app.string.daily_tasks')
  @Param rightTitle: ResourceStr = ''
  @Param bottomMargin: number = 0
  @BuilderParam content: () => void

  @Builder
  renderLeftText() {
    Text(this.liftTitle)
      .fontWeight(FontWeight.Bold)
      .fontColor($r('sys.color.font_primary'))
      .fontSize(16)
  }

  @Builder
  renderRightText() {
    if (this.rightTitle !== '') {
      Text(this.rightTitle)
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