import { BANNER_LIST } from '../constants/Constants';

@ComponentV2
export struct Banner {
  build() {
    Swiper() {
      ForEach(BANNER_LIST, (item: Resource) => {
        Image(item)
          .objectFit(ImageFit.Fill)
          .width('100%')
          .height(246)
          .borderRadius($r('app.string.border_radius_16'))
          .padding({ right: $r('app.string.padding_16'), left: $r('app.string.padding_16') })
      }, (item: Resource) => JSON.stringify(item));
    }
    .indicator(
      Indicator.dot()
        .selectedColor($r('sys.color.comp_background_emphasize'))
        .selectedItemWidth(12)
        .selectedItemHeight('6vp')
        .itemWidth('6vp')
        .itemHeight('6vp')
        .color($r('sys.color.comp_background_secondary'))
    )
    .clip(false)
    .autoPlay(true)
    .loop(true)
    .backgroundColor('#F1F3F5')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
  }
}