import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { geoLocationManager } from '@kit.LocationKit';
import { searchData, SearchPresetParam } from '../constants/SearchMockData';
import { City, CommonConstants,
  LocationUtils,
  MapCommonConstants, NewsModel, RouterMap, RouterUtils, WindowModel } from 'lib_common';

/**
 * 首页头部Bar
 */
@ComponentV2
export struct HomeHeaderBar {
  @Local currentCity: City = PersistenceV2.connect(City, () => new City())!;
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local newsModel: NewsModel = AppStorageV2.connect(NewsModel, () => new NewsModel())!;
  @Local suggestionIndex: number = 0
  private suggestionTimer: number = 0

  aboutToAppear(): void {
    if (this.suggestionTimer) {
      clearInterval(this.suggestionTimer)
    }
    if (searchData.length > 0) {
      this.suggestionTimer = setInterval(() => {
        this.suggestionIndex = (this.suggestionIndex + 1) % Math.min(10, searchData.length)
      }, 2000)
    }
  }

  aboutToDisappear(): void {
    if (this.suggestionTimer) {
      clearInterval(this.suggestionTimer)
      this.suggestionTimer = 0
    }
  }

  build() {

    Column() {
      Row() {
        Row() {
          Text(this.currentCity.cityName || $r('app.string.default_city'))
            .width(40)
            .height(24)
            .fontSize(16)
          Image($r('app.media.city_down'))
            .width(12)
            .height(24)
        }
        .height(40)
        .onClick(() => {
          RouterUtils.pushPathByName(RouterMap.CITY_PAGE)
        })

        Row() {
          Image($r('app.media.search'))
            .width(15)
            .height(15)
            .margin({ left: 16, right: 12 })

          Text(searchData.length > 0 ? searchData[this.suggestionIndex] :
          $r('app.string.home_search_placeholder'))
            .fontSize(14)
            .layoutWeight(1)
            .textAlign(TextAlign.Start)
            .fontColor('#666666')
        }
        // .width(200)
        .height(40)
        .borderRadius(24)
        .margin({ left: 8, right: 8 })
        .backgroundColor('#e5e7e9')
        .layoutWeight(1)
        .onClick(() => {
          const preset = searchData.length > 0 ? searchData[this.suggestionIndex] : ''
          const param: SearchPresetParam = { presetKeyword: preset }
          RouterUtils.pushPathByName(RouterMap.SEARCH_PAGE, param)
        })

        Image($r('app.media.ditietu')).width(40).height(40).margin({ right: 8 })
          .onClick(async () => {
            let request: geoLocationManager.SingleLocationRequest = {
              locatingPriority: MapCommonConstants.PRIORITY_LOCATING_SPEED,
              locatingTimeoutMs: MapCommonConstants.LOCATING_TIMEOUT_MS
            };
            const location = await LocationUtils.getGCJ02CurrentLocation()
            RouterUtils.pushPathByName(RouterMap.SUBWAY_PAGE, location.longitude + ',' + location.latitude)
          })
        // 更新红点变化 未读已读
        Image(this.newsModel.unReadNewsIds.length === 0 ? $r('app.media.notice_not') : $r('app.media.notice_have'))
          .width(40)
          .height(40)
          .onClick(() => {
            RouterUtils.pushPathByName(RouterMap.MORENEWS_PAGE)
          })
      }
      .height($r('app.float.nav_header_height'))
      .width(CommonConstants.FULL_PERCENT)

    }
    .padding({
      top: this.windowModel.windowTopPadding,
    })
    .width(CommonConstants.FULL_PERCENT)
  }
}