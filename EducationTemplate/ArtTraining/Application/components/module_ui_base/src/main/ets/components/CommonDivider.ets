@ComponentV2
export struct CommonDivider {
  @Param color: ResourceColor = $r('sys.color.comp_divider');
  @Param strokeWidth: string | number = '1px';
  @Param gap: Length = $r('app.string.space_m');

  build() {
    Divider()
      .vertical(false)
      .color(this.color)
      .strokeWidth(this.strokeWidth)
      .lineCap(LineCapStyle.Butt)
      .margin({
        top: this.gap,
        bottom: this.gap,
      });
  }
}