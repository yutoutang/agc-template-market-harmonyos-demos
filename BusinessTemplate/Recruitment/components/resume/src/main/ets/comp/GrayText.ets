/**
 * 灰色文本组件
 * 用于简历页面中的次要信息展示
 * 默认样式：字号12pt，行高14pt，颜色#60000000
 */
@ComponentV2
export struct GrayText {
  /** 文本内容 */
  @Param text: string = ''
  /** 字号，默认12 */
  @Param fontSize: number = 12
  /** 行高，默认14 */
  @Param lineHeight: number = 14
  /** 字重，默认400 */
  @Param fontWeight: FontWeight = 400
  /** 字体颜色，默认#60000000（灰色，透明度60%） */
  @Param fontColor: ResourceColor = '#60000000'
  /** 文本对齐方式，默认左对齐 */
  @Param textAlign: TextAlign = TextAlign.Start
  /** 最大行数，默认不限制 */
  @Param maxLines?: number = undefined
  /** 文本溢出处理，默认Clip */
  @Param textOverflow?: TextOverflow = undefined

  build() {
    Text(this.text)
      .fontSize(this.fontSize)
      .lineHeight(this.lineHeight)
      .fontWeight(this.fontWeight)
      .fontColor(this.fontColor)
      .textAlign(this.textAlign)
      .maxLines(this.maxLines)
      .textOverflow(this.textOverflow ? { overflow: this.textOverflow } : undefined)
  }
}
