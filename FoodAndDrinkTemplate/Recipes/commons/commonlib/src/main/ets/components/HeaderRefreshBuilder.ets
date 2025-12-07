@Builder
export function HeaderRefreshBuilder() {
    Column() {
      LoadingProgress()
        .color($r('sys.color.icon_on_primary'))
        .opacity(0.6)
        .width(36)
        .height(32)
    }
    .justifyContent(FlexAlign.Center)
}