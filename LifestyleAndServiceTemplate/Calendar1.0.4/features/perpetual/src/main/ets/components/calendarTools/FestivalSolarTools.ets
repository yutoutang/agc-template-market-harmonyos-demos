import { CalendarVM, NavigationTitle } from 'common'
import { FestivalSolar, HolidayInfo, PublicHolidayInfo, SolarInfo } from 'festival_solar';

@Builder
export function FestivalSolarToolsBuilder() {
  FestivalSolarTools()
}

@ComponentV2
export struct FestivalSolarTools {
  @Local currentIndex: number = 0
  vm: CalendarVM = CalendarVM.instance;

  build() {
    NavDestination() {
      Column() {
        NavigationTitle({
          title: '节日节气',
        })
        FestivalSolar({
          onFestivalCardClick:(festivalInfo: HolidayInfo) => {
            console.log('onFestivalCardClick',JSON.stringify(festivalInfo))
          },
          onSolarCardClick:(solarInfo: SolarInfo) => {
            console.log('onSolarCardClick',JSON.stringify(solarInfo))
          },
          onHolidayCardClick:(festivalInfo: PublicHolidayInfo) => {
            console.log('onHolidayCardClick',JSON.stringify(festivalInfo))
          }
        })
      }
    }
    .hideTitleBar(true)
  }
}