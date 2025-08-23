import { BaseTextStyleModifier, CommonConstants, LocationInfo, RouterModule, WindowUtil } from 'lib_foundation';
import { CityPage } from 'module_city_manage';
import { ThemeController } from 'module_theme';
import { HomeVM } from '../viewmodels/HomeVM';

@ComponentV2
export struct TopLocation {
  vm: HomeVM = HomeVM.instance;

  build() {
    Column() {
      Column()
        .width(CommonConstants.FULL_PERCENT)
        .height(56 + WindowUtil.getAvoidArea().top)
        .backgroundColor(ThemeController.themeColor)
        .opacity(this.vm.rate)
        .position({ top: 0 })

      if (this.vm.location.name) {
        Swiper(this.vm.swiperController) {
          Row() {
            Row() {
              Image($r('app.media.location')).width(18).height(22)
              Text(this.vm.location.name)
                .attributeModifier(new BaseTextStyleModifier('font_on_primary/Body_L/Medium'))
                .margin({ left: CommonConstants.SPACE_11 })
            }
            .onClick(() => {
              RouterModule.push({
                url: CityPage.MANAGED,
                onPop: popRes => this.vm.location = popRes.result as LocationInfo,
              });
            })
          }
          .width(CommonConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.Start)

          if (this.vm.realTimeWeather) {
            Row() {
              Row() {
                Image($r('app.media.location')).width(18).height(22)
                Text(this.vm.location.name)
                  .attributeModifier(new BaseTextStyleModifier('font_on_primary/Body_L/Medium'))
                  .margin({ left: CommonConstants.SPACE_11 })
                Image($r(`app.media.${this.vm.realTimeWeather!.icon}`))
                  .width(20)
                  .height(20)
                  .margin({ left: CommonConstants.SPACE_6, right: CommonConstants.SPACE_2 })
                Text(this.vm.realTimeWeather!.temp.toFixed(0) + '°')
                  .attributeModifier(new BaseTextStyleModifier('font_on_primary/Body_L/Medium'))
              }
              .onClick(() => {
                RouterModule.push({
                  url: CityPage.MANAGED,
                  onPop: popRes => this.vm.location = popRes.result as LocationInfo,
                });
              })
            }
            .width(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.Start)
          }
        }
        .disableSwipe(true)
        .indicator(false)
        .margin({ top: WindowUtil.getAvoidArea().top })
        .layoutWeight(1)
        .padding({ left: CommonConstants.SPACE_20, right: CommonConstants.SPACE_20 })
        .vertical(true)
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(56 + WindowUtil.getAvoidArea().top)
  }
}