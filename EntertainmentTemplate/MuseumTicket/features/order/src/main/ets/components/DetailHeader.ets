@ComponentV2
export struct DetailHeader {
  @Param icon: ResourceStr = '';
  @Param label: string = '';
  @Param name: string = '';
  @Param visitTime: string = '';

  build() {
    Column({ space: 12 }) {
      Row({ space: 7.5 }) {
        Image(this.icon).width(24);
        Text(this.label)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_primary'));
      }.width('100%');

      Row() {
        Text(this.name)
          .fontColor('#000000')
          .fontSize(14)
          .fontWeight(500);
        Text(this.visitTime)
          .fontColor('#000000')
          .fontSize(14)
          .fontWeight(500);
      }
      .width('100%')
      .height(40)
      .backgroundColor('#1A0A554A')
      .padding(12)
      .justifyContent(FlexAlign.SpaceBetween)
      .borderRadius(20);
    };
  }
}