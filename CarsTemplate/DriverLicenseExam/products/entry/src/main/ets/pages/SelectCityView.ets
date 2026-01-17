import { CitySearchController, UICitySelect } from 'module_city_select';
import { GuideService } from '@ohos_agcit/driver_license_exam_guide'
import { CommonModel } from '@ohos_agcit/driver_license_exam_commonlib';

@Builder
export function SelectCityViewBuilder() {
  SelectCityView();
}


@ComponentV2
struct SelectCityView {

  controller: CitySearchController = new CitySearchController();
  guideService: GuideService = GuideService.instance;
  @Local currentCity: string = this.guideService.getGuideData().city || '北京';
  vm: CommonModel = CommonModel.instance;

  @Local bottomRectHeight: number = 0;
  @Local topRectHeight: number = 0;

  aboutToAppear(): void {
    this.bottomRectHeight = AppStorage.get('bottomRectHeight') || 0;
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }

  build() {
    NavDestination() {
      Column() {
        UICitySelect({
          currentCity: this.currentCity,
          recentVisitList: ['北京', '上海', '深圳', '广西'],
          controller: this.controller,
          emitUpdateCityLocation: (city: string) => {
            this.currentCity = city;
            this.guideService.updateCity(city);
          },
          goBack: (citySelected?: string) => {
            const message = citySelected ? `选择了${citySelected}并返回` : '直接返回';
            this.getUIContext().getPromptAction().showToast({ message });
            this.vm.navStack.pop();
          },
          emitUpdateRecentCityList:(city: string) => {
            this.currentCity = city;
            this.guideService.updateCity(city);
          }
        })
      }
      .width('100%')
    }
    .height('100%')
    .width('100%')
    .title('城市选择')
    .padding({
      top:this.getUIContext().px2vp(this.topRectHeight),
      bottom: this.getUIContext().px2vp(this.bottomRectHeight)
    })
  }
}