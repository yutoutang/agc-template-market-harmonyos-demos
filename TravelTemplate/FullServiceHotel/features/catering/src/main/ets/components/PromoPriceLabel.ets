@ComponentV2
export struct PromoPriceLabel {
  @Param
  promoPrice: string | number = 0;
  @Param
  originalPrice: string | number = 0;
  @Param
  promoFontSize: number | string | Resource = $r('app.string.font_size_16');
  @Param
  originalFontSize: number | string | Resource = $r('app.string.font_size_12');

  build() {
    Row() {
      Text() {
        Span('￥')
          .fontSize(this.originalFontSize)
          .fontColor($r('app.color.highlight_color'))
        Span(this.promoPrice ? this.promoPrice.toString() : '')
          .fontSize(this.promoFontSize)
          .fontColor($r('app.color.highlight_color'))
        Span(' ')
        Span('￥' + (this.originalPrice ? this.originalPrice : ''))
          .fontSize(this.originalFontSize)
          .fontColor($r('app.color.font_color_level2'))
          .decoration({ type: TextDecorationType.LineThrough, color: $r('app.color.font_color_level2') })
      }
    }
    .alignItems(VerticalAlign.Bottom)
    .justifyContent(FlexAlign.Start)
  }
}