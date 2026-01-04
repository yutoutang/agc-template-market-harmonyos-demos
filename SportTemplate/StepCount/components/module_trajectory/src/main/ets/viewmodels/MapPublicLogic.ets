import { map, site } from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class MapPublicLogic {
  public static async getPoi(latitude: number, longitude: number): Promise<string> {
    let params: site.NearbySearchParams = {
      location: {
        latitude: latitude,
        longitude: longitude
      },
      poiTypes: [
        'Watch_Store',
        'SUBWAY',
        'PRIMARY_SCHOOL',
        'GENERAL_AUTO_REPAIR_SERVICE_CENTER'
      ]
    }
    // 返回周边搜索结果
    try {
      const result: site.NearbySearchResult = await site.nearbySearch(params);
      let address: string = result.sites ? result.sites[0].formatAddress ?? '' : ''
      return address
    } catch (error) {
      hilog.error(0x0000, 'MapPublicLogic', 'nearbySearch error');
      return ''
    }
  }

  public static async distanceBetween(latitude: number, longitude: number): Promise<number> {
    try {
      let location = await geoLocationManager.getCurrentLocation();
      return map.calculateDistance(location, { latitude: latitude, longitude: longitude });
    } catch (error) {
      return 0;
    }
  }
}