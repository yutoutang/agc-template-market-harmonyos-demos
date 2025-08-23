import { MappedMealPackage, MappedRestaurant } from '../models/MappedRestaurant';
import { RestaurantListPageVM } from '../viewmodels/RestaurantListPageVM';
import { MealCard } from '../components/MealCard';
import { CommonScroll } from 'componentlib';

@Builder
export function restaurantListPageBuilder() {
  RestaurantListPage();
}

@ComponentV2
struct RestaurantListPage {
  vm: RestaurantListPageVM = RestaurantListPageVM.instance;

  build() {
    NavDestination() {
      CommonScroll() {
        Image(this.vm.topBanner)
          .aspectRatio(16 / 9)
          .width($r('app.string.width_percent_full'))
          .borderRadius($r('app.string.border_radius_16'))
        ForEach(this.vm.restaurantList, (restaurant: MappedRestaurant) => {
          this.restaurantCardBuilder(restaurant);
        }, (item: MappedRestaurant) => JSON.stringify(item));
      }
    }
    .backgroundColor($r('app.color.background_color_grey'))
    .title('餐厅列表')
    .onReady(() => {
      this.vm.initData();
    });
  }

  @Builder
  restaurantCardBuilder(restaurant: MappedRestaurant) {
    Column() {
      this.restaurantHeaderBuilder(restaurant);

      List({ space: 16 }) {
        ForEach(restaurant.mappedMealPackageList, (mealPackage: MappedMealPackage) => {
          ListItem() {
            MealCard({
              meal: mealPackage,
              handleClick: () => {
                this.vm.jumpToFoodInfoPage(mealPackage.id);
              },
            })
              .width('40%')
          };
        }, (item: MappedMealPackage) => JSON.stringify(item));
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .height('auto')
      .width($r('app.string.width_percent_full'))
      .margin({ top: $r('app.string.margin_s') });
    }
    .commonContainerStyle()
  }

  @Builder
  restaurantHeaderBuilder(restaurant: MappedRestaurant) {
    Row() {
      Image(restaurant.cover)
        .height(48)
        .aspectRatio(1)
        .borderRadius($r('app.string.border_radius_capsule'));
      Column() {
        Row() {
          Text(restaurant.name)
            .fontSize($r('app.string.font_size_16'))
            .fontColor($r('app.color.font_color_level1'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .layoutWeight(1);
          Blank();
          Text(restaurant.distanceInMeters)
            .fontSize($r('app.string.font_size_14'))
            .fontColor($r('app.color.font_color_level1'));

        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.SpaceBetween);

        Row() {
          Text(restaurant.address)
            .fontSize($r('app.string.font_size_12'))
            .fontColor($r('app.color.font_color_level2'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .layoutWeight(1);
          Text('月销' + (restaurant.monthlyTotalSales ?? '--'))
            .fontSize($r('app.string.font_size_12'))
            .fontColor($r('app.color.font_color_level2'));
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.SpaceBetween);
      }
      .layoutWeight(1)
      .height(44)
      .padding({ left: $r('app.string.padding_xs') })
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .width('100%')
    .height('auto')
    .onClick(() => {
      this.vm.jumpToRestaurantPage(restaurant.shopId);
    });
  }
}

@Styles
function commonContainerStyle() {
  .width($r('app.string.width_percent_full'))
  .backgroundColor($r('app.color.background_color_white'))
  .borderRadius($r('app.string.border_radius_16'))
  .padding($r('app.string.padding_m'))
}