import { mapCommon } from '@kit.MapKit'
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { SearchServiceApi } from 'lib_api'
import { LocationUtils, MapComponents, MapSettingModel, TransitDetailModel } from 'module_map_detail'
import { CurrentStopDetailModel, StopDetailModel } from 'module_station_line_detail'
import {
  ArrivalReminderEnum,
  City,
  CityToCitycodeMap,
  RouterMap,
  RouterUtils,
  SettingModel,
  StopLineBase,
  StopModel,
  TransportModelEnum,
  UserInfoModel
} from 'lib_common'
import { StopLineModelConvertUtil } from 'business_home'
import { SystemSceneUtils } from 'module_city_select'
import { LoginSheetUtils } from 'lib_account'


@Builder
export function HomeMapBuilder(isSave?: boolean) {
  HomeMap({ isShow: isSave })
}

@ComponentV2
export struct HomeMap {
  @Consumer() latitude: number | undefined = undefined
  @Consumer() longitude: number | undefined = undefined
  @Consumer() address?: string = '我的位置'
  @Consumer() addressAction?: string = ''
  @Consumer() selectAddress?: string = '你要去哪'
  @Consumer() selectedLatitude: number | undefined = undefined
  @Consumer() selectedLongitude: number | undefined = undefined
  @Consumer() isShowPlanning: boolean = false;
  @Consumer() selectedIndex: number = 0;
  @Provider() isShowSave: boolean = false;
  @Param isShow: boolean = false
  @Local currentCity: City = PersistenceV2.connect(City, () => new City())!;
  settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;
  @Local location: mapCommon.LatLng = { longitude: 116.397463, latitude: 39.909187 }
  private mapSettingModel: MapSettingModel = new MapSettingModel();
  private TAG = '[HomeMap]'
  private userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  private currentStopDetailModel: CurrentStopDetailModel =
    AppStorageV2.connect(CurrentStopDetailModel, () => new CurrentStopDetailModel())!;
  // 站点一半的距离 单位公里
  private readonly HALF_TIME_BETWEEN_STOP: number = 1
  @Local arrivalReminderStations: number = 0

  @Monitor('settingInfo.warnType','settingInfo.warnValue','settingInfo.speedType','settingInfo.isArrivalReminder')
  settingInfoChange() {
    this.mapSettingModel.warnType = this.settingInfo.warnType
    this.mapSettingModel.warnValue = this.settingInfo.warnValue
    this.mapSettingModel.speedType = this.settingInfo.speedType
    this.mapSettingModel.isArrivalReminder = this.settingInfo.isArrivalReminder

    // 计算还省多少站警告
    if (this.mapSettingModel.warnType === ArrivalReminderEnum.TIME) {
      const warnValue = this.mapSettingModel.warnValue
      this.arrivalReminderStations = (warnValue / this.HALF_TIME_BETWEEN_STOP * 2)
    } else {
      this.arrivalReminderStations = this.mapSettingModel.warnValue
    }
  }

  aboutToAppear(): void {
    SystemSceneUtils.checkPermissionGrant('ohos.permission.LOCATION').then((granted: boolean) => {
      this.settingInfo.locationHasPermission = granted
      this.settingInfo.locationShowPrompt = !granted
      if (granted) {
        LocationUtils.getGCJ02CurrentLocation().then((location: mapCommon.LatLng) => {
          this.location = location
        })
      }
    })

    this.mapSettingModel.warnType = this.settingInfo.warnType
    this.mapSettingModel.warnValue = this.settingInfo.warnValue
    this.mapSettingModel.speedType = this.settingInfo.speedType
    this.mapSettingModel.isArrivalReminder = this.settingInfo.isArrivalReminder

    // 计算还省多少站警告
    if (this.mapSettingModel.warnType === ArrivalReminderEnum.TIME) {
      const warnValue = this.mapSettingModel.warnValue
      this.arrivalReminderStations = (warnValue / this.HALF_TIME_BETWEEN_STOP * 2)
    } else {
      this.arrivalReminderStations = this.mapSettingModel.warnValue
    }

  }

  @Builder
  LocationPermissionPrompt() {
    Column() {
      Image($r('app.media.location_not'))
        .width(120)
        .aspectRatio(1)
      Text('无法获取当前位置')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 16 })

