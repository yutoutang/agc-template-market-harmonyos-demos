@ComponentV2
export struct CommonTagList {
  @Param
  list: string[] = []
  @Param
  tagColor: ResourceColor = $r('app.color.tag_color')

  build() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.list, (tag: string) => {
        Column() {
          Text(tag)
            .fontSize($r('app.string.font_size_10'))
            .fontColor(this.tagColor)
            .maxLines(1)
            .margin({
              left: 8,
              right: 8,
              top: 4,
              bottom: 4,
            });
        }
        .borderWidth(1)
        .borderColor(this.tagColor)
        .borderRadius($r('app.string.border_radius_capsule'))
        .justifyContent(FlexAlign.Center)
        .margin({
          right: $r('app.string.margin_xs'),
          bottom: $r('app.string.margin_xxs'),
          top: $r('app.string.margin_xxs'),
        });
      }, (item: string, index: number) => index + '__' + item)
    }
  }
}