@Builder
export function HeaderRefreshBuilder() {
    Column() {
      LoadingProgress()
        .opacity(0.6)
        .width(36)
        .height(32)
    }
    .justifyContent(FlexAlign.Center)
}