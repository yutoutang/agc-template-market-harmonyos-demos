import { util } from '@kit.ArkTS';

@ComponentV2
export struct CommonBanner {
  @Param
  x: number = 16;
  @Param
  y: number = 9;
  @Param
  customRadius: Length = $r('app.string.border_radius_16')
  @Param
  covers: (PixelMap | ResourceStr | DrawableDescriptor)[] | null | undefined = [];
  @Param
  imageFit: ImageFit = ImageFit.Cover;
  @Param
  color: ResourceColor = $r('app.color.background_color_white');
  private readonly _ID: string = util.generateRandomUUID(false);

  build() {
    Swiper() {
      ForEach(this.covers && this.covers.length > 0 ? this.covers : [''],
        (item: ResourceStr) => {
          Image(item)
            .width('100%')
            .objectFit(this.imageFit)
            .backgroundColor(this.color)
            .aspectRatio(this.x / this.y)
        },
        (item: ResourceStr) => JSON.stringify(item));
    }
    .width('100%')
    .autoPlay(true)
    .interval(3500)
    .indicator(this.covers && this.covers.length > 1 ?
    new DotIndicator()
      .color($r('app.color.font_color_level3_invert'))
      .selectedColor($r('app.color.background_color_white'))
      .itemWidth(4)
      .itemHeight(4)
      .selectedItemWidth(12)
      .selectedItemHeight(4) :
      false,
    )
    .loop(true)
    .vertical(false)
    .disableSwipe(false)
    .alignRules({
      'bottom': { 'anchor': this._ID, 'align': VerticalAlign.Bottom },
      'left': { 'anchor': this._ID, 'align': HorizontalAlign.Start },
    })
    .borderRadius($r('app.string.border_radius_16'))
    .backgroundColor(this.color)
    .borderRadius(this.customRadius)
    .clip(true)
  }
}