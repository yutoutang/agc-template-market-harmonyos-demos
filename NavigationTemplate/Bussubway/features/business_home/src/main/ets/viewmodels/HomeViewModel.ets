import { AppStorageV2, PersistenceV2, promptAction } from '@kit.ArkUI';
import { notificationManager } from '@kit.NotificationKit';
import { common } from '@kit.AbilityKit';
import { geoLocationManager } from '@kit.LocationKit';
import {
  BaseViewModel,
  City,
  CommonConstants,
  Logger,
  NewsEnum,
  newsInformation,
  PushActionParams,
  PushUtils,
  RandomUtils,
  RouterToNews,
  SearchHistory,
  SettingModel,
  StopLineBase,
  StopModel,
  StringUtils
} from 'lib_common';
import { SystemSceneUtils } from 'module_city_select';
import { BusSubwayMap, SearchServiceApi } from 'lib_api';
import { StopLineModelConvertUtil } from '../utils/StopLineModelConvertUtil';
import {
  CollectionServiceApi,
  ComingBus,
  CurrentLineDetailModel,
  CurrentStopDetailModel,
  LineCollectionInnerModel,
  LineCollectionModel,
  LineDetailModel,
  StationCollectionInnerModel,
  StationCollectionModel,
  StopDetailModel
} from 'module_station_line_detail';

// 定义位置信息接口
interface LocationInfo {
  latitude: number;
  longitude: number;
}

@ObservedV2
export class HomeViewModel extends BaseViewModel {
  @Trace currentCity: City = PersistenceV2.connect(City, () => new City())!;
  searchHistory: SearchHistory = PersistenceV2.connect(SearchHistory, () => new SearchHistory())!;
  @Trace settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;
  // 附近站点相关属性
  @Trace nearbyStops: StopDetailModel[] = [];
  @Trace isLoadingNearby: boolean = false
  @Trace currentLocation?: LocationInfo
  private lineCollectionModel: LineCollectionModel =
    AppStorageV2.connect(LineCollectionModel, () => CollectionServiceApi.getLineCollectionList())!;
  private stationCollectionModel: StationCollectionModel =
    AppStorageV2.connect(StationCollectionModel, (): StationCollectionModel => new StationCollectionModel())!;
  private currentLineDetailModel: CurrentLineDetailModel =
    AppStorageV2.connect(CurrentLineDetailModel, () => new CurrentLineDetailModel())!;
  private currentStopDetailModel: CurrentStopDetailModel =
    AppStorageV2.connect(CurrentStopDetailModel, () => new CurrentStopDetailModel())!;
  // 定时器ID
  private timerID: number = 0

  getSearchResultList(searchValue: string) {
  }

  searchChange(searchValue: string) {
    this.getSearchResultList(searchValue)
    if (this.searchHistory.historyList.includes(searchValue) || searchValue.trim() === '') {
      return
    }
    this.searchHistory.historyList.push(searchValue)
  }

  clearHistory() {
    this.searchHistory.historyList = []
  }

  // mock 开启随机推送
  sendPushMessage() {
    const announcementList = newsInformation;
    // 随机选择一条公告
    const randomIndex = Math.floor(RandomUtils.getRandomIndex(announcementList.length));
    const pushActionParams: PushActionParams = {
      articleId: randomIndex.toString(),
      authorId: 'system',
      type: NewsEnum.Article
    };
    PushUtils.randomPushMessage(pushActionParams)
  }

  sendPushNotice(context: common.UIAbilityContext) {
    if (!this.settingInfo.pushSwitch) {
      notificationManager.requestEnableNotification(context).then((err) => {
        this.settingInfo.pushSwitch = true;
        this.sendPushMessage();
      }).catch(() => {
        this.settingInfo.pushSwitch = false;
      });
    } else {
      this.sendPushMessage();
    }
    /*
     * 判断是否是从push 卡片进入
     * */
    if (AppStorage.get('pushCardEntry')) {
      let newsData = AppStorage.get('pushCardEntry') as PushActionParams
      let routerParams: Record<string, string | NewsEnum> = {
        'type': newsData.type,
        'newsId': newsData.articleId,
        'authorId': newsData.authorId,
      }
      RouterToNews.pushToNewsDetails(routerParams)
      AppStorage.setOrCreate('isPushCardEntry', '')
    }
  }

