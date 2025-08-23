@Builder
export function TitleBuilder(title: string | undefined) {
  Row() {
    Text(title)
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .layoutWeight(1)
      .fontColor($r('sys.color.font_primary'))
  }
  .height(56)
  .justifyContent(FlexAlign.SpaceBetween)
  .layoutWeight(1)
  .padding({ left: 8, right: 16 })
}