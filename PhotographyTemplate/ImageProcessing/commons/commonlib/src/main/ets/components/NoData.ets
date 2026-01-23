
@ComponentV2
export struct NoData {
  @Param text: ResourceStr = '';

  build() {
    Text(this.text)
      .fontSize($r('sys.float.Body_S'))
      .fontColor($r('sys.color.icon_secondary'))
      .height('100%')
  }
}
