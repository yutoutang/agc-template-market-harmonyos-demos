import { MappedFood, MappedFoodInfo, MappedFoodInfoItem } from '../models/MappedFoodInfo';

@ComponentV2
export struct MealDetailCard {
  @Require @Param foodInfo: MappedFoodInfo | undefined;

  build() {
    Column({ space: 12 }) {
      Column() {
        Text('团购详情').titleStyle()
        ForEach(this.foodInfo?.items, (item: MappedFoodInfoItem) => {
          Text(item.type)
            .fontSize($r('app.string.font_size_16'))
            .fontColor($r('app.color.font_color_level1'))
            .margin({ bottom: $r('app.string.margin_s') })
          ForEach(item.foods, (food: MappedFood) => {
            this.foodItemBuilder(food.name, food.description, '￥' + food.price);
          }, (item: MappedFood) => JSON.stringify(item));
        }, (item: MappedFoodInfoItem) => JSON.stringify(item));
      }
      .commonContainerStyle()

      if (this.foodInfo?.usageRule) {
        Column() {
          Text('使用须知').titleStyle()

          Text(this.foodInfo.usageRule)
            .labelStyle()
            .lineHeight(24)
            .align(Alignment.Top)
        }
        .commonContainerStyle()
      }
    }
    .backgroundColor($r('app.color.background_color_grey'))
  }

  @Builder
  foodItemBuilder(name: string, count: string, price: string) {
    Row() {
      Text() {
        Span('·').fontSize($r('app.string.font_size_20'))
        Span(' ').letterSpacing(4)
        Span(name)
      }
      .labelStyle()
      .layoutWeight(1)

      Row() {
        Text(count + '份')
          .labelStyle()
          .layoutWeight(1);
        Text(price)
          .labelStyle();
      }
      .width($r('app.string.width_percent_25'))
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .width($r('app.string.width_percent_full'))
    .margin({ bottom: $r('app.string.margin_s') })
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.SpaceBetween);
  }
}

@Extend(Text)
function labelStyle() {
  .fontSize($r('app.string.font_size_14'))
  .fontColor($r('app.color.font_color_level2'))
}

@Extend(Text)
function titleStyle() {
  .fontSize($r('app.string.font_size_14'))
  .fontColor($r('app.color.font_color_level1'))
  .fontWeight(FontWeight.Medium)
  .margin({ bottom: $r('app.string.margin_m') })
}

@Extend(Column)
function commonContainerStyle() {
  .alignItems(HorizontalAlign.Start)
  .width($r('app.string.width_percent_full'))
  .backgroundColor($r('app.color.background_color_white'))
  .borderRadius($r('app.string.border_radius_16'))
  .padding($r('app.string.padding_m'))
}