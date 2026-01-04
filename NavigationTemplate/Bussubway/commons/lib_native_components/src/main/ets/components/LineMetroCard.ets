// 线路地铁卡片
@ComponentV2
export struct LineMetroCard {
  @Param title: string = ''
  @Param etaText: string = '' // 几班
  @Param stationText: string = '' // 站点
  @Param headingText: string = '' // 开往
  @Param firstTime: string = '' // 首 时间
  @Param lastTime: string = '' // 末 时间
  @Param uicolor: string = ''
  @Param @Require onCardClick?: () => void

  build() {
    Column() {
      Row() {
        Text(this.title)
          .fontSize(16)
          .fontColor(Color.Black)
          .backgroundColor(this.uicolor)
          .padding({
            left: 5,
            right: 5,
            top: 4,
            bottom: 4
          })
          .borderRadius(8)

        Row() {
          Text(this.etaText ? `${this.etaText}/班` : '')
            .fontSize(14)
            .fontColor('#777777')
        }
      }.width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text('站点').margin({ right: 8 }).fontColor('#777777').fontSize(15)
        Text(this.stationText).fontColor('#777777').fontSize(15)
      }.width('100%').margin({ top: 18, bottom: 10 })

      Row() {
        Row() {
          Text('开往').margin({ right: 8 }).fontColor('#777777').fontSize(15)
          Text(this.headingText).fontColor('#777777').fontSize(15)
        }

        Row() {
          Text(this.firstTime && this.lastTime ? `首 ${this.firstTime} ${'|'} 末 ${this.lastTime}` : '')
            .fontColor('#777777')
            .fontSize(15)
        }
      }.width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    // .height(130)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
    .margin({ bottom: 17 })
    .borderRadius(16)
    .padding({
      top: 15,
      bottom: 12,
      left: 12,
      right: 12
    })
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick()
      }
    })
  }
}