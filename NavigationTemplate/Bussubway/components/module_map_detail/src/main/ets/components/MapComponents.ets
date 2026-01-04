import { abilityAccessCtrl, common, wantAgent } from '@kit.AbilityKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppStorageV2, LengthMetrics, PersistenceV2, PromptAction, promptAction, window } from '@kit.ArkUI';
import { geoLocationManager } from '@kit.LocationKit';
import { connection } from '@kit.NetworkKit';
import { map, mapCommon, MapComponent, site } from '@kit.MapKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { MapDetailCommonConstants } from './MapDetailCommonConstants';
import { StopDetailModel } from 'module_station_line_detail';
import { SaveAllClass } from '../models/SaveAllClass';
import { SaveOneClass } from '../models/SaveOneClass';
import { SaveClass } from '../models/SaveClass';
import { CollectionSaveTagModel } from '../models/CollectionSaveTagModel';
import { TagServiceApi } from '../sercice/TagService';
import {
  ComingBus,
  TransitDetailModel,
  TransitRouteTransit,
  TransitRouteTransitSegment,
  TransitRouteTransitSegmentBusBuslineViaStop,
  TransitRouteTransitSegmentWorkStep
} from '../models/TransitDetailModel';
import { DrawRouteModel } from '../models/DrawRouteModel';
import { LocationUtils } from '../utils/LocationUtils';
import { MapChooseType } from '../constants/Enums';
import { RealTimeLatLng } from '../models/RealTimeLatLng';
import { MapSettingModel } from '../models/MapSettingModel';
import { SearchMapBuilder } from './SearchMapComponents';
import { CommentEventDispatcher } from '../utils/EventDispatcher';
import { ClickUtil } from '../utils/ClickUtil';

interface LocationInter {
  latitude: number,
  longitude: number
}

const TAG = '[Map]';


@ComponentV2
export struct MapComponents {
  // 导航搜索类型
  @Local searchType: string = ''
  @Param currentLocation: mapCommon.LatLng = { longitude: 116.397463, latitude: 39.909187 }
  @Local hasPremission: boolean = false
  // 目前自己的位置信息
  @Consumer() latitude: number | undefined = undefined
  @Consumer() longitude: number | undefined = undefined
  @Consumer() address?: string = '我的位置'
  @Consumer() addressAction?: string = ''
  @Consumer() selectAddress?: string = '你要去哪'
  @Local isOnLocationChange: boolean = false;
  @Consumer() isShowPlanning: boolean = false;
  @Consumer() isShowSave: boolean = false;
  @Local nearly?: site.Site[];
  @Local nearlyOne?: site.Site;
  @Local tabCome?: boolean = false;
  @Param istabCome?: boolean = false;
  @Consumer() selectedLatitude: number | undefined = undefined
  @Consumer() selectedLongitude: number | undefined = undefined
  @Local fontColor: string = '#182431'
  @Local fontColor2: string = '#ff111313'
  @Local selectedFontColor: string = '#0A59F7'
  @Local currentIndex: number = 0
  @Local myText: string = ''
  @Local isSave: boolean = false
  @Local nestedArray: string[][] = [];
  @Local selectOne: number[][] = [];
  @Local isAllWalKDistance: number[] = []
  @Local sum: number = 0
  // 步行公里
  @Local isDistance: number = 0
  @Local onClickOnePlanning: boolean = false
  @Local showHeight: number = -1
  @Local showTheClose: boolean = true
  @Local openPlanning: boolean = false
  @Local SheetSize1: number = SheetSize.LARGE;
  @Local SheetSize2: number = SheetSize.LARGE
  @Local openArrow: boolean = false
  @Local isShowHide: boolean[] = []
  @Event getTransitRoutes: (origin: string, destination: string, currentIndex: number) => Promise<TransitDetailModel>
  saveClass: SaveOneClass = AppStorageV2.connect(SaveOneClass, () => new SaveOneClass())!;
  // 站点详情相关
  @Local stopDetailModel?: StopDetailModel
  @Local addTagName: string = ''
  // 保存单个的站点总数
  @Local selectSaveSum: number = 0;
  // 保存的起始站点
  @Local selectSaveAddress?: string
  @Param isOpenOnePlanning?: boolean = false
  @Param isVip?: boolean = false
  @Local isCheckSave: boolean = false
  windowClass: window.Window | undefined = undefined
  promptAction: PromptAction = this.getUIContext().getPromptAction();
  // 回调参数
  @Param onNearbyStopsRequested?: (location: string) => Promise<StopDetailModel[]> = undefined
  @Param @Require routeStopDetailPage: (stopId: string) => void
  @Param onNavigateToStopDetail?: (stopDetailModel: StopDetailModel) => void = undefined
  @Local transitDetailModel?: TransitDetailModel
  @Local selectOneTransitModel?: TransitRouteTransit
  @Local isSlectID?: number
  @Local isDaoHangIng?: boolean = false
  @Event onFavoriteClick?: () => void // 收藏按钮点击事件
  @Event onSearchStop: (keyWord: string) => Promise<StopDetailModel[]> // 搜索站点
  @Event onSettingClick?: () => void // 设置按钮点击事件
  @Param arrivalReminderStations: number = 0
  @Param mapSettingModel: MapSettingModel = new MapSettingModel();
  @Local comingBus: ComingBus = new ComingBus()
  @Local minutePerTrip: number = 5
  @Local realTimeLatLng?: RealTimeLatLng
  @Local isSearchingTransit: boolean = false; // 是否搜索路线中
  private collectionSaveTagModel: CollectionSaveTagModel =
    PersistenceV2.connect(CollectionSaveTagModel, () => TagServiceApi.getCollectionSaveTags())!;
  private saveAllClass: SaveAllClass =
    AppStorageV2.connect(SaveAllClass, () => new SaveAllClass())!;
  // 创建TextInputController实例
  private textInputController: TextInputController = new TextInputController();
  private mapController?: map.MapComponentController;
  private callback?: AsyncCallback<map.MapComponentController>;
  private marker?: map.Marker;
  private mapOption?: mapCommon.MapOptions;
  private context: Context = this.getUIContext().getHostContext()!;
  // 记录高德返回的站点类型：'0'公交，'1'地铁
  private idToBusSubwayType: Map<string, string> = new Map<string, string>();
  private addTagDialogComponentId: number = 0;
  private drawRouteModel: DrawRouteModel = new DrawRouteModel();
  // Setting
  private readonly SETTING_SPEED: number[] = [10, 30, 60]
  private realTimeLocations: RealTimeLatLng[] = [];
  private currentWGS84location?: geoLocationManager.Location;
  private timerID: number = 0
  // 站点一半的距离 单位公里
  private readonly HALF_TIME_BETWEEN_STOP: number = 1
  @Event onInterceptLogin: (cb: (isLogin: boolean) => void) => void = () => {
  };

  @Monitor('isShowPlanning')
  async onChangeLocation() {
    if (this.latitude && this.longitude && this.selectedLatitude && this.selectedLongitude && this.isShowPlanning) {
      this.isSearchingTransit = true
      await this.testGetTransitRoutes(this.latitude, this.longitude, this.selectedLatitude,
        this.selectedLongitude)
    }
  }

  @Monitor('transitDetailModel')
  onChangetTransitDetailModel() {
    if (!this.transitDetailModel?.route?.transits) {
      return;
    }

    this.transitDetailModel.route.transits.forEach((value: TransitRouteTransit, index: number) => {
      // 处理出发站点信息
      this.processDepartureStop(value);

      // 处理路段信息
      this.processSegments(value);

      // 更新数组数据
      this.updateRouteData(index);

      // 重置临时变量
      this.resetTempVariables();
    });
  }

  private processDepartureStop(value: TransitRouteTransit): void {
    if (!value.segments || !value.segments[0] || !value.segments[0].bus ||
      !value.segments[0].bus.buslines || !value.segments[0].bus.buslines[0]) {
      return;
    }

    const busline = value.segments[0].bus.buslines[0];
    if (busline.type === '普通公交线路') {
      this.addressAction = busline.departureStop?.name + '(公交站)';
    } else {
      this.addressAction = busline.departureStop?.name + '(地铁站)';
    }
  }

  private processSegments(value: TransitRouteTransit): void {
    if (!value.segments) {
      return;
    }

    value.segments.forEach((segment: TransitRouteTransitSegment) => {
      // 计算站点数量
      if (segment.bus && segment.bus.buslines && segment.bus.buslines[0]?.viaStops) {
        this.sum += segment.bus.buslines[0].viaStops.length + 1;
      }

      // 计算步行距离
      if (segment.walking?.distance) {
        this.isDistance += Number(segment.walking.distance);
      }
    });
  }

  private updateRouteData(index: number): void {
    this.nestedArray[index] = [
      this.addressAction ? this.addressAction : '',
      this.sum ? this.sum.toString() : ''
    ];
    this.isAllWalKDistance[index] = this.isDistance;
  }

  private resetTempVariables(): void {
    this.isDistance = 0;
    this.addressAction = '';
    this.sum = 0;
  }

