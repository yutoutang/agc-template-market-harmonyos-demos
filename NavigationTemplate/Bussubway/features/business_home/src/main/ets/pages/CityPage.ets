import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { City, RouterUtils, StringUtils, WindowModel } from 'lib_common';
import { CitySearchController, UICitySelect } from 'module_city_select';

@Builder
export function CityPageBuilder() {
  CityPage()
}

@ComponentV2
struct CityPage {
  stack: NavPathStack = RouterUtils.getStack();
  @Local currentCity: City = PersistenceV2.connect(City, () => new City())!;
  @Local recentVisitList: string[] = ['北京', '上海', '深圳', '杭州', '成都'];
  controller: CitySearchController = new CitySearchController();
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;

  onBackPress(): boolean | void {
    return this.controller.onBackPressed();
  }

  build() {
    NavDestination() {
      Column() {
        UICitySelect({
          currentCity: this.currentCity.cityName,
          recentVisitList: this.recentVisitList,
          controller: this.controller,
          emitUpdateCityLocation: (city: string) => {
            city = StringUtils.trimLastCharacter(city, '市')
            this.currentCity.cityName = city;
          },
          emitUpdateRecentCityList: (city: string) => {
            // 更新最近访问城市列表，避免重复
            if (!this.recentVisitList.includes(city)) {
              this.recentVisitList.unshift(city);
              // 保持最近访问列表不超过5个
              if (this.recentVisitList.length > 5) {
                this.recentVisitList = this.recentVisitList.slice(0, 5);
              }
            }
          },
          goBack: (citySelected?: string) => {
            if (citySelected) {
              citySelected = StringUtils.trimLastCharacter(citySelected, '市')
              this.currentCity.cityName = citySelected;
            }
            // 返回上一页
            this.stack.pop();
          },
        })
      }
      .width('100%')
      .height('100%')
      .padding({
        top: this.windowModel.windowTopPadding,
        bottom: this.windowModel.windowBottomPadding
      })
      .backgroundColor('#ffffff')
    }
    .hideTitleBar(true)
  }
}