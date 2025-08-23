import { CommonTagList } from 'componentlib';

@ComponentV2
export struct BanquetHotelCard {
  @Param
  title: string = '';
  @Param
  address: string = '';
  @Param
  cover: PixelMap | ResourceStr | DrawableDescriptor | undefined = undefined;
  @Param
  maxArea: string = '';
  @Param
  maxCapacity: string = '';

  build() {
    Column() {
      Image(this.cover)
        .draggable(false)
        .width('100%')
        .aspectRatio(16 / 9)
        .objectFit(ImageFit.Cover)
        .borderRadius($r('app.string.border_radius_16'));
      Row() {
        Text(this.title)
          .fontSize($r('app.string.font_size_18'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.font_color_level1'))
          .margin({ right: $r('app.string.margin_s') });
        CommonTagList({
          list: [this.maxCapacity, this.maxArea],
        })
      }
      .alignItems(VerticalAlign.Center)
      .margin({ top: $r('app.string.margin_s') });

      Row() {
        Row() {
          Image($r('app.media.icon_local'))
            .height(12)
            .fillColor($r('app.color.font_color_level2'))
            .objectFit(ImageFit.Contain)
            .draggable(false)
            .margin({ right: 4 });
          Text(this.address)
            .fontSize($r('app.string.font_size_12'))
            .fontColor($r('app.color.font_color_level2'));
        }
        .alignItems(VerticalAlign.Center);

        Button('即刻预定')
          .fontSize($r('app.string.font_size_14'))
          .backgroundColor($r('app.color.theme_color'))
          .height(32)
      }
      .margin({ top: $r('app.string.margin_xs') })
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .alignItems(HorizontalAlign.Start)
  }
}