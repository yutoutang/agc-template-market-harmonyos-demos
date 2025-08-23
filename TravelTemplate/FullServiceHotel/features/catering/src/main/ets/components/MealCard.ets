import { MappedMealPackage } from '../models/MappedRestaurant';
import { PromoPriceLabel } from './PromoPriceLabel';

@ComponentV2
export struct MealCard {
  @Param
  meal: MappedMealPackage | undefined = undefined
  @Event
  handleClick: () => void = () => {
  }

  build() {
    Column() {
      if (this.meal) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(this.meal.coverUrl)
            .width('100%')
            .aspectRatio(4 / 3)
            .borderRadius($r('app.string.border_radius_16'));
          Text('月销' + (this.meal.monthlySales ? this.meal.monthlySales : '--'))
            .fontSize($r('app.string.font_size_10'))
            .borderRadius($r('app.string.border_radius_capsule'))
            .fontColor($r('app.color.font_color_level1_invert'))
            .backgroundColor($r('app.color.font_color_level3'))
            .padding($r('app.string.padding_xs'))
            .margin({ left: $r('app.string.margin_xs'), bottom: $r('app.string.margin_xs') });
        };

        Text(this.meal.name)
          .fontSize($r('app.string.font_size_16'))
          .margin({
            top: $r('app.string.margin_s'),
            bottom: $r('app.string.margin_xs'),
          })
          .fontColor($r('app.color.font_color_level1'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        PromoPriceLabel({
          promoPrice: this.meal.promoPrice,
          promoFontSize: $r('app.string.font_size_16'),
          originalPrice: this.meal.originalPrice,
          originalFontSize: $r('app.string.font_size_12'),
        });
      }
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .onClick(() => {
      this.handleClick?.()
    });
  }
}