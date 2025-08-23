import { CommonButton, CommonDivider, CommonHeader } from 'componentlib';
import { MealOrderVM } from '../viewmodels/MealOrderVM';
import { PromoPriceLabel } from '../components/PromoPriceLabel';
import { MealDetailCard } from '../components/MealDetailCard';

@ComponentV2
export default struct FoodOrderSubmitPage {
  mealOrderVm: MealOrderVM = MealOrderVM.instance;

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 12 }) {
          this.packageInfoBuilder();

          MealDetailCard({
            foodInfo: this.mealOrderVm.foodInfo,
          });
        }
        .margin({ bottom: $r('app.string.margin_l') })
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .padding({
        left: $r('app.string.padding_l'),
        right: $r('app.string.padding_l'),
      })


      this.bottomButtonBuilder();
    }
    .backgroundColor($r('app.color.background_color_grey'))
    .title(this.mealOrderVm.mealRequest?.shopName ?? '')
    .onReady(() => {
      this.mealOrderVm.resetFoodCount();
    });

  }

  @Builder
  packageInfoBuilder() {
    Row() {
      Image(this.mealOrderVm.foodInfo?.coverUrl)
        .height($r('app.string.height_percent_full'))
        .aspectRatio(4 / 3)
        .objectFit(ImageFit.Cover)
        .borderRadius($r('app.string.border_radius_16'))
        .margin({ right: $r('app.string.margin_s') });

      Column() {
        Text(this.mealOrderVm.foodInfo?.mealPackageName)
          .fontSize($r('app.string.font_size_16'))
          .fontWeight(500)
          .fontColor($r('app.color.font_color_level1'));
        Row() {
          PromoPriceLabel({
            promoPrice: this.mealOrderVm.foodInfo?.promoPrice,
            originalPrice: this.mealOrderVm.foodInfo?.originalPrice,
          });

          Row() {
            Row() {
              Image($r('app.media.ic_subtract')).width(16)
            }
            .countButtonStyle(this.mealOrderVm.foodCount > 1)
            .margin({ right: $r('app.string.margin_l') })
            .onClick(() => {
              this.mealOrderVm.handleFoodCount(false);
            });

            Text(this.mealOrderVm.foodCount.toString())
              .fontSize($r('app.string.font_size_18'))
              .lineHeight(24)
              .fontColor($r('app.color.font_color_level1'))
              .fontWeight(FontWeight.Medium);

            Row() {
              Image($r('app.media.ic_add')).width(16)
            }
            .countButtonStyle(this.mealOrderVm.foodCount < this.mealOrderVm.MAX_FOOD_COUNT)
            .margin({ left: $r('app.string.margin_l') })
            .onClick(() => {
              this.mealOrderVm.handleFoodCount();
            });
          }
        }
        .height($r('app.string.height_percent_full'))
        .width($r('app.string.width_percent_full'))
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1);

    }
    .height(96)
    .commonContainerStyle()
  }

  @Builder
  bottomButtonBuilder() {
    Row() {
      Text('总额')
        .fontSize($r('app.string.font_size_14'))
        .fontColor($r('app.color.font_color_level2'))
        .margin({ right: $r('app.string.margin_s') });

      PromoPriceLabel({
        promoPrice: Number(this.mealOrderVm.foodInfo?.promoPrice ?? 0) * this.mealOrderVm.foodCount,
        originalPrice: Number(this.mealOrderVm.foodInfo?.originalPrice ?? 0) * this.mealOrderVm.foodCount,
        promoFontSize: $r('app.string.font_size_20'),
        originalFontSize: $r('app.string.font_size_14'),
      })
        .layoutWeight(1)

      CommonButton({
        title: '提交订单',
        fullWidth: false,
        handleClick: () => {
          this.mealOrderVm.prepayMeal();
        },
      });
    }
    .width($r('app.string.width_percent_full'))
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('app.color.background_color_white'))
    .padding({
      left:$r('app.string.padding_l'),
      top:$r('app.string.padding_l')
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}

@Extend(Row)
function countButtonStyle(enable: boolean = true) {
  .height(32)
  .width(32)
  .borderRadius($r('app.string.border_radius_capsule'))
  .backgroundColor($r('app.color.background_color_grey_light'))
  .justifyContent(FlexAlign.Center)
  .alignItems(VerticalAlign.Center)
  .opacity(enable ? 1 : 0.4)
}

@Styles
function commonContainerStyle() {
  .width($r('app.string.width_percent_full'))
  .backgroundColor($r('app.color.background_color_white'))
  .borderRadius($r('app.string.border_radius_16'))
  .padding($r('app.string.padding_m'))
}

@Builder
export function foodOrderSubmitPageBuilder() {
  FoodOrderSubmitPage();
}