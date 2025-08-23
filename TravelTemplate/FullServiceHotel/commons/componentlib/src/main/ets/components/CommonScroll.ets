@ComponentV2
export struct CommonScroll {
  @BuilderParam
  contentBuilder: () => void;

  build() {
    Scroll() {
      Column({ space: 12 }) {
        this.contentBuilder()
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
    }
    .align(Alignment.Top)
    .layoutWeight(1)
    .padding({
      left: $r('app.string.padding_l'),
      right: $r('app.string.padding_l'),
      bottom:$r('app.string.padding_l')
    })
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off)
  }
}