  // 获取当前位置开关状态，拉起全局开关设置弹出框。
  isLocationToggle() {
    let atManager = abilityAccessCtrl.createAtManager();
    let isLocationEnabled = geoLocationManager.isLocationEnabled();
    if (!isLocationEnabled) {
      atManager.requestGlobalSwitch(this.context, abilityAccessCtrl.SwitchType.LOCATION).then((data: boolean) => {
        if (data) {
          this.hasPremission = true
          // 获取当前位置
          this.getLocationPosition();
          // 后台定位
          this.onLocationChange();
          // 持续定位
          this.startContinuousTask();

        } else {
          this.hasPremission = false
        }
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'Index', 'data:' + JSON.stringify(err));
      });
    } else {
      this.hasPremission = true
      // 获取当前位置
      this.getLocationPosition();
      // 后台定位
      this.onLocationChange();

    }
  }

  // 监听当前位置信息的改变
  onLocationChange(): void {
    let request: geoLocationManager.ContinuousLocationRequest = {
      interval: 1,
      locationScenario: MapDetailCommonConstants.NAVIGATION
    };
    try {
      geoLocationManager.on('locationChange', request, this.locationChange);
      if (!this.judgeHasNet()) {
        promptAction.showToast({
          message: '网络以断开请检查网络连接',
          duration: 2000
        });
        this.marker?.setInfoWindowVisible(false);
        this.address = '';
      }
    } catch (err) {
      hilog.error(0x0000, TAG, `onLocationChange failed, code: ${err.code}, message: ${err.message}`);
      this.locationFailedAlert(err.code);
    }
  }

  // 停止位置的监听
  offLocationChange(): void {
    try {
      geoLocationManager.off('locationChange', this.locationChange);
    } catch (err) {
      hilog.error(0x0000, TAG, `offLocationChange failed, code: ${err.code}, message: ${err.message}`);
    }
  }

  async setEnabled() {
    // 启用我的位置图层
    this.mapController?.setMyLocationEnabled(true);
    // 启用我的位置按钮 禁用采用自定义的组件实现定位功能
    this.mapController?.setMyLocationControlsEnabled(false)
    let style: mapCommon.MyLocationStyle = {
      anchorU: 0.5,
      anchorV: 0.5,
      displayType: mapCommon.MyLocationDisplayType.FOLLOW_ROTATE,
      // icon为自定义图标资源，使用时需要替换
      // 图标存放在resources/rawfile，icon参数传入rawfile文件夹下的相对路径
      icon: $r('app.media.my_location_icon'),
      // displayType: mapCommon.MyLocationDisplayType.FOLLOW
    };
    await this.mapController?.setMyLocationStyle(style);
    // 缩放控制器的启用状态
    this.mapController?.setZoomControlsEnabled(false)

    this.mapController?.setCompassControlsEnabled(false)
  }

  // 反向地理编码并且在地图上绘制标记
  async getAddress(location: LocationInter, isCameraUpdate?: boolean) {
    try {
      let mapLocation: mapCommon.LatLng = {
        latitude: location.latitude,
        longitude: location.longitude
      };

      if (isCameraUpdate) {
        let cameraPosition: mapCommon.CameraPosition = {
          target: mapLocation,
          zoom: 15,
          tilt: 0,
          bearing: 0
        };
        // 让相机不跟随移动就不要写这个
        let cameraUpdate = map.newCameraPosition(cameraPosition);

        this.mapController?.animateCamera(cameraUpdate, 100);

      }

      this.setEnabled()
    } catch (error) {
      hilog.error(0x0000, TAG, `getAddress failed, code: ${error.code}, message: ${error.message}`);
    }
  }

  // 使用回调获取附近公交地铁站点
  async loadNearbyStopsFromCallback(origin: boolean) {
    try {
      if (this.onNearbyStopsRequested && this.longitude && this.latitude) {
        // 调用回调函数获取附近站点
        let longitude = this.longitude;
        let latitude = this.latitude;
        if (!origin) {
          longitude = this.realTimeLatLng?.longitude ? this.realTimeLatLng?.longitude : this.longitude
          latitude = this.realTimeLatLng?.latitude ? this.realTimeLatLng?.latitude : this.latitude
        }
        const locationStr = `${longitude},${latitude}`;
        const aroundStops = await this.onNearbyStopsRequested(locationStr);

        if (aroundStops && aroundStops.length > 0) {
          // 在地图上添加回调返回的站点标记
          await this.addCallbackStopMarkers(aroundStops);
        }
      } else {
        // 如果没有提供回调，使用鸿蒙原生API作为备用
        await this.loadNearbyStopsFromHarmony();
      }
    } catch (error) {
      hilog.error(0x0000, TAG, `loadNearbyStopsFromCallback failed: ${JSON.stringify(error)}`);
      // 降级到鸿蒙原生API
      await this.loadNearbyStopsFromHarmony();
    }
  }

  // 在地图上添加回调返回的站点标记
  async addCallbackStopMarkers(stops: StopDetailModel[]) {
    // 先清除之前的站点标记，防止重复点击时图标重叠
    this.mapController?.clear();
    for (let stop of stops) {
      if (stop.latitude && stop.longitude && stop.siteId) {
        let markerOptions: mapCommon.MarkerOptions = {
          position: {
            latitude: stop.latitude,
            longitude: stop.longitude,
          },
          clickable: true,
          // 根据站点类型设置图标
          icon: stop.stopType === 'subway_station' ? $r('app.media.stop_sub') : $r('app.media.stop_bus'),
          title: stop.siteId, // 标题使用站点ID，便于回查
        };

        // 记录该标记的类型，用于点击时判定
        this.idToBusSubwayType.set(stop.siteId, stop.stopType === 'subway_station' ? '1' : '0');

        await this.mapController?.addMarker(markerOptions);
      }
    }
  }

  // 保留原有的鸿蒙API方法作为备用
  async loadNearbyStopsFromHarmony() {
    let totalSite: site.Site[] = [];
    let paramsBus: site.NearbySearchParams = {
      location: {
        latitude: this.latitude!,
        longitude: this.longitude!
      },
      // 取值范围
      radius: 1500,
      // 每一页返回的数据量取值范围
      pageSize: 20,
      poiTypes: [
        'BUS_STATION',
        'SUBWAY'
      ]
    }
    try {
      let resultBus = await site.nearbySearch(paramsBus)
      // 获取得到的附近的公交和地铁的页数
      let length: number = Math.ceil(resultBus.totalCount / 20)

      for (let i: number = 1; i <= length; i++) {
        let paramsBus: site.NearbySearchParams = {
          location: {
            latitude: this.latitude!,
            longitude: this.longitude!
          },
          // 取值范围
          radius: 1500,
          // 每一页返回的数据量取值范围
          pageSize: 20,
          pageIndex: i,
          poiTypes: [
            'BUS_STATION',
            'SUBWAY'
          ]
        }
        let resultBus = await site.nearbySearch(paramsBus)
        if (resultBus.sites) {
          totalSite = totalSite.concat(resultBus.sites)
        }
      }
    } catch (err) {
      hilog.error(0x0000, TAG, `get total site failed, code: ${err.code}, message: ${err.message}`);
      return
    }
    this.nearly = totalSite
    if (this.nearly) {
      this.nearly.forEach(async (value: site.Site, index: number, array: site.Site[]) => {
        if (value) {
          if (value.poi?.poiTypes) {
            let markerOptions: mapCommon.MarkerOptions = {
              position: {
                latitude: Number(value.location?.latitude),
                longitude: Number(value.location?.longitude),
              },
              clickable: true,
              // 设置标点
              icon: value.poi?.poiTypes[0] === 'SUBWAY' ? $r('app.media.ic_sub') : $r('app.media.ic_bus'),
              title: String(value.siteId),
            };
            await this.mapController?.addMarker(markerOptions)
          }
        }
      })
    }
  }

  // 处理回调站点标记点击事件
  handleCallbackMarkerClick(markerTitle: string) {
    try {
      this.routeStopDetailPage(markerTitle);
    } catch (error) {
      hilog.error(0x0000, TAG, `handleCallbackMarkerClick failed: ${JSON.stringify(error)}`);
    }
  }

  // 检测是否联网
  judgeHasNet(): boolean {
    try {
      let netHandle = connection.getDefaultNetSync();
      if (!netHandle || netHandle.netId === 0) {
        return false;
      }
      let netCapability = connection.getNetCapabilitiesSync(netHandle);
      let cap = netCapability.networkCap || [];
      if (cap.includes(connection.NetCap.NET_CAPABILITY_VALIDATED)) {
        return true;
      } else {
        return false;
      }
    } catch (err) {
      hilog.error(0x0000, TAG, `JudgeHasNet failed, code: ${err.code}, message: ${err.message}`);
    }
    return false;
  }

  locationChange = (location: geoLocationManager.Location): void => {
    this.getAddress({
      latitude: location.latitude,
      longitude: location.longitude
    });
  }

  // 位置功能打开失败策略
  locationFailedAlert(errCode: number) {
    if (errCode === MapDetailCommonConstants.LOCATION_SWITCH_OFF) {
      promptAction.showToast({
        message: '位置功能关闭，请检查位置设置',
        duration: 2000
      });
    } else if (errCode === MapDetailCommonConstants.LOCATION_FAILED) {
      promptAction?.showToast({
        message: '网络已断开，请检查网络设置',
        duration: 2000
      });
    } else if (errCode === MapDetailCommonConstants.REVERSE_GEOCODING_FAILED) {
      promptAction.showToast({
        message: '网络已断开，请检查网络设置',
        duration: 2000
      });
    } else if (errCode === MapDetailCommonConstants.WIFI_BLUETOOTH_OFF) {
      promptAction.showToast({
        message: 'wify或者蓝牙已经断开检查连接',
        duration: 2000
      });
    }

    this.marker?.setInfoWindowVisible(false);

  }

  // 获取当前位置信息
  getLocationPosition(): void {
    LocationUtils.getGCJ02CurrentLocation().then(async (location: mapCommon.LatLng) => {
      // 存储当前位置信息
      this.latitude = location.latitude
      this.longitude = location.longitude

      // 获取附近公交地铁
      if (!this.isDaoHangIng) {
        await this.loadNearbyStopsFromCallback(true);
      }

      let latlng: mapCommon.LatLng = {
        latitude: location.latitude!,
        longitude: location.longitude!
      }
      latlng = LocationUtils.convertGCJ02TOWGS84(latlng)
      if (this.currentWGS84location) {
        this.currentWGS84location.latitude = latlng.latitude
        this.currentWGS84location.longitude = latlng.longitude
        this.mapController?.setMyLocation(this.currentWGS84location)
      }
      // 定位
      this.getAddress({
        latitude: location.latitude,
        longitude: location.longitude,
      }, true)

    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `getCurrentLocationPosition failed, code: ${err.code}, message: ${err.message}`);
      /*this.locationFailedAlert(err.code);*/
    });
  }

  // 打开后台定位
  startContinuousTask(): void {
    let context = getContext(this) as common.UIAbilityContext;
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: context.abilityInfo.bundleName,
          abilityName: context.abilityInfo.name
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 1,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };

    try {
      wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj) => {
        backgroundTaskManager.startBackgroundRunning(this.context,
          backgroundTaskManager.BackgroundMode.LOCATION, wantAgentObj).then(() => {
          this.onLocationChange();
          hilog.info(0x0000, TAG, 'startBackgroundRunning succeeded');
        }).catch((err: BusinessError) => {
          hilog.error(0x0000, TAG, `startBackgroundRunning failed, cause:  ${JSON.stringify(err)}`);
        });
      });
    } catch (err) {
      hilog.error(0x0000, TAG, `start continuous task failed, code: ${err.code}, message: ${err.message}`);
      return
    }
  }

  // 关闭后台定位
  stopContinuousTask(): void {
    let contexts = this.context as common.UIAbilityContext;
    if (!contexts) {
      return;
    }
    backgroundTaskManager.stopBackgroundRunning(contexts).then(() => {
      if (!this.isOnLocationChange) {
        this.offLocationChange();
      }
      hilog.info(0x0000, TAG, 'stopBackgroundRunning succeeded');
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `stopBackgroundRunning failed, cause:  ${JSON.stringify(err)}`);
    });
  }

  // 获取到达时间
  getTimeArrive(arrivalTime?: number, isSelectOne?: boolean): string {
    let text: string = ''
    if (arrivalTime) {
      let targetTime = new Date(arrivalTime * 1000);
      const currentTime: Date = new Date();
      // 计算剩余毫秒数（取绝对值确保正值）
      const remainingMs: number = Math.abs(targetTime.getTime() - currentTime.getTime());
      // 计算小时和分钟
      const hours: number = Math.floor(remainingMs / (1000 * 60 * 60));
      const minutes: number = Math.floor((remainingMs % (1000 * 60 * 60)) / (1000 * 60));
      if (hours !== 0) {
        if (isSelectOne) {
          text = hours + '小时' + minutes + '分钟'
        } else {
          text = hours + ' 小时 ' + minutes + ' 分钟'
        }
      } else {
        if (isSelectOne) {
          text = minutes + '分钟'
        } else {
          text = minutes + ' 分钟'
        }
      }
    }
    return text
  }

  getTime(time: number): string {
    let text: string = ''
    // 计算小时、分钟和剩余秒数
    const hours: number = Math.floor(time / 3600);
    let minutes: number = Math.floor((time % 3600) / 60);
    minutes = minutes === 0 ? 1 : minutes
    if (hours > 0) {
      text = hours + '小时'
    }
    text = text + minutes + '分钟'
    return text
  }

  getDistance(distance: number): string {
    let thisDistance = (Math.round(distance / 1000 * 100) / 100).toFixed(1)
    let text: string = ''
    if (Number(thisDistance) > 1) {
      text = thisDistance + '公里'
    } else {
      text = distance + '米'
    }
    return text
  }

  // 获取路径
  async testGetTransitRoutes(latitude: number, longitude: number, selectLatitude: number, selectLongitude: number) {
    try {
      this.transitDetailModel =
        await this.getTransitRoutes(longitude + ',' + latitude, selectLongitude + ',' + selectLatitude,
          this.currentIndex)
      this.isSearchingTransit = false
    } catch (error) {
      this.isSearchingTransit = false
      const err: BusinessError = error as BusinessError;
    }
  }

  // 创建站点详情数据模型
  createStopDetailModel(siteData: site.Site) {
    this.stopDetailModel = new StopDetailModel()
    this.stopDetailModel.siteId = siteData.siteId
    this.stopDetailModel.name = siteData.name
    this.stopDetailModel.address = siteData.formatAddress
    this.stopDetailModel.distance = siteData.distance ? Math.round(siteData.distance / 1000 * 10) / 10 : 0 // 转换为公里
    this.stopDetailModel.sameNameCount = 2 // 模拟数据，实际应该从API获取
    this.stopDetailModel.isFavorited = false
    this.stopDetailModel.latitude = siteData.location?.latitude
    this.stopDetailModel.longitude = siteData.location?.longitude

    if (siteData.poi?.poiTypes && siteData.poi.poiTypes[0] === 'SUBWAY') {
      // 地铁站点
      this.stopDetailModel.stopType = 'subway_station'
    } else {
      // 公交站点
      this.stopDetailModel.stopType = 'bus_stop'
    }
  }

  async aboutToAppear(): Promise<void> {
    CommentEventDispatcher.interceptLogin = (cb: (isLogin: boolean) => void) => {
      this.onInterceptLogin(cb)
    }
    this.initializePlanningState();
    this.initializeTabState();
    this.checkPermissionsAndNetwork();
    this.setupMapOptions();
    this.setupMapCallback();
    await this.fetchInitialRoutes();
    await this.setupLocationTracking();
    this.startTimer();
  }

  private initializePlanningState(): void {
    if (this.isOpenOnePlanning) {
      this.isCheckSave = true;
      this.isShowPlanning = true;
      this.showTheClose = true;
      this.openPlanning = true;
      this.latitude = this.saveClass.startLa;
      this.longitude = this.saveClass.startLo;
      this.selectedLatitude = this.saveClass.endLa;
      this.selectedLongitude = this.saveClass.endLo;
      this.selectOneTransitModel = this.saveClass.routers;
      this.selectSaveAddress = this.saveClass.address;

      if (this.saveClass.total && this.saveClass.walkDistance) {
        this.selectSaveSum = this.saveClass.total;
        this.isDistance = this.saveClass.walkDistance;
      }

      this.address = this.saveClass.startAddress;
      this.selectAddress = this.saveClass.endAddress;
      this.isSlectID = Number(this.saveClass.id);
    }
  }

  private initializeTabState(): void {
    this.tabCome = this.istabCome ?? false;
  }

  private checkPermissionsAndNetwork(): void {
    this.isLocationToggle();

    if (!this.judgeHasNet()) {
      promptAction.showToast({
        message: '网络已断开，请检查网络设置',
        duration: 2000
      });
    }
  }

  private setupMapOptions(): void {
    this.mapOption = {
      position: {
        target: this.currentLocation,
        zoom: 15
      },
      scaleControlsEnabled: true
    };
  }

  private setupMapCallback(): void {

    this.callback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        this.mapController?.on('markerClick', async (map) => {
          const markerTitle = map.getTitle();
          ClickUtil.throttle(async () => {
            await this.handleCallbackMarkerClick(markerTitle);
          }, 1000, true)
        });
      }
    };
    }

  private async fetchInitialRoutes(): Promise<void> {
    if (this.latitude && this.longitude && this.selectedLatitude && this.selectedLongitude && this.isShowPlanning) {
      this.isSearchingTransit = true;
      await this.testGetTransitRoutes(this.latitude, this.longitude, this.selectedLatitude, this.selectedLongitude);
    }
  }

  private async setupLocationTracking(): Promise<void> {
    try {
      this.currentWGS84location = await geoLocationManager.getCurrentLocation();
    } catch (err) {
      hilog.error(0x0000, TAG, `setup location tracking failed, code: ${err.code}, message: ${err.message}`);
      return
    }
  }

  private startTimer(): void {
    let index = 0;
    this.timerID = setInterval(() => {
      this.updateRealTimeLocation(index);
      this.updateComingBus();
      index++;
    }, this.SETTING_SPEED[this.mapSettingModel.speedType] * 1000);
  }

  private updateRealTimeLocation(index: number): void {
    if (!this.isDaoHangIng) {
      return;
    }

    if (!this.realTimeLocations || this.realTimeLocations.length === 0) {
      return;
    }

    if (index >= this.realTimeLocations.length) {
      index = 0;
    }

    let realTimeLatLng: RealTimeLatLng = this.realTimeLocations[index];
    let latlng: mapCommon.LatLng = {
      latitude: realTimeLatLng.latitude!,
      longitude: realTimeLatLng.longitude!
    };

    latlng = LocationUtils.convertGCJ02TOWGS84(latlng);

    if (this.currentWGS84location) {
      this.currentWGS84location.latitude = latlng.latitude;
      this.currentWGS84location.longitude = latlng.longitude;
      this.mapController?.setMyLocation(this.currentWGS84location);
      this.realTimeLatLng = {
        segmentIndex: realTimeLatLng.segmentIndex,
        segmentType: realTimeLatLng.segmentType
      };
    }
  }

  private updateComingBus(): void {
    if (this.comingBus!.stations! > 0) {
      this.comingBus!.stations!--;
    } else {
      this.comingBus!.stations! = 10;
    }
  }

  aboutToDisappear(): void {
    clearInterval(this.timerID)
  }

  // 路径规划弹窗关闭,重置起点和终点
  resetAddress() {
    this.address = '我的位置'
    this.longitude = this.currentLocation.longitude
    this.latitude = this.currentLocation.latitude
    this.selectAddress = '你要去哪'
    this.selectedLatitude = undefined
    this.selectedLongitude = undefined
    this.currentIndex = 0
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          if (canIUse('SystemCapability.Map.Core')) {
            MapComponent({
              mapOptions: this.mapOption,
              mapCallback: this.callback,
            })
              .width('100%')
              .height('100%')
          }
        }
        .height('100%')
        .width('100%')

        // 控制 按钮
        this.controllerBuilder()

      }
      .height('100%')
      .width('100%')
      .alignContent(Alignment.Bottom)
      .bindSheet($$this.isShowSave, this.collectionSheet(), {
        height: SheetSize.FIT_CONTENT,
        showClose: true,
        title: { title: '收藏换乘方案' },
        preferType: SheetType.CENTER
      })
      .gesture(
        // 解决长按存在长按属性的控件超过800ms，长按手势无对应事件响应
        LongPressGesture({ duration: 400 })
          .onAction(() => {
          })
      )
    }
    .bindSheet($$this.isShowPlanning, this.mapPlanningBuilder(), {
      preferType: SheetType.CENTER,
      backgroundColor: '#f1f5f8',
      enableOutsideInteractive: true,
      detents: this.isDaoHangIng ? [this.SheetSize1, this.SheetSize2] :
        [this.SheetSize1], //this.isDaoHangIng ? [this.SheetSize1, this.SheetSize2] :
      showClose: this.showTheClose && this.searchType === '',
      mode: SheetMode.OVERLAY,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
      onWillDismiss: ((dismissDialogAction: DismissSheetAction) => {
        // 根据关闭原因处理
        if (dismissDialogAction.reason === DismissReason.CLOSE_BUTTON) {
          if (this.openPlanning) {
            // 关闭详情页面
            this.sum = 0
            this.isCheckSave = false
            this.selectSaveSum = 0
            this.isDistance = 0
            this.openPlanning = false
            this.isSlectID = 0
            this.SheetSize1 = SheetSize.LARGE
            this.SheetSize2 = SheetSize.LARGE
          } else {
            this.resetAddress()
            dismissDialogAction.dismiss();
          }
        } else if (dismissDialogAction.reason === DismissReason.SLIDE_DOWN && !this.showTheClose &&
          !this.isDaoHangIng) {
          // 点击关闭按钮时执行自定义逻辑
          // 必须调用 dismiss() 关闭弹窗
          this.resetAddress()
          dismissDialogAction.dismiss();
        } else if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE && !this.showTheClose &&
          !this.isDaoHangIng) {
          this.resetAddress()
          dismissDialogAction.dismiss();
        }
      })
    })
    .hideTitleBar(true)
  }

  @Builder
  collectionSheet() {
    Column() {
      ForEach(this.collectionSaveTagModel.tagNames, (tag: string) => {
        Row() {
          if (tag === '家') {
            Image($r('app.media.collection_home'))
              .width(24)
              .height(24)
          } else if (tag === '公司') {
            Image($r('app.media.collection_company'))
              .width(24)
              .height(24)
          } else {
            Image($r('app.media.collection_other'))
              .width(24)
              .height(24)
          }
          Text(tag).fontColor(16).fontWeight(FontWeight.Medium)
            .margin({ left: 16 })
        }
        .justifyContent(FlexAlign.Start)
        .width('100%')
        .height(48)
        .onClick(() => {
          // 收藏路线
          this.collectLine(tag)
          this.isShowSave = false
          this.isCheckSave = true
          this.promptAction.showToast({ message: '收藏成功' })
        })
      })
      Row() {
        Image($r('app.media.collection_add'))
          .width(24)
          .height(24)
        Text('添加').fontColor(16).fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .height(48)
      .onClick(() => {
        this.promptAction.openCustomDialog({
          builder: () => {
            this.addTagDialog()
          },
          width: 328,
          height: 192,
          cornerRadius: 32,
          backgroundColor: 'C8FFFFFF'
        }).then((dialogId: number) => {
          this.addTagDialogComponentId = dialogId;
        })
      })
    }

    .padding({ left: 16, right: 16, bottom: 20 })
  }

  // 添加收藏
  collectLine(tag: string) {
    let savePlan: SaveClass | undefined
    this.saveAllClass.saveAllClass.forEach(model => {
      if (model.tag === tag) {
        savePlan = model
        return
      }
    })
    if (savePlan) {
      savePlan.savePlanClass.push({
        routers: this.selectOneTransitModel,
        id: String(this.isSlectID),
        address: this.selectSaveAddress,
        total: this.selectSaveSum,
        walkDistance: this.isDistance,
        startAddress: this.address,
        startLa: this.getLatitudeByLocation(this.transitDetailModel?.route.origin ?? ''),
        startLo: this.getLongitudeByLocation(this.transitDetailModel?.route.origin ?? ''),
        endAddress: this.selectAddress,
        endLa: this.getLatitudeByLocation(this.transitDetailModel?.route.destination ?? ''),
        endLo: this.getLongitudeByLocation(this.transitDetailModel?.route.destination ?? '')
      })
    } else {
      savePlan = new SaveClass()
      savePlan.tag = tag
      savePlan.savePlanClass.push({
        routers: this.selectOneTransitModel,
        id: String(this.isSlectID),
        address: this.selectSaveAddress,
        total: this.selectSaveSum,
        walkDistance: this.isDistance,
        startAddress: this.address,
        startLa: this.latitude,
        startLo: this.longitude,
        endAddress: this.selectAddress,
        endLa: this.selectedLatitude,
        endLo: this.selectedLongitude
      })
      this.saveAllClass.saveAllClass.push(savePlan)
    }
  }

  getLongitudeByLocation(location: string) {
    const locations = location.split(',');
    return Number(locations[0])
  }

  getLatitudeByLocation(location: string) {
    const locations = location.split(',');
    return Number(locations[1])
  }

  addMapMaker(latitudeStr: number, longitudeStr: number, icon: Resource, context: string) {
    let pointAnnotationOptions: mapCommon.PointAnnotationParams = {
      // 定义点注释图标锚点
      position: {
        latitude: latitudeStr,
        longitude: longitudeStr,
      },
      // 定义点注释名称与地图poi名称相同时，是否支持去重
      repeatable: true,
      // 定义点注释的碰撞规则
      collisionRule: mapCommon.CollisionRule.NAME,
      // 定义点注释的标题，数组长度最小为1，最大为3
      titles: [{
        // 定义标题内容
        content: context,
        // 定义标题字体颜色
        color: 0xFF000000,
        // 定义标题字体大小
        fontSize: 12,
        // 定义标题描边颜色
        // strokeColor: 0xFFFFFFFF,
        // 定义标题描边宽度
        strokeWidth: 2,
        // 定义标题字体样式
        fontStyle: mapCommon.FontStyle.ITALIC
      }
      ],
      // 定义点注释的图标，图标存放在resources/rawfile
      icon: icon,
      // 定义点注释是否展示图标
      showIcon: true,
      // 定义点注释的锚点在水平方向上的位置
      anchorU: 1,
      // 定义点注释的锚点在垂直方向上的位置
      anchorV: 0.5,
      // 定义点注释的显示属性，为true时，在被碰撞后仍能显示
      forceVisible: false,
      // 定义碰撞优先级，数值越大，优先级越低
      priority: 3,
      // 定义点注释展示的最小层级
      minZoom: 2,
      // 定义点注释展示的最大层级
      maxZoom: 22,
      // 定义点注释是否可见
      visible: true,
      // 定义点注释叠加层级属性
      zIndex: 10
    }
    if (this.mapController) {
      this.mapController.addPointAnnotation(pointAnnotationOptions);
    }
  }

  addStartAndEndMarkers() {
    // 添加起点标记
    if (this.latitude && this.longitude) {
      let startMarkerOptions: mapCommon.MarkerOptions = {
        position: {
          latitude: this.isOpenOnePlanning && this.saveClass.startLa ? this.saveClass.startLa : this.latitude,
          longitude: this.isOpenOnePlanning && this.saveClass.startLo ? this.saveClass.startLo : this.longitude,
        },
        icon: $r('app.media.ic_map_qidian'), // 起点图标，需要您提供相应的资源
        title: '起点',
      };
      this.mapController?.addMarker(startMarkerOptions);
    }

    // 添加终点标记
    if (this.selectedLatitude && this.selectedLongitude) {
      let endMarkerOptions: mapCommon.MarkerOptions = {
        position: {
          latitude: this.isOpenOnePlanning && this.saveClass.endLa ? this.saveClass.endLa : this.selectedLatitude,
          longitude: this.isOpenOnePlanning && this.saveClass.endLo ? this.saveClass.endLo : this.selectedLongitude,
        },
        icon: $r('app.media.ic_map_zhongdian'), // 终点图标，需要您提供相应的资源
        title: '终点',
      };
      this.mapController?.addMarker(endMarkerOptions);
    }
  }

  @Builder
  addTagDialog() {
    Column() {

      Text('添加标签')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .height(56)
        .lineHeight(24)

      TextInput({ text: $$this.addTagName, placeholder: '请输入标签名称' })
        .height(48)
        .margin({ top: 12 })
        .placeholderColor($r('sys.color.font_secondary'))
        .maxLength(10)
        .backgroundColor($r('sys.color.comp_background_primary'))
        .enterKeyType(EnterKeyType.Done)
        .maxLength(20)

      Row() {
        Row() {
          Text('取消')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .opacity(0.6)
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
        .onClick(() => {
          this.addTagName = ''
          this.promptAction.closeCustomDialog(this.addTagDialogComponentId)
        })

        Row() {
          Text('确定')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#0A59F7')
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
        .onClick(() => {
          if (this.addTagName === '') {
            this.promptAction.showToast({
              message: '请输入标签名称',
              duration: 1000
            })
          } else {
            this.collectionSaveTagModel.tagNames.push(this.addTagName)
            //this.addCollectionLineTag(this.addTagName)
            this.saveAllClass.saveAllClass.push()
            this.addTagName = ''
            this.promptAction.closeCustomDialog(this.addTagDialogComponentId)
          }
        })
      }
      .width('100%')
      .height(40)
      .margin({ top: 20 })
    }
    .padding({ left: 24, right: 24 })
  }

  @Builder
  mapPlanningBuilder() {
    if (this.searchType) {
      SearchMapBuilder(
        (keyWord: string) => {
          return this.onSearchStop(keyWord)
        },
        (stopDetail: StopDetailModel) => {
          this.handleStopSelection(stopDetail);
        },
        () => {
          this.searchType = ''
        }
      )
    } else if (this.openPlanning) {
      this.myPlanning()
    } else {
      this.planningMainContent()
    }
  }

  @Builder
  private planningMainContent() {
    Column() {
      // 标题
      Column() {
        Text('路线规划')
          .fontSize(19)
          .fontWeight(500)
      }
      .width('100%')
      .height($r('app.float.nav_header_height'))
      .justifyContent(FlexAlign.Center)

      // 导航按钮
      this.navigationButtons()

      // 三个tab
      this.tabContents()
    }
    .height('100%')
    .backgroundColor('#f1f5f8')
  }

  @Builder
  private navigationButtons() {
    Row() {
      Column() {
        Row() {
          Image($r('app.media.ic_dao_hang'))
            .width(15)
            .margin({ left: 10 })
          Text(this.address)
            .height(38)
            .fontSize(16)
            .backgroundColor('#ffffff')
            .margin({ left: 10 })
            .width('80%')
            .onClick(() => {
              this.searchType = MapChooseType.ORIGIN
            })
        }

        Divider()
          .color($r('sys.color.comp_divider'))
          .width('87%')
          .height(2)
          .margin({ top: 5, bottom: 5 })

        Row() {
          Image($r('app.media.ic_get_location'))
            .width(17)
            .margin({ left: 10, right: 10 })
          Text(this.selectAddress)
            .height(38)
            .fontSize(16)
            .backgroundColor('#ffffff')
            .borderColor(Color.Black)
            // 消除圆角 保持长方形
            .width('80%')
            .margin({ top: 5 })
            .onClick(() => {
              this.searchType = MapChooseType.TARGET
            })
        }
      }
      .alignItems(HorizontalAlign.Center)
      .width('87%')

      Column() {
        Image($r('app.media.ic_change_station'))
          .width(15)
          .rotate({ angle: 90 })
      }
      .onPressedColumn()
      .height(110)
      .width('13%')
      .justifyContent(FlexAlign.Center)
      .borderRadius(18)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        this.swapOriginAndDestination();
      })
    }
    .height(110)
    .width('93%')
    .justifyContent(FlexAlign.Center)
    .margin({ top: 5 })
    .backgroundColor(Color.White)
    .borderRadius(18)
  }

  @Builder
  private tabContents() {
    Column() {
      Tabs({ barPosition: BarPosition.Start, index: this.currentIndex }) {
        TabContent() {
          this.tabContentBody()
        }.tabBar(this.tabBuilder(0, '推荐'))
        .height('100%')

        TabContent() {
          this.tabContentBody()
        }.tabBar(this.tabBuilder(1, '最快到达'))
        .height('100%')

        TabContent() {
          this.tabContentBody()
        }.tabBar(this.tabBuilder(2, '最少换乘'))
        .height('100%')
      }
      .vertical(false)
      .barMode(BarMode.Fixed)
      .barHeight(56)
      .animationDuration(400)
      .onChange((index: number) => {
        this.handleTabChange(index);
      })
      .borderRadius(5)
    }
    .width('100%')
    .margin({ top: 10 })
    .backgroundColor('#f1f5f8')
  }

  @Builder
  private tabContentBody() {
    if (this.isSearchingTransit &&
    this.latitude && this.longitude &&
    this.selectedLatitude &&
    this.selectedLongitude) {
      this.isLoadding()
    } else {
      this.tab()
    }
  }

  private handleStopSelection(stopDetail: StopDetailModel) {
    if (this.searchType === MapChooseType.TARGET) {
      this.selectAddress = stopDetail.address
      this.selectedLatitude = stopDetail.latitude
      this.selectedLongitude = stopDetail.longitude
    } else {
      this.address = stopDetail.address
      this.latitude = stopDetail.latitude
      this.longitude = stopDetail.longitude
    }
    this.searchType = ''
    if (this.latitude && this.longitude && this.selectedLatitude && this.selectedLongitude &&
    this.isShowPlanning) {
      this.isSearchingTransit = true
      this.testGetTransitRoutes(this.latitude, this.longitude, this.selectedLatitude,
        this.selectedLongitude)
    }
  }

  private swapOriginAndDestination() {
    let add = this.address
    let select = this.selectAddress
    if (this.selectAddress === '你要去哪') {
      this.address = '从哪出发'
      this.selectAddress = add
    } else if (this.address === '从哪出发') {
      this.selectAddress = '你要去哪'
      this.address = select
    } else {
      this.address = this.selectAddress
      this.selectAddress = add
    }

    let la: number | undefined = this.latitude
    this.latitude = this.selectedLatitude
    this.selectedLatitude = la

    let lo: number | undefined = this.longitude
    this.longitude = this.selectedLongitude
    this.selectedLongitude = lo

    if (this.address && this.selectAddress) {
      if (this.latitude && this.longitude && this.selectedLatitude && this.selectedLongitude) {
        this.isSearchingTransit = true
        this.testGetTransitRoutes(this.latitude, this.longitude, this.selectedLatitude,
          this.selectedLongitude)
      }
    }
  }

  private handleTabChange(index: number) {
    this.transitDetailModel = undefined
    this.currentIndex = index
    if (this.latitude && this.longitude && this.selectedLatitude && this.selectedLongitude) {
      this.isSearchingTransit = true
      this.testGetTransitRoutes(this.latitude, this.longitude, this.selectedLatitude, this.selectedLongitude)
    }
  }

  @Builder
  tab() {
    Column() {
      List() {
        if (this.transitDetailModel?.route?.transits) {
          ForEach(this.transitDetailModel?.route.transits, (item: TransitRouteTransit, index: number) => {
            if (item) {
              ListItem() {
                this.transitRouteItem(item, index)
              }
              .margin({ top: 12 })
            }
          }, (v: TransitRouteTransit) => v.cost?.duration)
        }
      }
      .width('100%')
      .alignListItem(ListItemAlign.Center)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .width('100%')
    .margin({ bottom: 180 })
  }

  @Builder
  private transitRouteItem(item: TransitRouteTransit, index: number) {
    Column() {
      // 第一行：时间与步行距离
      this.routeSummaryRow(item, index)

      // 第二行：路线详情
      this.routeDetailsRow(item, index)

      // 第三行：站点信息
      this.stationInfoRow(index)
    }
    .width('90%')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.isSlectID = Date.now()
      this.openPlanning = true
      this.isDistance = this.isAllWalKDistance[index]
      this.selectSaveSum = Number(this.nestedArray[index][1])
      this.selectOneTransitModel = item
      this.selectSaveAddress = this.nestedArray[index][0]
    })
  }

  @Builder
  private routeSummaryRow(item: TransitRouteTransit, index: number) {
    Row() {
      Text(this.getTime(Number(item.cost?.duration)))
        .fontSize(17)
        .fontWeight(500)
      Image($r('app.media.ic_walk'))
        .width(10)
        .margin({ left: 10 })
      if (this.isAllWalKDistance[index] / 1000 > 1) {
        Text((Math.round(this.isAllWalKDistance[index] / 1000 * 100) / 100).toFixed(1) + '公里')
          .fontSize(14)
          .margin({ left: 2 })
      } else {
        Text(this.isAllWalKDistance[index] + '米')
          .fontSize(14)
          .margin({ left: 2 })
      }
    }
    .margin({ top: 10, left: 15, bottom: 10 })
  }

  @Builder
  private routeDetailsRow(item: TransitRouteTransit, index: number) {
    Flex({ wrap: FlexWrap.Wrap, space: { cross: LengthMetrics.px(20) } }) {
      if (this.transitDetailModel?.route.transits) {
        ForEach(this.transitDetailModel?.route.transits[index].segments,
          (itemSegment: TransitRouteTransitSegment, index2: number) => {
            if (itemSegment) {
              this.segmentItem(itemSegment, item, index2)
            }
          }, (v: TransitRouteTransitSegment) => v.walking?.cost?.duration)
      }
    }
    .margin({
      left: 15,
      right: 15,
      bottom: 10
    })
    .width('100%')
    .padding({ right: 15 })
  }

  @Builder
  private segmentItem(itemSegment: TransitRouteTransitSegment, item: TransitRouteTransit, index2: number) {
    if (itemSegment && item.segments) {
      // 步行部分
      if (itemSegment.walking) {
        this.walkingSegment(itemSegment, item, index2)
      }

      // 公交/地铁部分
      if (itemSegment.bus && itemSegment.bus.buslines) {
        if (itemSegment.bus.buslines[0].type === '普通公交线路' && itemSegment.bus.buslines[0].name) {
          this.busSegment(itemSegment, item, index2)
        }
        if (itemSegment.bus.buslines[0].type === '地铁线路' && itemSegment.bus.buslines[0].name) {
          this.subwaySegment(itemSegment, item, index2)
        }
      }
    }
  }

  @Builder
  private walkingSegment(itemSegment: TransitRouteTransitSegment, item: TransitRouteTransit, index2: number) {
    Row() {
      // 步行的情况
      Image($r('app.media.is_walk'))
        .width(15)
        .margin({ right: 2 })
      Text(this.getTime(Number(itemSegment?.walking?.cost?.duration)))
        .fontSize(14)
        .margin({ right: 5 })
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#fff3f3f3')
    .borderRadius(8)
    .height(20)

    if (index2 !== (item.segments?.length ?? 0 - 1) || (itemSegment.bus && itemSegment.walking)) {
      Image($r('app.media.ic_zhong_jian'))
        .width(20)
    }
  }

  getSegmentName(name: string) {
    if (!name) {
      return ''
    }
    return name.substring(0, name.indexOf('('))
  }

  @Builder
  private busSegment(itemSegment: TransitRouteTransitSegment, item: TransitRouteTransit, index2: number) {
    Column() {
      Text(this.getSegmentName(itemSegment?.bus?.buslines ? itemSegment?.bus?.buslines[0]?.name ?? '' : ''))
        .fontSize(14)
        .fontColor('#02A500')
        .margin({ left: 3, right: 3 })
    }
    .height(20)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .borderWidth(1)
    .borderColor('#02A500')
    .backgroundColor('#E0FBEC')
    .borderRadius(8)

    if (item.segments) {
      if (index2 !== item.segments.length - 1) {
        Image($r('app.media.ic_zhong_jian'))
          .width(20)
      }
    }
  }

  @Builder
  private subwaySegment(itemSegment: TransitRouteTransitSegment, item: TransitRouteTransit, index2: number) {
    Column() {
      Text(this.getSegmentName(itemSegment?.bus?.buslines ? itemSegment?.bus?.buslines[0]?.name ?? '' : ''))

        .fontSize(14)
        .fontColor(Color.Black)
        .margin({ left: 5, right: 5 })
    }
    .height(20)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(itemSegment?.bus?.buslines ? itemSegment?.bus?.buslines[0].uicolor ?? '#F7CE00' : '#F7CE00')
    .borderRadius(8)

    if (item.segments) {
      if (index2 !== item.segments.length - 1) {
        Image($r('app.media.ic_zhong_jian'))
          .width(20)
      }
    }
  }

  @Builder
  private stationInfoRow(index: number) {
    if (this.nestedArray[index] && this.nestedArray[index][1] && this.nestedArray[index][0]) {
      Row() {
        Text(`共${this.nestedArray[index][1]}站 · ${this.nestedArray[index][0]} 上车`)
          .fontSize(14)
          .fontColor('#000000')
      }
      .margin({ left: 15, bottom: 10 })
    }
  }

  @Builder
  myPlanning() {
    if (this.selectOneTransitModel) {
      Column() {
        Column() {
          Text(this.isDaoHangIng ? '导航进行中' : '换乘详情')
            .fontSize(20)
            .fontWeight(500)
            .margin({ top: 14, left: 20, bottom: 5 })
        }.width('100%')
        .alignItems(HorizontalAlign.Start)

        Column() {
          Scroll() {
            Column() {
              if (!this.isDaoHangIng) {
                this.planningSummary()
              }
              this.routeDetail()
            }
          }
          .scrollBar(BarState.Off)
          .margin({ top: 10 })
        }.layoutWeight(1)

        Blank()
        this.bottomButtons()
      }.height('100%')
    }
  }

  @Builder
  private planningSummary() {
    Column() {
      Flex({ wrap: FlexWrap.Wrap, space: { cross: LengthMetrics.px(20) } }) {
        if (this.selectOneTransitModel?.segments) {
          ForEach(this.selectOneTransitModel.segments,
            (item: TransitRouteTransitSegment, index2: number) => {
              this.segmentNavigation(item, index2)
            }, (item: TransitRouteTransitSegment) => item.walking?.cost?.duration)
        }
      }
      .margin({
        top: 10,
        left: 15,
        right: 15,
        bottom: 10
      })
      .width('100%')
      .padding({ right: 15 })

      if (this.selectOneTransitModel) {
        Row() {
          Text() {
            Span(`共${this.selectSaveSum}站 · ${this.getTime(Number(this.selectOneTransitModel.cost?.duration))} · 步行约${this.getDistance(this.isDistance)}`)
            if (this.selectOneTransitModel.cost?.transitFee) {
              Span(`· 票价${this.selectOneTransitModel.cost?.transitFee}元`)
            }
          }
          .fontSize(14)
          .fontColor($r('sys.color.icon_secondary'))
          .width('95%')
        }
        .margin({ left: 15, bottom: 10 })
      }
    }
    .width('90%')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .justifyContent(FlexAlign.Center)
    .margin({ top: 10 })
  }

  @Builder
  private segmentNavigation(item: TransitRouteTransitSegment, index2: number) {
    // 走路的情况下
    if (item.walking) {
      this.walkNavigation(item, index2)
    }

    if (item.bus?.buslines && item.bus.buslines[0]) {
      if (item.bus?.buslines[0].type === '地铁线路') {
        this.subwayNavigation(item, index2)
      } else if (item.bus?.buslines[0].type === '普通公交线路') {
        this.busNavigation(item, index2)
      }
    }
  }

  @Builder
  private routeDetail() {
    Column() {
      Row() {
        Image($r('app.media.ic_dao_hang'))
          .width(15)
          .margin({ left: 10, top: 10 })
        Text(this.address + '(起点)')
          .fontSize(18)
          .fontWeight(500)
          .margin({ left: 10, top: 10 })
      }.width('100%')

      ForEach(this.selectOneTransitModel?.segments,
        (itemSections: TransitRouteTransitSegment, indexSections: number) => {
          this.segmentDetail(itemSections, indexSections)
        }, (v: TransitRouteTransitSegment) => v.walking?.cost?.duration)

      Row() {
        Image($r('app.media.ic_end'))
          .width(15)
          .margin({ left: 10, top: 5 })
        Text(this.selectAddress + '(终点)')
          .fontSize(18)
          .fontWeight(500)
          .margin({ left: 10, top: 5 })
      }.width('100%')
      .margin({ bottom: 10 })
    }
    .width('90%')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .justifyContent(FlexAlign.Center)
    .margin({ top: 10 })
  }

  @Builder
  private segmentDetail(itemSections: TransitRouteTransitSegment, indexSections: number) {
    if (itemSections.walking) {
      this.walkingTransit(indexSections, itemSections)
    }

    if (itemSections.bus?.buslines) {
      if (itemSections.bus?.buslines[0].type) {
        this.stationInfo(itemSections, indexSections)
        this.busDirectionInfo(itemSections)
        this.arrivalInfo(itemSections, indexSections)
        this.stationCountInfo(itemSections, indexSections)
        this.viaStopsInfo(itemSections, indexSections)
        this.finalStationInfo(itemSections)
        this.transferInfo(itemSections, indexSections)
      }
    }
  }

  @Builder
  private stationInfo(itemSections: TransitRouteTransitSegment, indexSections: number) {
    // 站点信息
    Row() {
      Stack() {
        Column() {
        }
        .width(12)
        .backgroundColor(itemSections.bus?.buslines![0].type! === '普通公交线路' ? '#00C427' :
          itemSections.bus?.buslines![0].uicolor!)
        .borderRadius({ topLeft: '50%', topRight: '50%' })
        .height(40)

        Circle({ width: 8, height: 8 })
          .fill(Color.White)
          .margin({ top: 3 })
      }.alignContent(Alignment.Top)
      .margin({ left: 10 })

      if (itemSections.bus?.buslines![0].departureStop) {
        Text(itemSections.bus.buslines[0].type === '普通公交线路' ?
          itemSections.bus.buslines[0].departureStop?.name + '(公交站)' :
          itemSections.bus.buslines[0].departureStop?.name + '(地铁站)')
          .fontSize(18)
          .fontWeight(500)
          .margin({ left: 10 })
      }
    }.height(30)
    .margin({ top: 10 })
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  private busDirectionInfo(itemSections: TransitRouteTransitSegment) {
    // 开往哪儿
    Row() {
      Column() {
      }
      .width(12)
      .backgroundColor(itemSections.bus?.buslines![0].type === '普通公交线路' ? '#00C427' :
        itemSections.bus?.buslines![0].uicolor)
      .margin({ left: 10 })
      .height(30)

      Column() {
        Text(itemSections.bus?.buslines![0].name?.substring(0,
          itemSections.bus?.buslines![0].name?.indexOf('(')))
          .fontSize(14)
          .fontColor(itemSections.bus?.buslines![0].type === '普通公交线路' ? '#02A500' :
            Color.Black)
          .margin({ left: 3, right: 3 })
      }
      .height(20)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .borderWidth(1)
      .borderColor(itemSections.bus?.buslines![0].type === '普通公交线路' ? '#02A500' :
        itemSections.bus?.buslines![0].uicolor)
      .backgroundColor(itemSections.bus?.buslines![0].type === '普通公交线路' ? '#E0FBEC' :
        itemSections.bus?.buslines![0].uicolor)
      .borderRadius(8)
      .margin({ left: 10 })

      Text(`开往 · ${itemSections.bus?.buslines![0].endStop}`)
        .fontSize(12)
        .fontColor($r('sys.color.icon_secondary'))
        .margin({ left: 10 })
    }.height(30)
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private arrivalInfo(itemSections: TransitRouteTransitSegment, indexSections: number) {
    // 距离几站 还有几分钟
    Row() {
      Stack() {
        Column() {
        }
        .width(12)
        .backgroundColor(itemSections.bus?.buslines![0].type === '普通公交线路' ? '#00C427' :
          itemSections.bus?.buslines![0].uicolor)
        .height(55)
        .margin({ left: 10 })

        Image($r('app.media.realtime_location'))
          .height(32)
          .margin({ left: 2 })
          .visibility(this.realTimeLatLng?.segmentIndex === indexSections &&
            this.realTimeLatLng?.segmentType === 'bus' ? Visibility.Visible : Visibility.Hidden)
      }
      .alignContent(Alignment.Start)

      this.arrivalReminder(itemSections, indexSections)
    }
  }

  @Builder
  private stationCountInfo(itemSections: TransitRouteTransitSegment, indexSections: number) {
    Row() {
      Column() {
      }
      .width(12)
      .backgroundColor(itemSections.bus?.buslines![0].type === '普通公交线路' ? '#00C427' :
        itemSections.bus?.buslines![0].uicolor)
      .margin({ left: 10 })
      .height(30)

      if (itemSections.bus?.buslines![0].viaStops?.length) {
        Text(`乘坐 ${itemSections.bus?.buslines![0].viaStops?.length +
          1}站 · ${this.getTime(Number(itemSections.bus?.buslines![0].cost?.duration))}`)
          .fontSize(12)
          .fontColor($r('sys.color.icon_secondary'))
          .margin({ left: 10 })
      } else {
        Text(`乘坐 1站 · ${this.getTime(Number(itemSections.bus?.buslines![0].cost?.duration))}`)
          .fontSize(12)
          .fontColor($r('sys.color.icon_secondary'))
          .margin({ left: 10 })
      }

      if (itemSections.bus?.buslines![0].viaStops) {
        if (itemSections.bus?.buslines![0].viaStops?.length > 0) {
          Image(this.isShowHide[indexSections] ? $r('app.media.arrowon') : $r('app.media.arrow'))
            .width(30)
            .onClick(() => {
              this.isShowHide[indexSections] = !this.isShowHide[indexSections]
            })
        }
      }
    }.width('100%')
  }

  @Builder
  private viaStopsInfo(itemSections: TransitRouteTransitSegment, indexSections: number) {
    if (this.isShowHide[indexSections]) {
      ForEach(itemSections.bus?.buslines![0].viaStops,
        (itemsViaStop: TransitRouteTransitSegmentBusBuslineViaStop, indexs: number) => {
          if (itemSections.bus?.buslines && itemSections.bus?.buslines[0].viaStops) {
            Row() {
              Stack() {
                Column() {
                }
                .width(12)
                .backgroundColor(itemSections.bus?.buslines[0].type === '普通公交线路' ?
                  '#00C427' : itemSections.bus.buslines[0].uicolor)
                .height(30)

                Circle({ width: 8, height: 8 })
                  .fill('#80ffffff')
              }.height(30)
              .margin({ left: 10 })
              .alignContent(Alignment.Center)

              Text(itemsViaStop.name)
                .fontSize(11)
                .margin({ left: 10 })
            }
          }
        }, (v: TransitRouteTransitSegmentBusBuslineViaStop) => v.id)
    }
  }

  @Builder
  private finalStationInfo(itemSections: TransitRouteTransitSegment) {
    Row() {
      Stack() {
        Column() {
        }
        .width(12)
        .backgroundColor(itemSections.bus?.buslines![0].type === '普通公交线路' ? '#00C427' :
          itemSections.bus?.buslines![0].uicolor)
        .height(30)
        .borderRadius({ bottomLeft: '50%', bottomRight: '50%' })

        Circle({ width: 8, height: 8 })
          .fill(Color.White)
          .margin({ bottom: 3 })
      }.height(30)
      .margin({ left: 10 })
      .alignContent(Alignment.Bottom)

      // 最后一个站点
      Text(itemSections.bus?.buslines![0].type === '普通公交线路' ?
        itemSections.bus?.buslines![0].arrivalStop?.name + '(公交站)' :
        itemSections.bus?.buslines![0].arrivalStop?.name + '(地铁站)')
        .fontSize(18)
        .fontWeight(500)
        .margin({ left: 10 })
    }
    .height(30)
    .margin({ bottom: 10 })
    .alignItems(VerticalAlign.Bottom)
  }

  @Builder
  private transferInfo(itemSections: TransitRouteTransitSegment, indexSections: number) {
    // 检查是否为站内换乘（连续两段公交/地铁的到达站和出发站相同）
    if (this.selectOneTransitModel &&
    this.selectOneTransitModel.segments &&
      this.selectOneTransitModel.segments.length > indexSections + 1 &&
      itemSections.bus?.buslines?.[0]?.arrivalStop?.name &&
      this.selectOneTransitModel.segments[indexSections +
        1]?.bus?.buslines?.[0]?.departureStop?.name) {
      if (itemSections.bus?.buslines?.[0]?.arrivalStop?.name ===
        this.selectOneTransitModel.segments[indexSections +
          1]?.bus?.buslines?.[0]?.departureStop?.name &&
        !this.selectOneTransitModel.segments[indexSections + 1]?.walking) {
        // 站内换乘逻辑处理
        Row() {
          Stack() {
            Image($r('app.media.dian_dian'))
              .height(40)
              .margin({ right: 2 })
            Image($r('app.media.realtime_location'))
              .height(32)
              .margin({ left: 2 })
              .visibility(this.realTimeLatLng?.segmentIndex === indexSections &&
                this.realTimeLatLng?.segmentType === '站内换乘' ? Visibility.Visible :
                Visibility.Hidden)
          }

          Image($r('app.media.is_walk'))
            .width(15)

          Text('站内换乘')
            .fontSize(14)
            .margin({ left: 10 })
        }.width('100%')
        .alignItems(VerticalAlign.Center)
      }
    }
  }

  @Builder
  private bottomButtons() {
    // 底部按钮
    if (this.isDaoHangIng) {
      Button() {
        Text('退出导航')
          .fontColor($r('sys.color.font_emphasize'))
      }
      .width('90%')
      .height(35)
      .onClick(async () => {
        this.showTheClose = true
        this.isDaoHangIng = false
        this.SheetSize1 = SheetSize.LARGE
        this.realTimeLocations = []
        this.mapController?.clear()
        await this.loadNearbyStopsFromCallback(false)
      })
      .backgroundColor('#e4e8eb')
      .margin({ bottom: 50 })
    } else {
      Row() {
        Column() {
          Image(this.isCheckSave ? $r('app.media.collect_star_cancel') : $r('app.media.collect_star'))
            .width(24)
            .margin({ top: 10 })
          Text(this.isCheckSave ? '取消收藏' : '收藏')
            .fontSize(13)
            .margin({ top: 10 })
        }.margin({ right: 70 })
        .onClick(() => {
          this.handleFavoriteClick()
        })

        Column() {
          Image($r('app.media.go_go_go'))
            .width(24)
            .margin({ top: 10 })
          Text('出发')
            .fontSize(13)
            .margin({ top: 10 })
        }.margin({ left: 70 })
        .onClick(() => {
          this.starNavigation();
        })
      }.height(80)
      .backgroundColor('#F1F3F5')
      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.Center)
    }
  }

  private handleFavoriteClick() {
    if (this.onFavoriteClick) {
      this.onFavoriteClick()
    }
    if (!this.isCheckSave && this.isShowSave) {
      this.isShowSave = true
    } else {
      for (let i = this.saveAllClass.saveAllClass.length - 1; i >= 0; i--) {
        const Model: SaveClass =
          this.saveAllClass.saveAllClass[i]
        for (let j = Model.savePlanClass.length - 1; j >= 0; j--) {
          const detailModel: SaveOneClass = Model.savePlanClass[j]
          if (detailModel.id === String(this.isSlectID)) {
            Model.savePlanClass.splice(j, 1)
            // 为空值将tag删除
            this.isCheckSave = false
            this.isShowSave = false
            this.promptAction.showToast({ message: '取消收藏成功' })
          }
        }
      }
    }
  }

  private starNavigation() {
    this.showTheClose = false;
    this.isDaoHangIng = true;
    this.mapController?.clear();
    this.SheetSize1 = 250;
    this.SheetSize2 = SheetSize.LARGE;
    let roadsWalk: mapCommon.LatLng[] = [];
    let roadsBus: mapCommon.LatLng[] = [];

    this.selectOneTransitModel?.segments?.forEach((value: TransitRouteTransitSegment, index: number) => {
      if (value.walking) {
        this.processWalkingSegment(value, index, roadsWalk);
      }

      if (value.bus?.buslines && value.bus.buslines[0] &&
        value.bus.buslines[0].departureStop?.location && value.bus.buslines[0].arrivalStop?.location) {
        this.processBusSegment(value, index, roadsBus);
      }
    }, (v: TransitRouteTransitSegment) => v.walking?.cost?.duration);

    this.addStartAndEndMarkers();
  }

  private processWalkingSegment(value: TransitRouteTransitSegment, index: number, roadsWalk: mapCommon.LatLng[]): void {
    value.walking!.steps?.forEach((value2: TransitRouteTransitSegmentWorkStep) => {
      if (value2.polyline?.polyline) {
        const points = value2.polyline.polyline.split(';');
        for (let i = 0; i < points.length; i++) {
          const point = points[i];
          if (point.trim().length === 0) {
            continue;
          }

          const coords = point.split(',');
          const longitudeStr = coords[0];
          const latitudeStr = coords[1];

          const coordinate: mapCommon.LatLng = {
            longitude: parseFloat(longitudeStr),
            latitude: parseFloat(latitudeStr)
          };

          roadsWalk.push(coordinate);

          if (i % 5 === 0) {
            const realTimeLocation: RealTimeLatLng = {
              latitude: coordinate.latitude,
              longitude: coordinate.longitude,
              segmentIndex: index,
              segmentType: 'walk'
            };
            this.realTimeLocations.push(realTimeLocation);
          }
        }

        this.drawRouteModel.drawRoute(this.mapController, roadsWalk, 'walk');
        roadsWalk.length = 0;
      }
    });
  }

  private processBusSegment(value: TransitRouteTransitSegment, index: number, roadsBus: mapCommon.LatLng[]): void {
    // 添加上车站点标记
    const departureCoords = value.bus!.buslines![0].departureStop!.location!.split(',');
    if (value.bus!.buslines![0].departureStop?.name) {
      this.addMapMaker(
        Number(departureCoords[1]),
        Number(departureCoords[0]),
        $r('app.media.shangche'),
        value.bus!.buslines![0].departureStop.name
      );
    }

    // 添加下车站点标记
    const arrivalCoords = value.bus!.buslines![0].arrivalStop!.location!.split(',');
    if (value.bus!.buslines![0].arrivalStop?.name) {
      this.addMapMaker(
        Number(arrivalCoords[1]),
        Number(arrivalCoords[0]),
        $r('app.media.xiache'),
        value.bus!.buslines![0].arrivalStop.name
      );
    }

    // 添加途经站点标记
    value.bus!.buslines![0].viaStops?.forEach((stop: TransitRouteTransitSegmentBusBuslineViaStop) => {
      if (stop.location) {
        const coords = stop.location.split(',');
        if (stop.name) {
          this.addMapMaker(
            Number(coords[1]),
            Number(coords[0]),
            $r('app.media.yuan'),
            stop.name
          );
        }
      }
    });

    // 绘制公交/地铁线路
    const polyline = value.bus!.buslines![0].polyline?.polyline;
    if (polyline) {
      const points = polyline.split(';');
      for (let i = 0; i < points.length; i++) {
        const point = points[i];
        if (point.trim().length === 0) {
          continue;
        }

        const coords = point.split(',');
        const longitudeStr = coords[0];
        const latitudeStr = coords[1];

        const coordinate: mapCommon.LatLng = {
          longitude: parseFloat(longitudeStr),
          latitude: parseFloat(latitudeStr)
        };

        if (i % 10 === 0) {
          const realTimeLocation: RealTimeLatLng = {
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            segmentIndex: index,
            segmentType: 'bus'
          };
          this.realTimeLocations.push(realTimeLocation);
        }

        roadsBus.push(coordinate);
      }

      if (value.bus!.buslines![0].type === '地铁线路') {
        let colorNumber: number = 0;
        if (value.bus!.buslines![0].uicolor) {
          const color: string = value.bus!.buslines![0].uicolor.substring(1);
          const argbHex: string = 'FF' + color;
          colorNumber = parseInt(argbHex, 16);
        }
        this.drawRouteModel.drawRoute(this.mapController, roadsBus, 'sub', colorNumber);
      } else {
        this.drawRouteModel.drawRoute(this.mapController, roadsBus, 'bus');
      }

      roadsBus.length = 0;
    }
  }

  @Builder
  arrivalReminder(itemSections: TransitRouteTransitSegment, indexSections: number) {
    Column() {
      if (itemSections.bus?.buslines![0].type === '普通公交线路') {
        if (this.comingBus) {
          if (this.comingBus.stations! + indexSections * 2 <= this.arrivalReminderStations &&
          this.mapSettingModel.isArrivalReminder) {
            if (this.comingBus.stations! + indexSections * 2 <= 1) {
              Row() {
                Text('即将进站').fontColor('#E84026').fontSize(16);
                Text('·').fontColor('#E84026').margin({ left: 1, right: 1 });
                Text((this.comingBus.stations! + indexSections * 2) *
                this.HALF_TIME_BETWEEN_STOP * 2 + '分钟')
                  .fontColor('#E84026')
                  .fontSize(16);
                Image($r('app.media.arrival_notice')).width(10).height(10)
                  .offset({ y: -15 });
              }.margin({ left: 12 });
            } else {
              Row() {
                Text(this.comingBus.stations! + indexSections * 2 + '站')
                  .fontColor('#E84026')
                  .fontSize(16);
                Text('·').fontColor('#E84026').margin({ left: 1, right: 1 });
                Text((this.comingBus.stations! + indexSections * 2) *
                this.HALF_TIME_BETWEEN_STOP * 2 + '分钟')
                  .fontColor('#E84026')
                  .fontSize(16);
                Image($r('app.media.arrival_notice')).width(10).height(10)
                  .offset({ y: -15 });
              }.margin({ left: 12 });
            }

          } else {
            if (this.comingBus.stations! + indexSections * 2 <= 1) {
              Row() {
                Text('即将进站')
                  .fontColor('#0A59F7')
                  .fontSize(16);
                Text('·').fontColor('#0A59F7').margin({ left: 1, right: 1 });
                Text((this.comingBus.stations! + indexSections * 2) *
                this.HALF_TIME_BETWEEN_STOP *
                  2 + '分钟')
                  .fontColor('#0A59F7')
                  .fontSize(16);
                Image($r('app.media.arrival')).width(10).height(10)
                  .offset({ y: -15 });
              }.margin({ left: 12 });
            } else {
              Row() {
                Text(this.comingBus.stations! + indexSections * 2 + '站')
                  .fontColor('#0A59F7')
                  .fontSize(16);
                Text('·').fontColor('#0A59F7').margin({ left: 1, right: 1 });
                Text((this.comingBus.stations! + indexSections * 2) *
                this.HALF_TIME_BETWEEN_STOP *
                  2 + '分钟')
                  .fontColor('#0A59F7')
                  .fontSize(16);
                Image($r('app.media.arrival')).width(10).height(10)
                  .offset({ y: -15 });
              }.margin({ left: 12 });
            }

          }
        }
      } else {
        Text(this.minutePerTrip + '分钟/班')
          .fontColor('#000000')
          .fontSize(16)
          .opacity(0.6)
          .margin({ left: 12 });
      }

    }
    .height(48)
    .backgroundColor('#fff3f3f3')
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .width('85%')
  }

  @Builder
  walkingTransit(indexSections: number, itemSections: TransitRouteTransitSegment) {
    Row() {
      Stack() {
        Image($r('app.media.dian_dian'))
          .height(40)
          .margin({ right: 2 });
        Image($r('app.media.realtime_location'))
          .height(32)
          .margin({ left: 2 })
          .visibility(this.realTimeLatLng?.segmentIndex === indexSections &&
            this.realTimeLatLng?.segmentType === 'walk' ? Visibility.Visible : Visibility.Hidden);
      };

      Image($r('app.media.is_walk'))
        .width(15);

      if (itemSections.walking) {
        Text(`${this.getDistance(itemSections.walking.distance)} · ${this.getTime(Number(itemSections.walking.cost?.duration))}`)
          .fontSize(14)
          .fontColor($r('sys.color.icon_secondary'))
          .margin({ left: 10 });
      }

    }.width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  busNavigation(item: TransitRouteTransitSegment, index2: number) {
    Column() {
      Text(this.getSegmentName(item?.bus?.buslines ? item?.bus?.buslines[0]?.name ?? '' : ''))
        .fontSize(14)
        .fontColor('#02A500')
        .margin({ left: 3, right: 3 });
    }
    .height(20)
    //.width(50)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .borderWidth(1)
    .borderColor('#02A500')
    .backgroundColor('#E0FBEC')
    .borderRadius(8)

    if (this.selectOneTransitModel?.segments) {
      if (index2 !== this.selectOneTransitModel?.segments?.length - 1) {
        Image($r('app.media.ic_zhong_jian'))
          .width(20);
      }
    }
  }

  @Builder
  subwayNavigation(item: TransitRouteTransitSegment, index2: number) {
    Column() {
      Text(this.getSegmentName(item?.bus?.buslines ? item?.bus?.buslines[0]?.name ?? '' : ''))
        .fontSize(14)
        .fontColor($r('sys.color.icon_secondary'))
        .margin({ left: 5, right: 5 });
    }
    .height(20)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(item?.bus?.buslines ? item?.bus?.buslines[0].uicolor ?? '#F7CE00' : '#F7CE00')
    .borderRadius(8)

    if (this.selectOneTransitModel?.segments) {
      if (index2 !== this.selectOneTransitModel?.segments?.length - 1) {
        Image($r('app.media.ic_zhong_jian'))
          .width(20);
      }
    }
  }

  @Builder
  walkNavigation(item: TransitRouteTransitSegment, index2: number) {
    Row() {
      // 步行的情况
      Image($r('app.media.is_walk'))
        .width(15)
        .margin({ right: 2 });
      if (item.walking?.cost?.duration) {
        Text(this.getTime(Number(item.walking?.cost?.duration)))
          .fontSize(14)
          .fontColor($r('sys.color.icon_secondary'))
          .margin({ right: 5 });
      }
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#fff3f3f3')
    .borderRadius(8)
    .height(20)

    // 桥接图片
    if (this.selectOneTransitModel?.segments) {
      if (index2 !== this.selectOneTransitModel?.segments?.length - 1 ||
        (item.bus && item.walking)) {
        Image($r('app.media.ic_zhong_jian'))
          .width(20);
      }
    }
  }

  @Builder
  controllerBuilder() {
    Column() {
      Row() {
        Image($r('app.media.ic_lu_jing'))
          .width(21)
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .height(35)
      .width(35)
      .borderRadius(8)
      .onPressedRow()
      .onClick(() => {
        this.isShowPlanning = true
        this.transitDetailModel = undefined
        this.selectedLatitude = undefined
        this.selectedLongitude = undefined
        this.selectAddress = '你要去哪'
      })

      Row() {
        Image($r('app.media.ic_my_location'))
          .width(21)
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .height(35)
      .width(35)
      .borderRadius(8)
      .margin({ top: 10 })
      .onPressedRow()
      .onClick(() => {

        // 定位自己的位置信息
        this.getLocationPosition()
      })

    }
    .margin({ bottom: 130, left: '80%' })
  }

  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.currentIndex === index ? this.fontColor2 : this.fontColor)
        .fontSize(16)
        .fontWeight(this.currentIndex === index ? 500 : 400)
        .lineHeight(22)
        .margin({ top: 17, bottom: 7 })
      Row()
        .height(2)
        .backgroundColor('#0A59F7')
        .opacity(this.currentIndex === index ? 1 : 0)
        .width('20%')
    }.width('100%')
  }

  @Builder
  isLoadding() {
    // 显示加载状态
    Column() {
      LoadingProgress()
        .width(40)
        .aspectRatio(1)
        .color($r('sys.color.icon_secondary'))
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}

@Extend(Row)
function onPressedRow() {
  .stateStyles({
    normal: { .backgroundColor('#ffffff')
    },
    pressed: { .backgroundColor('#efefef')
    },
  })
}

@Extend(Column)
function onPressedColumn() {
  .stateStyles({
    normal: { .backgroundColor('#ffffff')
    },
    pressed: { .backgroundColor('#efefef')
    },
  })
}