@ComponentV2
export struct CommonSymbol{
  @Param @Require
  src:Resource
  @Param
  color:ResourceColor = $r('sys.color.font_primary')

  build() {
    Row(){
      SymbolGlyph(this.src)
        .fontSize(24)
        .fontColor([this.color])
    }
    .width(40)
    .height(40)
    .borderRadius(20)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .justifyContent(FlexAlign.Center)
  }
}