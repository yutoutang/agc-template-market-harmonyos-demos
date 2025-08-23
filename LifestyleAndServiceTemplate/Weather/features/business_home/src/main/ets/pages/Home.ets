import { CardAttributeUpdater, CommonConstants, RouterMap, RouterModule } from 'lib_foundation';
import { ThemeController, ThemesCard } from 'module_theme';
import { BroadCastUtil, VoiceType } from 'module_voice_broadcast';
import { UIDays, UIHours, UIIndices, UINow } from 'module_weather_core';
import { TopLocation } from '../components/TopLocation';
import { HomeVM } from '../viewmodels/HomeVM';

@ComponentV2
export struct Home {
  vm: HomeVM = HomeVM.instance;
  cardOtherModifier: CardAttributeUpdater = new CardAttributeUpdater();

  aboutToAppear(): void {
    this.vm.init();
  }

  build() {
    Column() {
      Image(ThemeController.themePic)
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
        .objectFit(ImageFit.Cover)
        .position({ top: 0 })
        .opacity(1 - this.vm.rate)

      TopLocation().position({ top: 0 }).zIndex(1)

      Scroll(this.vm.scrollerController) {
        Column() {
          if (this.vm.realTimeWeather) {
            UINow({ weather: this.vm.realTimeWeather }) {
              Row() {
                Image($r('app.media.ic_speaker')).width(19)
              }
              .width(24)
              .height(24)
              .onClick(() => {
                this.vm.speak()
              })
            }

            Blank().width(CommonConstants.FULL_PERCENT).height(10).backgroundColor($r('sys.color.background_secondary'))
          }

          if (this.vm.hourlyWeathers.length) {
            UIHours({ weathers: this.vm.hourlyWeathers, itemWidth: 48 })
            Blank().width(CommonConstants.FULL_PERCENT).height(10).backgroundColor($r('sys.color.background_secondary'))
          }

          if (this.vm.dailyWeathers.length) {
            UIDays({ weathers: this.vm.dailyWeathers, itemWidth: 56 })
            Blank().width(CommonConstants.FULL_PERCENT).height(10).backgroundColor($r('sys.color.background_secondary'))
          }

          if (this.vm.indicesWeathers.length) {
            UIIndices({
              weathers: this.vm.indicesWeathers[0],
              click: (weather) => {
                RouterModule.push({ url: RouterMap.INDICES, param: weather.type });
              },
            })
          }

          Blank().layoutWeight(1).width(CommonConstants.FULL_PERCENT)
        }
        .margin({ top: this.vm.topPadding })
        .backgroundColor($r('sys.color.background_primary'))
        .borderRadius({ topLeft: 16, topRight: 16 })
        .clip(true)
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Fade)
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .onScrollFrameBegin((offset) => {
        this.vm.scroll();
        return { offsetRemain: offset };
      })
    }
    .backgroundColor(ThemeController.themeColor)
  }
}
