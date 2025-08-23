@ComponentV2
export struct CardContainer {
  @Param title: string = '';
  @BuilderParam content: () => void;

  build() {
    Column() {
      Text(this.title)
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Bold)
        .height(56)
        .margin({ left: 16 })
      if (this.content) {
        this.content()
      }
    }
    .width('100%')
    .backgroundColor($r('sys.color.comp_background_primary'))
    .alignItems(HorizontalAlign.Start)
  }
}