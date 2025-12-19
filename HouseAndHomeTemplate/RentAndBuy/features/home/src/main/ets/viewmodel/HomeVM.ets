import { map, mapCommon } from '@kit.MapKit';
import { common } from '@kit.AbilityKit';
import {
  AppStorageBank,
  CurrentAddressInfo,
  HouseType,
  https,
  IBasicHouse,
  IFavoriteRequest,
  INewHouse,
  IRentHouse,
  ISearchRequest,
  ISecondHouse,
  Logger,
  SwiperContent,
  SwiperContentType,
  SwiperOption,
  SwiperType,
  SystemUtils,
  ComplexInfo,
  IHouseListRequest,
  EventEmitName,
} from 'foundation';
import { MapUtil } from 'module_base';

@ObservedV2
export class HomeVM {
  @Trace areaHouseList: [string, number][] = [];
  @Trace hotHouseList: IBasicHouse[] = [];
  @Trace searchHouseList: IBasicHouse[] = [];
  @Trace currentCity: string = '';
  @Trace hotTabIndex: number = 0;
  @Trace searchLoading: boolean = false;
  @Trace loading: boolean = false;
  private static _instance: HomeVM;
  private mu: MapUtil = MapUtil.instance;

  public static get instance() {
    if (!HomeVM._instance) {
      HomeVM._instance = new HomeVM();
    }
    return HomeVM._instance;
  }

  init(context: Context) {
    this.applyLocationPermission(context);
    this.getHouseListByIndex(this.hotTabIndex);
  }

  updateFavorite(houseId: string, type: HouseType) {
    let param: IFavoriteRequest = {
      type: type,
      houseId: houseId,
    };
    https.updateFavorite(param).then((res) => {
      if (res.code === 0) {
        Logger.info('update favorite status success with houseId' + houseId);
      }
    });
  }

  getHouseListByIndex(tabIndex: number) {
    let param: IHouseListRequest = {
      city: AppStorageBank.getCurrentCity(),
      type: tabIndex,
    };
    https.getHotHouseList(param).then((res) => {
      this.hotHouseList = res.data;
      this.loading = false;
    });
  }

  applyLocationPermission(context: Context) {
    SystemUtils.applyLocationPermission(context).then((isGranted) => {
      if (isGranted) {
        SystemUtils.getCurrentCityInfo().then((addressInfo: CurrentAddressInfo) => {
          if (addressInfo.city) {
            this.currentCity = addressInfo.city;
            AppStorageBank.setCurrentCity(this.currentCity);
            AppStorageBank.setCurrentLocation(addressInfo.latitude, addressInfo.longitude);
            (context as common.UIAbilityContext).eventHub.on(EventEmitName.INIT_MAP,
              (latitude: number, longitude: number) => {
                this.mu.initMap(latitude, longitude, context);
              });
          }
        });
      }
    });
  }

  updateCurrentCity(city: string) {
    https.updateCurrentCity(city).then((res) => {
      if (res.code === 0) {
        Logger.info('update current city with city ' + city);
      }
    });
  }

  updateCityList(city: string) {
    https.updateRecentCityList(city).then((res) => {
      if (res.code === 0) {
        Logger.info('update rent city with city ' + city);
      }
    });
  }

  searchHouse(selectedType: HouseType, keyword: string) {
    let param: ISearchRequest = {
      type: selectedType,
      keyword: keyword,
    };
    https.aggregatedHouseSearch(param).then((res) => {
      this.searchHouseList = res.data;
      this.searchLoading = false;
    });
  }

  calcDistance(latitude: number, longitude: number) {
    let fromLatLng: mapCommon.LatLng = {
      latitude: latitude,
      longitude: longitude,
    };

    let toLatLng: mapCommon.LatLng = {
      latitude: AppStorageBank.getCurrentLocation()[0],
      longitude: AppStorageBank.getCurrentLocation()[1],
    };

    return map.calculateDistance(fromLatLng, toLatLng);
  }

  handleNewHouseSwiper(house: INewHouse): SwiperOption[] {
    return [
      {
        swiperType: SwiperType.ANALYSIS,
        contents: house.inspect,
      },
      {
        swiperType: SwiperType.REAL,
        contents: house.real ?? [],
      }
      ,
      {
        swiperType: SwiperType.EFFECT,
        contents: house.effect ? this.getContent(SwiperContentType.IMAGE, house.effect) : [],
      },
      {
        swiperType: SwiperType.LOCATION,
        contents: house.zone ? this.getContent(SwiperContentType.IMAGE, house.zone) : [],
      },
      {
        swiperType: SwiperType.PROGRAM,
        contents: house.onsite ? this.getContent(SwiperContentType.IMAGE, house.onsite) : [],
      },
    ];
  }

  handleSecondHouseSwiper(house: ISecondHouse): SwiperOption[] {
    let swiperList: SwiperOption[] = [
      {
        swiperType: SwiperType.VR,
        contents: [{
          type: SwiperContentType.WEB,
          content: house.vr?.uri ?? '',
          preview: house.vr?.preview ?? '',
        }],
      },
      {
        swiperType: SwiperType.VIDEO,
        contents: house.video ? this.getComplexContent(house.video) : [],
      },
      {
        swiperType: SwiperType.PROGRAM,
        contents: house.zone ? this.getContent(SwiperContentType.IMAGE, house.zone) : [],
      },
      {
        swiperType: SwiperType.HOUSE,
        contents: house.pic ? this.getContent(SwiperContentType.IMAGE, house.pic) : [],
      },
    ];
    return swiperList;
  }

  handleRentHouseSwiper(house: IRentHouse): SwiperOption[] {
    return [
      {
        swiperType: SwiperType.HOUSE,
        contents: house.pic ? this.getContent(SwiperContentType.IMAGE, house.pic) : [],
      },
    ];
  }

  getComplexContent(values: ComplexInfo[]) {
    let contents: SwiperContent[] = values.map(item => {
      return {
        type: SwiperContentType.VIDEO,
        content: item.uri,
        preview: item.preview,
      } as SwiperContent;
    });
    return contents;
  }

  getContent(type: SwiperContentType, values: string[]) {
    let contents: SwiperContent[] = values.map(item => {
      return {
        type: type,
        content: item,
      } as SwiperContent;
    });
    return contents;
  }
}