      Text('请开启精确定位权限，以获取附近站点与路线信息')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 8 })

      Text('开启定位')
        .width(120)
        .height(40)
        .backgroundColor('#e5e7e9')
        .fontColor('#0A59F7')
        .margin({ top: 24 })
        .textAlign(TextAlign.Center)
        .borderRadius(30)
        .onClick(() => {
          this.requestLocationPermissionAgain()
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    NavDestination() {
      if (this.settingInfo.locationShowPrompt) {
        this.LocationPermissionPrompt()
      } else {
        MapComponents({
          currentLocation: this.location,
          isVip: this.userInfoModel.isVip,
          isOpenOnePlanning: this.isShow,
          mapSettingModel: this.mapSettingModel,
          arrivalReminderStations: this.arrivalReminderStations,
          // 绑定数据回调
          onNearbyStopsRequested: async (location: string) => {
            return await this.handleNearbyStopsRequested(location)
          },
          routeStopDetailPage: (stopId: string) => {
            this.routeStopDetailPage(stopId)
          },
          onFavoriteClick: () => {
            this.clickFavorite()
          },
          onSettingClick: () => {
            RouterUtils.pushPathByName(RouterMap.SETTING_PAGE)
          },
          onSearchStop: async (keyWord: string) => {
            let result: StopModel[] = await SearchServiceApi.searchBusstop(keyWord, 10)
            if (!result) {
              return []
            }
            let stopList: StopDetailModel[] = []
            for (let stop of result) {
              let stopDetailModel = new StopDetailModel()
              stopDetailModel.name = stop.name
              stopDetailModel.address = stop.name
              let location = stop.location?.split(',').map(Number);
              stopDetailModel.longitude = location ? location[0] : undefined
              stopDetailModel.latitude = location ? location[1] : undefined
              stopDetailModel.stopType = stop.busSubwayType
              stopList.push(stopDetailModel)
            }
            return stopList
          },
          // 绑定页面跳转回调
          onNavigateToStopDetail: (stopDetailModel: StopDetailModel) => {
            this.handleNavigateToStopDetail(stopDetailModel)
          },
          getTransitRoutes: async (origin: string, destination: string, currentIndex: number) => {
            let strategy: number = 0
            if (currentIndex === 0) {
              // 获取导航设置
              if (this.settingInfo.accessType === TransportModelEnum.BUS) {
                // 不乘地铁模式
                strategy = 5
              } else {
                // 乘地铁模式
                strategy = 7
              }
            } else if (currentIndex === 1) {
              // 时间短模式
              strategy = 8
            } else if (currentIndex === 2) {
              // 少换乘模式
              strategy = 2
            }
            const transitModel = await SearchServiceApi.transitSearch(origin, destination,
              CityToCitycodeMap.CITYNAME_ADCODE_RECORD[this.currentCity.cityName!],
              CityToCitycodeMap.CITYNAME_ADCODE_RECORD[this.currentCity.cityName!],
              strategy)
            const transitModelJson = JSON.stringify(transitModel)
            const transitDetailModel: TransitDetailModel = JSON.parse(transitModelJson)
            return transitDetailModel
          },
          onInterceptLogin: (loginInterceptCb: (isLogin: boolean) => void) => {
            if (!this.userInfoModel.isLogin) {
              LoginSheetUtils.open()
              return
            }
            loginInterceptCb(this.userInfoModel.isLogin)
          },
        })
      }
    }
  }

  clickFavorite() {
    // 检查登录状态
    if (!this.userInfoModel.isLogin) {
      // 未登录，弹出登录半模态
      this.isShowSave = false
      LoginSheetUtils.open();
      return;
    } else {
      this.isShowSave = true
    }

  }

  private async requestLocationPermissionAgain(): Promise<void> {
    const granted: boolean = await SystemSceneUtils.applyLocationPermission()
    this.settingInfo.locationHasPermission = granted
    this.settingInfo.locationShowPrompt = !granted
    if (granted) {
      LocationUtils.getGCJ02CurrentLocation().then((location: mapCommon.LatLng) => {
        this.location = location
      })
    }
  }

  // 实现附近站点搜索回调（调用高德API）
  private async handleNearbyStopsRequested(location: string): Promise<StopDetailModel[]> {
    try {

      // 调用高德API获取附近站点
      const aroundStops: StopLineBase[] = await SearchServiceApi.aroundSearch(location)

      // 转换为StopDetailModel格式
      const stopDetailModels: StopDetailModel[] = aroundStops.map((stop: StopLineBase) => {
        const stopDetailModel = new StopDetailModel()
        stopDetailModel.siteId = stop.id
        stopDetailModel.name = stop.name

        // 解析位置信息 - 需要将StopLineBase转换为StopModel
        if (stop instanceof StopModel && stop.location) {
          const locationParts: string[] = stop.location.split(',')
          if (locationParts.length >= 2) {
            stopDetailModel.longitude = Number(locationParts[0])
            stopDetailModel.latitude = Number(locationParts[1])
          }
        }

        // 设置站点类型
        stopDetailModel.stopType = stop.busSubwayType === '1' ? 'subway_station' : 'bus_stop'
        stopDetailModel.isFavorited = false

        return stopDetailModel
      })

      hilog.info(0x0000, this.TAG, `获取到 ${stopDetailModels.length} 个附近站点`)
      return stopDetailModels
    } catch (error) {
      hilog.error(0x0000, this.TAG, `获取附近站点失败: ${JSON.stringify(error)}`)
      return []
    }
  }

  // 实现站点详情搜索回调（调用高德API）
  private async routeStopDetailPage(stopId: string) {
    try {
      hilog.info(0x0000, this.TAG, `获取站点详情: ${stopId}`)
      // 使用searchSameNameBusstop获取站点详情
      const stopModel: StopModel = await SearchServiceApi.searchBusstopById(stopId);
      // 模型转换
      const stopDetailModel: StopDetailModel = await StopLineModelConvertUtil.genStopDetailModel(stopModel)
      this.currentStopDetailModel.stopDetailList.push(stopDetailModel)
      RouterUtils.pushPathByName(RouterMap.STOPDETAIL_PAGE, stopDetailModel);
      hilog.info(0x0000, this.TAG, `站点详情获取成功: ${stopDetailModel.name}`)
    } catch (error) {
      hilog.error(0x0000, this.TAG, `获取站点详情失败: ${JSON.stringify(error)}`)
    }
  }

  // 实现站点详情页面跳转回调
  private handleNavigateToStopDetail(stopDetailModel: StopDetailModel) {
    try {
      hilog.info(0x0000, this.TAG, `跳转到站点详情页面: ${stopDetailModel.name}`)
      RouterUtils.pushPathByName(RouterMap.STOPDETAIL_PAGE, stopDetailModel)
    } catch (error) {
      hilog.error(0x0000, this.TAG, `跳转站点详情页面失败: ${JSON.stringify(error)}`)
    }
  }
}
