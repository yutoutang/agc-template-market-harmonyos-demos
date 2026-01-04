/**
 * 城市选择组件页面
 * 用于求职意向页面中工作城市的选择
 */


import { CITY_LIST_SAMPLE, CitySelect, HOT_CITY_LIST_SAMPLE, CitySelectController, City } from 'city_select'
import { TitleBar } from '../components/TitleBar'

export interface CitySelectParams {
  selected: string
  onConfirm: (values: string) => void
  source?: string // 标识来源页面:'work' 或 'career'
}

@Builder
export function CitySelectPageBuilder() {
  CitySelectPage()
}

@ComponentV2
export struct CitySelectPage {
  controller: CitySelectController = new CitySelectController()
  @Local navPathStack: NavPathStack = new NavPathStack();
  private params: CitySelectParams = {
    selected: '', onConfirm: () => {
    }
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          title: '选择城市',
          onBack: () => this.navPathStack.pop()
        })
          .padding({ left: 16, right: 16 })

        Column() {
          CitySelect({
            select: ((city: City) => {
              AppStorage.setOrCreate('resume_city_select_result', city.name)
              this.navPathStack.pop()
              this.params.onConfirm(city.name)
            }),
            cancel: () => {
              this.navPathStack.pop()
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
      .padding({
        top: 32,
        bottom: 32
      })
      .backgroundColor($r('sys.color.comp_background_list_card'))
    }
    .onReady((context: NavDestinationContext) => {
      this.navPathStack = context.pathStack
      if (context.pathInfo.param) {
        this.params = context.pathInfo.param as CitySelectParams

      }
    })
    .hideTitleBar(true)
  }
}
