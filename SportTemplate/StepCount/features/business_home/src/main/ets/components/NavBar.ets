/**
 * 通用页面标题栏
 */
@ComponentV2
export struct NavBar {
  @Param title: ResourceStr = '';
  @Param bgColor: ResourceColor = '#00000000';
  @Param typeface: number = 0
  @Param fontLineHeight: number = 0;
  @Param paddingLeft: number = -1;
  @Param paddingRight: number = -1;
  @Param paddingTop: number = -1;
  @Param fonthue: string = ''

  build() {
    Column() {
      Row() {
        if (this.title) {
          Text(this.title)
            .textAlign(TextAlign.Start)
            .fontSize(this.typeface)
            .fontColor(this.fonthue ? this.fonthue : $r('sys.color.font_primary'))
            .fontWeight(FontWeight.Bold)
            .lineHeight(this.fontLineHeight !== 0 ? this.fontLineHeight : this.typeface)
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