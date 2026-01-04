@ComponentV2
export struct OrderFormItem {
  @BuilderParam
  customContent: () => void = this.buildDefault
  @Param
  label: string = ''
  @Param
  labelColor: ResourceColor = $r('app.color.font_color_level2')
  @Param
  contentColor: ResourceColor = $r('app.color.font_color_level1')
  @Param
  content: string = ''
  @Param
  contentList: string[] = []
  @Param
  contentFontSize: Resource | string = $r('app.float.font_size_12')

  build() {
    Row() {
      Text(this.label)
        .fontSize(this.contentFontSize)
        .fontColor(this.labelColor)
        .constraintSize({ minWidth: 72 })
      Row() {
        this.customContent()
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.End)
    }
    .width($r('app.string.size_percent_full'))
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  buildDefault() {
    if (this.contentList.length > 0) {
      Column() {
        ForEach(this.contentList, (item: string) => {
          Text(item)
            .fontColor(this.contentColor)
            .fontSize(this.contentFontSize)
            .alignSelf(ItemAlign.End)
        }, (item: string) => item)
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.End)
    } else {
      Text(this.content)
        .fontColor(this.contentColor)
        .fontSize(this.contentFontSize)
    }

  }
}
