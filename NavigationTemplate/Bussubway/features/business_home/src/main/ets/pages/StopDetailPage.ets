import {
  BusSubwaySetting,
  CurrentStopDetailModel,
  LineDetailModel,
  MapStopDetailView,
  SameStopDetail,
  SameStopDetailModel,
  StationCollectionInnerModel,
  StationCollectionModel,
  StopDetailModel,
  StopDetailViewModel,
  StopLinesBundle,
  StopNavigation
} from 'module_station_line_detail';
import { SearchServiceApi, TagServiceApi } from 'lib_api';
import {
  ArrivalReminderEnum,
  CollectionLineTagModel,
  CommonConstants,
  RouterMap,
  RouterUtils,
  SameNameStopModel,
  SettingModel,
  UserInfoModel
} from 'lib_common';
import { LoginSheetUtils } from 'lib_account';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppStorageV2, PersistenceV2, PromptAction } from '@kit.ArkUI';

@Builder
export function StopDetailPageBuilder() {
  StopDetailPage()
}

@ComponentV2
struct StopDetailPage {
  // 当前站点信息
  @Local stopDetailModel?: StopDetailModel
  // 同名站台信息
  @Local sameStopDetailModel: SameStopDetailModel = new SameStopDetailModel();
  @Local sameNameLinesMap: Map<string, StopLinesBundle> = new Map<string, StopLinesBundle>()
  // 还有多少站台需要提醒
  @Local arrivalReminderStations: number = 0
  @Provider() isStopDetailPanelVisible: boolean = true
  @Provider() isFavoriteSheetVisible: boolean = false // 控制收藏弹窗显示
  settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;
  promptAction: PromptAction = this.getUIContext().getPromptAction();
  private userInfoModel: UserInfoModel =
    PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  private pathStack: NavPathStack = new NavPathStack();
  private TAG = '[StopDetailPage]';
  // 站点收藏相关
  private stationCollectionModel: StationCollectionModel =
    AppStorageV2.connect(StationCollectionModel,
      (): StationCollectionModel => new StationCollectionModel())!;
  private collectionLineTagModel: CollectionLineTagModel =
    PersistenceV2.connect(CollectionLineTagModel, () => TagServiceApi.getCollectionLineTags())!;
  private currentStopDetailModel: CurrentStopDetailModel =
    AppStorageV2.connect(CurrentStopDetailModel, () => new CurrentStopDetailModel())!;
  @Local setting: BusSubwaySetting = new BusSubwaySetting();
  private stopDetailViewModel: StopDetailViewModel =
    AppStorageV2.connect(StopDetailViewModel, () => new StopDetailViewModel())!;

