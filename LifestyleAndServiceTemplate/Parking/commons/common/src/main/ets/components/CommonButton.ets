class ButtonConstant {
  // 背景颜色
  static readonly BG_COLOR: ResourceColor = '#387BF1';
  // 按钮高度
  static readonly HEIGHT: Length = 40;
}

@ComponentV2
export struct CommonButton {
  // 按钮文字
  @Param title: string = '';
  // 按钮操作
  @Event handleClick: () => void;

  build() {
    Button(this.title)
      .fontWeight(FontWeight.Medium)
      .height(ButtonConstant.HEIGHT)
      .backgroundColor(ButtonConstant.BG_COLOR)
      .fontColor($r('sys.color.font_on_primary'))
      .fontSize($r('sys.float.Body_L'))
      .width('calc(100% - 56vp)')
      .onClick(() => {
        this.handleClick();
      })
  }
}