  /**
   * 获取当前城市
   */
  getCurrentCity(uiContext: UIContext) {
    SystemSceneUtils.getCurrentCityInfo().then((city: string) => {
      if (city) {
        city = StringUtils.trimLastCharacter(city, '市')
        this.currentCity.cityName = city
      } else {
        uiContext.getPromptAction().showToast({ message: '定位失败，请重试!' });
      }
    })
  }

  /**
   * 获取附近站点
   */
  async loadNearbyStops(context: Context) {
    try {
      this.isLoadingNearby = true;

      // 获取当前位置
      const location = await geoLocationManager.getCurrentLocation();
      this.currentLocation = {
        latitude: location.latitude,
        longitude: location.longitude
      } as LocationInfo;

      // 调用附近站点API
      const locationStr = `${location.longitude},${location.latitude}`;
      const aroundStops = await SearchServiceApi.aroundSearchByPage(locationStr, 1);

      // 为每个附近站点获取详细信息
      let detailedStops = await this.loadStopDetails(aroundStops);

      // 2. 按距离从近到远排序
      detailedStops.sort((a, b) => {
        const distanceA = parseFloat(String(a.distance || '0'));
        const distanceB = parseFloat(String(b.distance || '0'));
        return distanceA - distanceB;
      });

      this.nearbyStops = detailedStops;
      Logger.info('HomeViewModel', `筛选排序后站点数量: ${this.nearbyStops.length}`)
    } catch (error) {
      promptAction.showToast({ message: '获取附近站点失败，请重试!' });
    } finally {
      this.isLoadingNearby = false;
    }
  }

  loadStopLineData() {
    this.initLineDetailList();
    this.startTimer();
  }

  private initLineDetailList(): void {
    this.lineCollectionModel.lineCollectionInnerModels.forEach((lineCollectionInnerModel: LineCollectionInnerModel) => {
      lineCollectionInnerModel.lineDetailList.forEach((lineDetailModel: LineDetailModel) => {
        // 切换路线
        lineDetailModel.switchDirec = async () => {
          if (lineDetailModel.direc) {
            const lineModel = await SearchServiceApi.searchBuslineById(lineDetailModel.direc)
            if (lineModel) {
              StopLineModelConvertUtil.convertToLineDetailModel(lineDetailModel, lineModel);
              await StopLineModelConvertUtil.calRecentStop(lineDetailModel)
            }
          }
        };
        StopLineModelConvertUtil.calRecentStop(lineDetailModel)
      })
    })
  }

  private startTimer(): void {
    this.timerID = setInterval(() => {
      const alreadyExecutedLineDetailModels: LineDetailModel[] = [];

      // 处理lineCollectionModel
      this.processLineCollectionModel(alreadyExecutedLineDetailModels);

      // 处理currentLineDetailModel
      this.processCurrentLineDetailModel();

      // 处理nearbyStops
      this.processNearbyStops(alreadyExecutedLineDetailModels);

      // 处理currentStopDetailModel
      this.processCurrentStopDetailModel();

      // 处理stationCollectionModel
      this.processStationCollectionModel();
    }, CommonConstants.SETTING_SPEED[this.settingInfo.speedType] * 1000)
  }

  private processLineCollectionModel(alreadyExecutedLineDetailModels: LineDetailModel[]): void {
    this.lineCollectionModel.lineCollectionInnerModels.forEach(
      (lineCollectionInnerModel: LineCollectionInnerModel) => {
        lineCollectionInnerModel.lineDetailList.forEach((lineDetailModel: LineDetailModel) => {
          if (lineDetailModel.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_BUS) {
            alreadyExecutedLineDetailModels.push(lineDetailModel);
            this.updateComingBuses(lineDetailModel);
          }
        });
      });
  }

  private processCurrentLineDetailModel(): void {
    this.currentLineDetailModel.lineDetailList.forEach((lineDetailModel: LineDetailModel) => {
      if (lineDetailModel.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_BUS) {
        this.updateComingBuses(lineDetailModel);
      }
    });
  }

