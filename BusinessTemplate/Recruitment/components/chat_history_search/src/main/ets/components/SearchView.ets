@ComponentV2
export struct SearchView {
  @Param @Require onSubmitSearch: (searchText: string) => void = (searchText: string) => {
  };
  @Local searchText: string = '';

  build() {
    Row() {
      Image($r('app.media.ic_search'))
        .opacity(0.6)
        .width($r('app.float.vp_16'))
        .objectFit(ImageFit.Contain)
      TextInput({ text: $$this.searchText, placeholder: $r('app.string.search') })
        .fontSize($r('sys.float.Body_L'))
        .width('66%')
        .backgroundColor(Color.Transparent)
        .placeholderColor($r('sys.color.font_secondary'))
        .margin({ right: $r('app.float.vp_8') })
        .padding({ left: $r('app.float.vp_8') })
        .enterKeyType(EnterKeyType.Search)
        .onSubmit(() => {
          this.onSubmitSearch(this.searchText)
        })
      Blank().layoutWeight(1)
      Row() {
        Image($r('app.media.clear'))
          .width($r('app.float.vp_40'))
          .objectFit(ImageFit.Contain)
          .padding($r('app.float.vp_12'))
      }
      .backgroundColor(Color.Transparent)
      .margin({ right: $r('app.float.vp_4') })
      .onClick(() => {
        this.searchText = '';
      })
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height($r('app.float.vp_40'))
    .backgroundColor($r('sys.color.gray_01'))
    .borderRadius($r('app.float.vp_20'))
    .margin({
      bottom: $r('app.float.vp_8'),
      top: $r('app.float.vp_8'),
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16'),
    })
    .padding({
      left: $r('app.float.vp_12'),
    })
  }
}