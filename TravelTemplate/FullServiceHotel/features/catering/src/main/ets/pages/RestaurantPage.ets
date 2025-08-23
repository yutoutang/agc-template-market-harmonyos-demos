import { CommonBanner, CommonScroll } from 'componentlib';
import { MappedMealPackage } from '../models/MappedRestaurant';
import { RestaurantPageVM } from '../viewmodels/RestaurantPageVM';
import { MealCard } from '../components/MealCard';
import { CallDialog } from 'module_call_dialog';

@Builder
export function restaurantPageBuilder() {
  RestaurantPage();
}

@ComponentV2
struct RestaurantPage {
  vm: RestaurantPageVM = RestaurantPageVM.instance;

  build() {
    NavDestination() {
      CommonScroll() {
        CommonBanner({
          covers: this.vm.restaurant?.banners ?? [''],
        })
        this.restaurantCardBuilder();
        this.mealPackageListBuilder();
      }
    }
    .backgroundColor($r('app.color.background_color_grey'))
    .title(this.vm.restaurant?.name ?? '')
    .onReady(() => {
      this.vm.initData();
    });
  }

  @Builder
  restaurantCardBuilder() {
    Row() {
      Image(this.vm.restaurant?.cover)
        .width(48)
        .height(48)
        .margin({ right: $r('app.string.margin_s') })
        .borderRadius($r('app.string.border_radius_capsule'))
      Column() {
        Row() {
          Text(this.vm.restaurant?.name)
            .fontSize($r('app.string.font_size_16'))
            .fontColor($r('app.color.font_color_level1'))
            .layoutWeight(1);
          Text(this.vm.restaurant?.distanceInMeters)
            .greyTextStyle();
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .layoutWeight(1);

        Row() {
          Text(this.vm.restaurant?.address).greyTextStyle().layoutWeight(1);
          Text('月销' + (this.vm.restaurant?.monthlyTotalSales ?? '--')).greyTextStyle();
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .layoutWeight(1);

        Row() {
          Text(this.vm.restaurant?.notice)
            .greyTextStyle()
            .fontSize($r('app.string.font_size_10'))

          CallDialog({
            phoneNumber: this.vm.restaurant?.phoneNumber ?? '',
          }) {
            Row() {
              Image($r('app.media.ic_tel'))
                .height($r('app.integer.icon_size_12'))
                .fillColor($r('app.color.theme_color'));
              Text('联系商家')
                .fontSize($r('app.string.font_size_10'))
                .fontColor($r('app.color.theme_color'));
            }
          }
        }
        .width($r('app.string.width_percent_full'))
        .justifyContent(FlexAlign.SpaceBetween)
        .layoutWeight(1);
      }
      .layoutWeight(1)
      .height($r('app.string.height_percent_full'))
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .height(90)
    .width($r('app.string.width_percent_full'))
    .backgroundColor($r('app.color.background_color_white'))
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .padding($r('app.string.padding_m'))
    .borderRadius($r('app.string.border_radius_16'))
  }

  @Builder
  mealPackageListBuilder() {
    Grid() {
      ForEach(this.vm.restaurant?.mappedMealPackageList, (mealPackage: MappedMealPackage) => {
        GridItem() {
          MealCard({
            meal: mealPackage,
            handleClick: () => {
              this.vm.jumpToFoodInfoPage(mealPackage.id);
            },
          })
        };
      }, (item: MappedMealPackage) => JSON.stringify(item));
    }
    .columnsTemplate('1fr 1fr')
    .columnsGap($r('app.string.margin_m'))
    .rowsGap($r('app.string.margin_m'));
  }
}


@Extend(Text)
function greyTextStyle() {
  .fontSize($r('app.string.font_size_12'))
  .fontColor($r('app.color.font_color_level2'));
}

@Styles
function commonContainerStyle() {
  .width($r('app.string.width_percent_full'))
  .backgroundColor($r('app.color.background_color_white'))
  .borderRadius($r('app.string.border_radius_16'))
  .padding($r('app.string.padding_m'))
}