  private processNearbyStops(alreadyExecutedLineDetailModels: LineDetailModel[]): void {
    this.nearbyStops.forEach((stopDetailModel: StopDetailModel) => {
      stopDetailModel.busLines!.forEach((lineDetailModel: LineDetailModel) => {
        if (alreadyExecutedLineDetailModels.indexOf(lineDetailModel) >= 0) {
          return;
        }
        if (this.shouldUpdateComingBuses(lineDetailModel)) {
          if (lineDetailModel.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_BUS) {
            this.updateComingBuses(lineDetailModel);
          }
        }
      });
    });
  }

  private processCurrentStopDetailModel(): void {
    this.currentStopDetailModel.stopDetailList.forEach((stopDetailModel: StopDetailModel) => {
      stopDetailModel.busLines!.forEach((lineDetailModel: LineDetailModel) => {
        if (this.shouldUpdateComingBuses(lineDetailModel)) {
          if (lineDetailModel.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_BUS) {
            this.updateComingBuses(lineDetailModel);
          }
        }
      });
    });
  }

  private processStationCollectionModel(): void {
    this.stationCollectionModel.stationCollectionInnerModels.forEach(
      (stationCollectionInnerModel: StationCollectionInnerModel) => {
        stationCollectionInnerModel.stopDetailList.forEach((stopDetailModel: StopDetailModel) => {
          stopDetailModel.busLines!.forEach((lineDetailModel: LineDetailModel) => {
            if (this.shouldUpdateComingBuses(lineDetailModel)) {
              if (lineDetailModel.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_BUS) {
                this.updateComingBuses(lineDetailModel);
              }
            }
          });
        });
      });
  }

  private shouldUpdateComingBuses(lineDetailModel: LineDetailModel): boolean {
    return lineDetailModel.currentStop !== undefined &&
    lineDetailModel.currentStop.comingBusList &&
      lineDetailModel.currentStop.comingBusList.length > 0;
  }

  private updateComingBuses(lineDetailModel: LineDetailModel): void {
    if (!lineDetailModel.currentStop) {
      return;
    }

    // 判断有没有点到站
    for (let i = 0; i < lineDetailModel.currentStop.comingBusList.length; i++) {
      const comingBus: ComingBus = lineDetailModel.currentStop.comingBusList[0];
      if (comingBus.stations! === 0) {
        comingBus.stations = lineDetailModel.currentStop.stopOffsetIndex! + 1;
        const first = lineDetailModel.currentStop.comingBusList.shift()!;
        lineDetailModel.currentStop.comingBusList.push(first);
      }
    }

    lineDetailModel.currentStop.comingBusList.forEach((comingBus: ComingBus) => {
      if (comingBus.stations! > 0) {
        comingBus.stations!--;
      }
      // 计算时间
      comingBus.time = comingBus.stations! * CommonConstants.HALF_TIME_BETWEEN_STOP * 2;
    });
  }

  clearInterval() {
    clearInterval(this.timerID)
  }

  /**
   * 为附近站点加载详细线路信息
   */
  private async loadStopDetails(aroundStops: StopLineBase[]): Promise<StopDetailModel[]> {
    try {
      const detailedStops: StopDetailModel[] = [];
      // 为所有站点获取详细线路信息
      const promises = aroundStops.map(async (stop: StopLineBase) => {
        if (stop instanceof StopModel && stop.id) {
          try {
            // 使用searchSameNameBusstop获取站点详情
            const stopModel: StopModel = await SearchServiceApi.searchBusstopById(stop.id);
            // 模型转换
            const stopDetailModel: StopDetailModel = await StopLineModelConvertUtil.genStopDetailModel(stopModel)
            detailedStops.push(stopDetailModel);
          } catch (error) {
            Logger.error(`获取站点 ${stop.name} 详情失败:`, error);
          }
        }
      });

      await Promise.all(promises);
      return detailedStops;
    } catch (error) {
      return aroundStops; // 返回原始数据
    }
  }
}