import {
  AppStorageBank,
  AreaHouse,
  BaseResponse,
  CurrentAddressInfo,
  HouseType,
  IBasicHouse,
  Location,
  MapUtil,
  SystemUtil,
} from 'module_base';
import { promptAction } from '@kit.ArkUI';

@ObservedV2
export class HouseMapVM {
  @Trace houseList: IBasicHouse[] = [];
  @Trace houseMakerList: Location[] = [];
  @Trace areaHouseList: AreaHouse[] = [];
  fetchHousePromise: Promise<BaseResponse<IBasicHouse[]>>[] = [];
  stack: NavPathStack = new NavPathStack();
  private static _instance: HouseMapVM;
  private mu: MapUtil = MapUtil.instance;

  public static get instance() {
    if (!HouseMapVM._instance) {
      HouseMapVM._instance = new HouseMapVM();
    }
    return HouseMapVM._instance;
  }

  applyLocationPermission(uiContext: UIContext) {
    SystemUtil.applyLocationPermission(uiContext.getHostContext()!).then((isGranted) => {
      if (isGranted) {
        SystemUtil.getCurrentCityInfo().then((addressInfo: CurrentAddressInfo) => {
          if (addressInfo.city) {
            AppStorageBank.setCurrentCity(addressInfo.city);
            AppStorageBank.setCurrentLocation(addressInfo.latitude, addressInfo.longitude);
          }
        });
      } else {
        uiContext.getPromptAction().showToast({
          message: '请前往设置-应用和元服务中打开此应用的位置服务开关',
          duration: 2000,
        });
      }
    });
  }

  initMap(uiContext: UIContext) {
    let latitude = AppStorageBank.getCurrentLocation()[0];
    if (latitude) {
      this.mu.initMap(AppStorageBank.getCurrentLocation()[0], AppStorageBank.getCurrentLocation()[1],
        uiContext.getHostContext()!, 10, this.stack);
    } else {
      // 询问申请位置权限
      this.applyLocationPermission(uiContext);
    }
  }

  drawMap() {
    Promise.all(this.fetchHousePromise).then((values) => {
      this.houseList = [...values[0].data, ...values[1].data, ...values[2].data];
      this.houseMakerList = this.houseList.map(item => {
        return {
          type: item.type,
          houseId: item.houseId,
          title: item.cell,
          unit: item.type === HouseType.RENT ? `${item.unit}元/月` : `${item.unit}元/平`,
          latitude: item.latitude,
          longitude: item.longitude,
        } as Location;
      });

      this.clusterHouse(this.houseList);
    });
  }

  getAreaHouseList(list: IBasicHouse[]) {
    let areaHouseList: AreaHouse[] = [];
    list.forEach((item: IBasicHouse) => {
      let areaHouse = areaHouseList.filter((areaHouseItem: AreaHouse) => areaHouseItem.area === item.area)[0];
      if (areaHouse) {
        areaHouse.locations.push({
          title: item.cell,
          unit: item.type === HouseType.RENT ? `${item.unit}元/月` : `${item.unit}元/平`,
          latitude: item.latitude,
          longitude: item.longitude,
        } as Location);
      } else {
        areaHouseList.push({
          area: item.area,
          locations: [{
            title: item.cell,
            unit: item.type === HouseType.RENT ? `${item.unit}元/月` : `${item.unit}元/平`,
            latitude: item.latitude,
            longitude: item.longitude,
          } as Location],
        });
      }
    });
    return areaHouseList;
  }

  clusterHouse(houseList: IBasicHouse[]) {
    this.areaHouseList = this.getAreaHouseList(houseList);
    this.mu.setMakers(this.houseMakerList);
    this.areaHouseList.forEach((clusterData: AreaHouse) => {
      this.mu.clusterHouseByArea(clusterData);
    });
  }
}