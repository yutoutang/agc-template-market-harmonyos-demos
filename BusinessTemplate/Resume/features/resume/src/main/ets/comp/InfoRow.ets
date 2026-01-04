/**
 * 信息行组件
 * 用于简历各个页面的信息展示行,支持标题、值、占位符、必填标记等
 */

@ComponentV2
export struct InfoRow {
  @Param title: string = ''
  @Param value: string = ''
  @Param placeholder: string = ''
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
  @Param isRequired: boolean = false
  @Param onClickRow: () => void = () => {
  }
  @BuilderParam valueBuilder?: () => void

  build() {
    Row() {
      Column() {
        Row() {
          Text(this.title)
            .fontSize(this.titleFontSize)
            .lineHeight(this.titleLineHeight)
            .fontWeight(this.titleFontWeight)
            .fontColor(this.titleFontColor)
          if (this.isRequired) {
            Text('*')
              .padding({ top: 3, left: 3 })
              .fontSize(18)
              .fontColor('#C4272B')
          }
        }

        if (this.valueBuilder) {
          this.valueBuilder()
        } else {
          Text(this.value || this.placeholder)
            .fontSize(16)
            .lineHeight(this.valueLineHeight)
            .fontWeight(400)
            .fontColor((!this.value || this.isSecondary) ? $r('sys.color.font_secondary') :
            $r('sys.color.font_primary'))
            .margin({ top: this.valueMarginTop })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      SymbolGlyph($r('sys.symbol.chevron_right')).fontSize('24vp').fontColor([$r('sys.color.font_fourth')])
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
