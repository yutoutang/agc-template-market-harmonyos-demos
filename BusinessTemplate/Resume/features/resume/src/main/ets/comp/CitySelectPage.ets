/**
 * 城市选择组件页面
 * 用于求职意向页面中工作城市的选择
 */

import { CommonHeader } from 'common'
import { phoneRouterControl } from 'oh_router'
import { CITY_LIST_SAMPLE, CitySelect, HOT_CITY_LIST_SAMPLE, CitySelectController, City } from 'city_select'

@Builder
export function CitySelectPageBuilder() {
  CitySelectPage()
}

@ComponentV2
export struct CitySelectPage {
  controller: CitySelectController = new CitySelectController()

  build() {
    NavDestination() {
      Column() {
        CommonHeader({
          title: '选择城市',
          onReturnClick: () => {
            phoneRouterControl.popPage()
          },
          backgroundColorParam: '#FFFFFF'
        })
        .padding({ left: 16, right: 16 })

        Column() {
          CitySelect({
            select: ((city: City) => {
              AppStorage.setOrCreate('resume_city_select_result', city.name)
              phoneRouterControl.popPage()
            }),
            cancel: () => {
              phoneRouterControl.popPage()
            },
            cityList: CITY_LIST_SAMPLE,
            hotCityList: HOT_CITY_LIST_SAMPLE,
            controller: this.controller,
          })
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.comp_background_list_card'))
    }
    .hideTitleBar(true)
  }
}
