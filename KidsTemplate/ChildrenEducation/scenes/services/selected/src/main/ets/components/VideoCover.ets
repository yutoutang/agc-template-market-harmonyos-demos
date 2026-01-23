@ComponentV2
export struct VideoCover {
  @Param imageUrl: string = '';
  @Param isVip: boolean = true;
  @Param updateCount: number = 0;
  @Param totalCount: number = 0;
  @Param imageWidth: number = 96;
  @Param imageHeight: number = 54;

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image(this.imageUrl)
        .width(this.imageWidth)
        .height(this.imageHeight)
        .aspectRatio(16 / 9)
        .borderRadius(12);

      Image(this.isVip ? $r('app.media.icon_vip_top_start') : $r('app.media.icon_free_top_start'))
        .width(32)
        .height(16)
        .align(Alignment.TopStart)

      Stack({ alignContent: Alignment.Center }) {
        Text(`共${this.totalCount}节`)
          .fontColor($r('sys.color.white'))
          .fontSize(10)
          .zIndex(2);
        Button()
          .fontColor(Color.White)
          .backgroundColor($r('sys.color.black'))
          .opacity(0.4)
          .width(53)
          .height(16)
      }
      .offset({ x: this.imageWidth - 53 - 4, y: this.imageHeight - 16 - 4 })
    }
  }
}

