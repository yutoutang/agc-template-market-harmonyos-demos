import { CommonButton, CommonBanner } from 'componentlib';

import { PromoPriceLabel } from '../components/PromoPriceLabel';
import { RouterMap, RouterModule } from 'commonlib';
import { MealDetailCard } from '../components/MealDetailCard';
import { FoodInfoPageVM } from '../viewmodels/FoodInfoPageVM';

@Builder
export function foodInfoPageBuilder() {
  FoodInfoPage();
}

@ComponentV2
struct FoodInfoPage {
  vm: FoodInfoPageVM = FoodInfoPageVM.instance;

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 12 }) {
          CommonBanner({
            covers: [this.vm.foodInfo?.coverUrl ?? ''],
          })

          this.mealHeaderBuilder();

          MealDetailCard({
            foodInfo: this.vm.foodInfo,
          });
        }
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .padding({
        left: $r('app.string.padding_l'),
        right: $r('app.string.padding_l'),
      })
      .margin({ bottom: $r('app.string.margin_l') })

      CommonButton({
        title: '立即团购',
        handleClick: () => {
          RouterModule.push({ url: RouterMap.RESTAURANT_FOOD_ORDER });
        },
      });
    }
    .backgroundColor($r('app.color.background_color_grey'))
    .title('套餐详情')
    .onReady(() => {
      this.vm.initData();
    });
  }

  @Builder
  mealHeaderBuilder() {
    Column() {
      Text(this.vm.foodInfo?.mealPackageName)
        .fontSize($r('app.string.font_size_16'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.font_color_level1'))
        .margin({ bottom: $r('app.string.margin_l') })

      Row() {
        PromoPriceLabel({
          promoPrice: this.vm.foodInfo?.promoPrice,
          originalPrice: this.vm.foodInfo?.originalPrice,
        });

        Text('月销' + (this.vm.foodInfo?.monthlySales ?? '--'))
          .fontSize($r('app.string.font_size_14'))
          .fontColor($r('app.color.font_color_level3'));
      }
      .width($r('app.string.width_percent_full'))
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Bottom);

    }
    .commonContainerStyle()
    .alignItems(HorizontalAlign.Start)
  }
}

@Styles
function commonContainerStyle() {
  .width($r('app.string.width_percent_full'))
  .backgroundColor($r('app.color.background_color_white'))
  .borderRadius($r('app.string.border_radius_16'))
  .padding($r('app.string.padding_m'))
}