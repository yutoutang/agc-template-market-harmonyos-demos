@ComponentV2
export struct VipBadge {
  @Param isSquareStyle: boolean = true;
  @Param squareRadius: number = 4;
  @Param customRadius: number = 8;

  build() {
    Row() {
      Text('VIP')
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
    }
    .width(this.isSquareStyle ? 24 : 32)
    .height(16)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.membership'))
    .borderRadius(this.isSquareStyle ? this.squareRadius : {
      topRight: this.customRadius,
      bottomLeft: this.customRadius,
    })
  }
}