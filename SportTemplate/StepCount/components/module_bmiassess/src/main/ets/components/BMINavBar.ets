/**
 * 通用页面标题栏
 */
@ComponentV2
export struct BMINavBar {
  @Param title: ResourceStr = '';
  @Param typeface: number = 0
  @Param bgColor: ResourceColor = '#00000000';
  @Param fontLineHeight: number = 0;
  @Param paddingLeft: number = -1;
  @Param paddingTop: number = -1;
  @Param paddingRight: number = -1;
  @Param fonthue: string = ''

  build() {
    Column() {
      Row() {
        if (this.title) {
          Text(this.title)
            .fontSize(this.typeface)
            .textAlign(TextAlign.Start)
            .fontColor(this.fonthue ? this.fonthue : $r('sys.color.font_primary'))
            .lineHeight(this.fontLineHeight !== 0 ? this.fontLineHeight : this.typeface)
            .fontWeight(FontWeight.Bold)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }.justifyContent(FlexAlign.Start)
    .padding({
      top: this.paddingTop !== -1 ? this.paddingTop : 0
    })
    .width('100%')
    .backgroundColor(this.bgColor)
  }
}