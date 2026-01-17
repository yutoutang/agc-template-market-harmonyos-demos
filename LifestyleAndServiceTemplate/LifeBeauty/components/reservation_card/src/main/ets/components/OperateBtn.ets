@ComponentV2
export struct OperateBtn {
  @Param imgSrc: Resource | undefined = undefined;
  @Param btnText: ResourceStr = '';
  @Param fgColor: ResourceColor = '';
  @Param isDisabled: boolean = false;
  @Event onClickEvent: () => void = () => {
  };

  build() {
    Row({ space: 4 }) {
      SymbolGlyph(this.imgSrc)
        .fontSize(16)
        .fontColor([this.fgColor])
      Text(this.btnText)
        .fontSize(12)
        .fontColor(this.fgColor)
    }
    .opacity(this.isDisabled ? 0.4 : 1)
    .onClick(() => {
      this.onClickEvent();
    })
  }
}