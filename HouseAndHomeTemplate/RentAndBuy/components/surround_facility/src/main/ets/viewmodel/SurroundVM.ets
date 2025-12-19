import { map, mapCommon, site } from '@kit.MapKit';
import { AppStorageBank, MapUtil } from 'module_base';
import { Facility, FacilityType } from '../model/Index';
import { ADDITIONAL_FACILITY_TYPES } from '../constants/Constant';

@ObservedV2
export class SurroundVM {
  private static _instance: SurroundVM;
  @Trace keyword: string = '';
  @Trace currentFacility?: Facility;
  @Trace facilities: Facility[] = [];
  @Trace fullFacilities: Facility[] = [];
  @Trace latitude: number = 0;
  @Trace longitude: number = 0;
  @Trace isShow: boolean = false;
  @Trace typeIndex: number = 0;
  @Trace list: site.Site[] = [];
  @Trace keyIndex: number = 0;
  mapUtil: MapUtil = MapUtil.instance;
  stack: NavPathStack = new NavPathStack();

  public static get instance() {
    if (!SurroundVM._instance) {
      SurroundVM._instance = new SurroundVM();
    }
    return SurroundVM._instance;
  }

  getFullSurroundFacilityList(context: Context) {
    // 增大缩放比例
    this.mapUtil.initMap(this.latitude, this.longitude, context, 12);
    let promises: Promise<site.SearchByTextResult>[] =
      ADDITIONAL_FACILITY_TYPES.map((item): Promise<site.SearchByTextResult> => {
        return this.getPoiListByText(item.keyword, this.latitude, this.longitude, 5000);
      });
    this.fullFacilities = [];
    let list: Facility[] = [];
    Promise.all(promises).then((values) => {
      values.forEach((item, index) => {
        let facility = {
          type: ADDITIONAL_FACILITY_TYPES[index].type,
          name: ADDITIONAL_FACILITY_TYPES[index].name,
          keyword: ADDITIONAL_FACILITY_TYPES[index].keyword,
          sites: item.sites?.sort((a, b) => (a.distance ?? 0) - (b.distance ?? 0)) ?? [],
        } as Facility;
        list.push(facility);
      });
      this.fullFacilities = [...this.facilities, ...list];
      this.currentFacility = this.fullFacilities[0];
      this.keyword = this.currentFacility.keyword.split(',')[this.keyIndex];
      this.getFacilityList();
    });
  }

  getFacilityList() {
    this.getPoiListByText(this.keyword, this.latitude, this.longitude, 5000).then((res) => {
      this.list = res.sites?.sort((a, b) => (a.distance ?? 0) - (b.distance ?? 0)) ?? [];
      this.mapUtil.drawFacility(this.list, this.currentFacility?.name.slice(0, 2) as FacilityType);
    });
  }

  getSurroundFacilityList(facilityOptions: Facility[]) {
    this.latitude = this.mapUtil.mapOptions?.position.target.latitude ?? 0;
    this.longitude = this.mapUtil.mapOptions?.position.target.longitude ?? 0;
    let promises: Promise<site.SearchByTextResult>[] = facilityOptions.map((item): Promise<site.SearchByTextResult> => {
      return this.getPoiListByText(item.keyword, this.latitude, this.longitude, 5000);
    });
    this.facilities = [];
    Promise.all(promises).then((values) => {
      values.forEach((item, index) => {
        let facility = {
          type: facilityOptions[index].type,
          name: facilityOptions[index].name,
          keyword: facilityOptions[index].keyword,
          sites: item.sites?.sort((a, b) => (a.distance ?? 0) - (b.distance ?? 0)) ?? [],
        } as Facility;
        this.facilities.push(facility);
      });
      this.isShow = true;
    });
  }

  getPreview(title: string) {
    let preview = this.facilities.map((facility: Facility) => {
      return {
        name: facility.name,
        sites: facility.sites?.splice(0, 3),
      } as Facility;
    });
    this.mapUtil.drawHousePoint(title);
    return preview;
  }

  getPoiListByText(poiText: string, latitude: number, longitude: number, radius?: number) {
    let params: site.SearchByTextParams = {
      query: poiText,
      location: {
        latitude: latitude,
        longitude: longitude,
      },
      radius: radius,
      language: 'zh_CN',
    };
    return site.searchByText(params);
  }

  calDistance(options: mapCommon.MapOptions, toLatLng: mapCommon.LatLng) {
    let fromLatLng: mapCommon.LatLng = {
      latitude: options?.position.target.latitude ?? AppStorageBank.getCurrentLocation()[0],
      longitude: options?.position.target.longitude ?? AppStorageBank.getCurrentLocation()[1],
    };
    return map.calculateDistance(fromLatLng, toLatLng);
  }
}