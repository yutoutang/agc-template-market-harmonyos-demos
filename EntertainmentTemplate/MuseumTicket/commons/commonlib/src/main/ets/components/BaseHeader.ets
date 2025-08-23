@Builder
export function BaseHeader(title: string) {
  Row() {
    Text(title).width('100%').fontSize($r('sys.float.Title_M')).fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Medium);
  }
  .width('100%')
  .height(56)
  .padding({
    left: 24,
    right: 24,
    top: 12,
    bottom: 12,
  })
}