import { CITY_LIST_SAMPLE, CitySelect, HOT_CITY_LIST_SAMPLE, CitySelectController, City } from 'job_intention';
import { BarVM, CommonHeader } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';

@Builder
export function CitySelectPageBuilder() {
  CitySelectPage()
}


@ComponentV2
struct CitySelectPage {
  @Local currentCity: City = {
    name: '南京市',
    code: '320100',
  };
  controller: CitySelectController = new CitySelectController();

  onBackPress(): boolean | void {
    return this.controller.onBackPressed();
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.CityBuilder()
      },
    })
  }

  @Builder
  CityBuilder() {
    NavDestination() {
      Column() {
        CommonHeader({
          title: '筛选城市',
          backgroundColorParam: '#fff',
          onReturnClick: () => {
            phoneRouterControl.popPage();
          },
        }).padding({ left: 16 })
        CitySelect({
          select: ((city) => {
            // 选择城市
            this.currentCity = city
            // 返回选中的城市数据
            phoneRouterControl.popPage({
              popData: city.name
            })
          }),
          cancel: () => {
            // 取消选择
            phoneRouterControl.popPage()
          },
          handleCurrentCity: (city) => {
            if (city) {
            } else {
            }
          },
          cityList: CITY_LIST_SAMPLE,
          hotCityList: HOT_CITY_LIST_SAMPLE,
          controller: this.controller,
        })
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .padding({
        top: BarVM.instance.staBarH,
        bottom: BarVM.instance.aiBarH
      })
    }
    .height('100%')
    .width('100%')
  }
}
