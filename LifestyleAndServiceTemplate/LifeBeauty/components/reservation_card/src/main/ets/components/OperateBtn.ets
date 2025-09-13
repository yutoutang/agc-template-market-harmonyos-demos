@ComponentV2
export struct OperateBtn {
  @Param imgSrc: ResourceStr = '';
  @Param btnText: ResourceStr = '';
  @Param fgColor: ResourceColor = '';
  @Event onClickEvent: () => void = () => {
  };

  build() {
    Row({ space: 5 }) {
      Image(this.imgSrc)
        .width(14)
        .height(14)
      Text(this.btnText)
        .fontSize(12)
        .fontColor(this.fgColor)
    }
    .onClick(() => {
      this.onClickEvent();
    })
  }
}