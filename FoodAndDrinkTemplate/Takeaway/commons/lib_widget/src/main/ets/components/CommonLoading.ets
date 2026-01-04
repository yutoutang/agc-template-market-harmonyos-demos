@ComponentV2
export struct CommonLoading {
  build() {
    Row() {
      LoadingProgress()
        .size({width: 32, height: 32})
    }
    .layoutWeight(1)
    .width($r('app.string.size_percent_full'))
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }
}