  // 获取同名站点信息（只有公交站才需要同名站台功能）
  async loadSameNameStops() {
    try {
      if (this.stopDetailModel?.siteId) {
        // 只有公交站才需要同名站台功能，地铁站不需要
        if (this.stopDetailModel.stopType === 'bus_stop') {
          // 查询同名站点，重新构造同名站台模型
          const sameNameStopModel: SameNameStopModel =
            await SearchServiceApi.searchSameNameBusstop(this.stopDetailModel.siteId)
          // 模型转换，首页站点模型转换成同名站台模型
          this.sameStopDetailModel.siteId = this.stopDetailModel.siteId;
          this.sameStopDetailModel.name = this.stopDetailModel.name;
          this.sameStopDetailModel.address = this.stopDetailModel.address;
          this.sameStopDetailModel.distance = this.stopDetailModel.distance;
          this.sameStopDetailModel.longitude = this.stopDetailModel.longitude;
          this.sameStopDetailModel.latitude = this.stopDetailModel.latitude;
          // 同名站台ID后缀
          let sameStopDetailIndex: number = 0;
          sameNameStopModel.sameNameStopList.forEach(sameNameStop => {
            sameNameStop.sameNameStopLineList.forEach(sameNameStopLine => {
              const location = sameNameStop.location;
              let sameStopDetail: SameStopDetail = new SameStopDetail();
              this.sameStopDetailModel.sameStopDetails.forEach(item => {
                // 如果存在说明已经加入了同名站台
                const sameStopLocation = item.longitude + ',' + item.latitude;
                if (sameStopLocation === location) {
                  sameStopDetail = item
                  return
                }
              })
              if (!sameStopDetail.latitude || !sameStopDetail.longitude) {
                const location: string = sameNameStop.location!
                const locations = location.split(',');
                const longitude = Number(locations[0])
                const latitude = Number(locations[1])
                sameStopDetail.id = this.stopDetailModel?.siteId + '_' + sameStopDetailIndex++
                sameStopDetail.longitude = longitude
                sameStopDetail.latitude = latitude
                if (this.stopDetailModel?.longitude === longitude && this.stopDetailModel?.latitude === latitude) {
                  this.sameStopDetailModel.mainStopId = sameStopDetail.id
                }
                this.sameStopDetailModel.sameStopDetails.push(sameStopDetail)
              }
              // 插入同名站台路线
              const lineId = sameNameStopLine.id
              this.stopDetailModel?.busLines?.forEach(busLine => {
                if (busLine.id === lineId) {
                  sameStopDetail.lineDetailModels.push(busLine)
                  return
                }
              })
            })
          })
        }
      }
    } catch (error) {
      hilog.error(0x0000, this.TAG, `loadSameNameStops failed: ${JSON.stringify(error)}`);
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }){
        // 使用 MapStopDetailView，它内部包含了地图和站点详情
        MapStopDetailView({
          initialSiteId: this.stopDetailModel?.siteId,
          sameStopDetailModel: this.sameStopDetailModel,
          sameNameLinesMap: this.sameNameLinesMap,
          stopDetailModel: this.stopDetailModel,
          collectionStationTags: this.collectionLineTagModel.tagNames,
          arrivalReminderStations: this.arrivalReminderStations,
          setting: this.setting,
          collectStation: (tag: string) => {
            this.collectStation(tag)
          },
          routeLineDetailPage: (lineDetailModel: LineDetailModel) => {
            RouterUtils.pushPathByName(RouterMap.LINE_DETAIL_PAGE, lineDetailModel)
          },
          onNavigate: (stopNavigation: StopNavigation) => {
            let routerParam: Record<string, Object> = {}
            routerParam.stopNavigation = stopNavigation
            RouterUtils.pushPathByName(RouterMap.INDEX_PAGE, routerParam)
          },
          routerMap: this.pathStack,
          onFavoriteClick: () => {
            this.onFavoriteButtonClick()
          },
          onInterceptLogin: (loginInterceptCb: (isLogin: boolean) => void) => {
            if (!this.userInfoModel.isLogin) {
              // 未登录，弹出登录半模态
              LoginSheetUtils.open()
              return
            }
            // 已登录，传递登录状态
            loginInterceptCb(this.userInfoModel.isLogin)
          },
          addCollectionStopTag: (tag: string) => {
            this.collectionLineTagModel.tagNames.push(tag)
          },
        })
        Row() {
          Image($r('app.media.ic_back'))
            .width(40)
            .aspectRatio(1)
        }
        .margin({ left: 20, top: 50 })
        .align(Alignment.TopStart)
        .zIndex(1000)
        .onClick(() => {
          this.pathStack.pop(); // 返回上一页
        })
      }
      .width('100%')
      .height('100%')

    }
    .onReady(async (context) => {
      this.pathStack = context.pathStack
      this.stopDetailModel = context.pathInfo.param as StopDetailModel

      // 如果有站点详情数据，设置初始位置
      if (this.stopDetailModel && this.stopDetailModel.latitude && this.stopDetailModel.longitude) {
        // 检查并同步收藏状态
        this.syncFavoriteStatus();

        // 计算还省多少站警告
        if (this.settingInfo.warnType === ArrivalReminderEnum.TIME) {
          const warnValue = this.settingInfo.warnValue
          this.arrivalReminderStations = warnValue / (CommonConstants.HALF_TIME_BETWEEN_STOP * 2)
        } else {
          this.arrivalReminderStations = this.settingInfo.warnValue
        }
        // 获取同名站点信息
        await this.loadSameNameStops();

      }
      this.setting.isArrivalReminder = this.settingInfo.isArrivalReminder
      this.stopDetailViewModel.stopDetailModel = this.stopDetailModel
      this.stopDetailViewModel.isFavorited = this.stopDetailModel.isFavorited
    })
    .onWillShow(() => {
      this.isStopDetailPanelVisible = true
    })
    .onWillHide(() => {
      this.isStopDetailPanelVisible = false
      if (this.currentStopDetailModel.stopDetailList.length > 0) {
        this.currentStopDetailModel.stopDetailList.pop()
      }
    })
    .hideTitleBar(true)
  }

  // 收藏站点（收藏所有同名站台）
  private collectStation(tag: string) {
    if (!this.stopDetailModel) {
      return;
    }

    let stationCollectionInnerModel: StationCollectionInnerModel | undefined;

    // 查找是否已存在该标签
    this.stationCollectionModel.stationCollectionInnerModels.forEach(innerModel => {
      if (innerModel.tag === tag) {
        stationCollectionInnerModel = innerModel;
        return;
      }
    });

    if (stationCollectionInnerModel) {
      // 标签已存在，检查是否已收藏该站点（使用站点名称判断）
      stationCollectionInnerModel!.stopDetailList.push(this.stopDetailModel);
      // 更新当前站台的收藏状态
      this.stopDetailModel.isFavorited = true;
    } else {
      // 标签不存在，创建新标签并添加所有同名站台
      stationCollectionInnerModel = new StationCollectionInnerModel();
      stationCollectionInnerModel.tag = tag;
      stationCollectionInnerModel!.stopDetailList.push(this.stopDetailModel);
      this.stationCollectionModel.stationCollectionInnerModels.push(stationCollectionInnerModel);
      // 更新当前站台的收藏状态
      this.stopDetailModel.isFavorited = true;
    }
    this.stopDetailViewModel.isFavorited = this.stopDetailModel.isFavorited
    this.promptAction.showToast({ message: '收藏成功' })
  }

  // 处理收藏按钮
  private onFavoriteButtonClick() {
    // 已登录，打开收藏标签选择弹窗
    this.isFavoriteSheetVisible = true;
  }

  // 同步收藏状态（使用站点名称判断）
  private syncFavoriteStatus() {
    if (!this.stopDetailModel) {
      return;
    }

    // 检查该站点是否已被收藏（使用站点名称判断，因为同名站台共享收藏状态）
    let isFavorited = false;
    this.stationCollectionModel.stationCollectionInnerModels.forEach(innerModel => {
      const existingIndex = innerModel.stopDetailList.findIndex(
        stop => stop.name === this.stopDetailModel?.name
      );
      if (existingIndex !== -1) {
        isFavorited = true;
      }
    });

    // 更新收藏状态
    this.stopDetailModel.isFavorited = isFavorited;
  }
}