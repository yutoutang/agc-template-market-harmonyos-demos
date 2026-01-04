@ComponentV2
export struct InfoRow {
  @Param title: string = ''
  @Param value: string = ''
  @Param isSecondary: boolean = false
  @Param heightValue: Length = 77
  @Param paddingValue: Padding | Length = 0
  @Param titleFontSize: number | string | Resource = 12
  @Param titleFontWeight: number | FontWeight | string = 400
  @Param titleFontColor: ResourceColor = $r('sys.color.font_primary')
  @Param titleLineHeight: number | string | Resource = 14
  @Param valueMarginTop: Length = 8
  @Param valueLineHeight: number | string | Resource = 19
  @Param bgColor: ResourceColor = Color.Transparent
  @Param isDraftPosition: boolean = false
  @Param valueFontSize: number | string | Resource = 16
  @Param onClickRow: () => void = () => {
  }
  @BuilderParam valueBuilder?: () => void

  build() {
    Row() {
      if (this.isDraftPosition) {
        Column() {
          Text(this.title)
            .fontSize(this.titleFontSize)
            .lineHeight(this.titleLineHeight)
            .fontWeight(this.titleFontWeight)
            .fontColor(this.titleFontColor)
            .margin({
              bottom: 8
            })
          if (this.valueBuilder) {
            this.valueBuilder()
          } else {
            Text(this.value)
              .fontSize(16)
              .lineHeight(this.valueLineHeight)
              .fontWeight(400)
              .fontColor(this.isSecondary ? $r('sys.color.font_secondary') : $r('sys.color.font_primary'))
              .margin({ right: 8 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      } else {
        Row() {
          Text(this.title)
            .fontSize(this.titleFontSize)
            .lineHeight(this.titleLineHeight)
            .fontWeight(this.titleFontWeight)
            .fontColor(this.titleFontColor)

          if (this.valueBuilder) {
            this.valueBuilder()
          } else {
            Text(this.value)
              .fontSize(this.valueFontSize)
              .lineHeight(this.valueLineHeight)
              .fontWeight(400)
              .fontColor(this.isSecondary ? 'rgba(0,0,0,0.4)' : 'rgba(0,0,0,0.9)')
              .margin({ right: 8 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .padding({
                left: 8
              })
              .layoutWeight(1)
              .textAlign(TextAlign.End)
          }
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .layoutWeight(1)
      }


      if (!this.valueBuilder) {
        SymbolGlyph($r('sys.symbol.chevron_right')).fontSize('24vp').fontColor([$r('sys.color.font_fourth')])
      }
    }
    .width('100%')
    .height(this.heightValue)
    .padding(this.paddingValue)
    .backgroundColor(this.bgColor)
    .onClick(() => {
      this.onClickRow()
    })
  }
}
