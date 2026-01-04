import { geoLocationManager } from '@kit.LocationKit';
import { map, mapCommon } from '@kit.MapKit';
import { MapDetailCommonConstants } from '../components/MapDetailCommonConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = '[LocationUtils]';

/**
 * 应用市场utils
 */
export class LocationUtils {
  /**
   * 是否有更新版本
   * @param context
   * @returns
   */
  public static async getGCJ02CurrentLocation(): Promise<mapCommon.LatLng> {
    try {
      const request: geoLocationManager.SingleLocationRequest = {
        locatingPriority: MapDetailCommonConstants.PRIORITY_LOCATING_SPEED,
        locatingTimeoutMs: MapDetailCommonConstants.LOCATING_TIMEOUT_MS
      };
      const location: geoLocationManager.Location = await geoLocationManager.getCurrentLocation(request)
      let wgs84Position: mapCommon.LatLng = {
        latitude: location.latitude,
        longitude: location.longitude
      };
      // 转换经纬度坐标
      let gcj02Position: mapCommon.LatLng =
        map.convertCoordinateSync(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, wgs84Position);
      return gcj02Position;
    } catch (err) {
      let wgs84Position: mapCommon.LatLng = {
        latitude: 0,
        longitude: 0
      };
      hilog.error(0x0000, 'LocationUtils', `Failed to get GCJ02 Current Location, code: ${err.code}, message: ${err.message}`);
      return wgs84Position;
    }
  }

  /**
   * 是否有更新版本
   * @param context
   * @returns
   */
  public static convertGCJ02TOWGS84(latlng: mapCommon.LatLng): mapCommon.LatLng {
    // 转换经纬度坐标
    const lng = latlng.longitude
    const lat = latlng.latitude
    if (LocationUtils.outOfChina(lng, lat)) {
      return { latitude: lat, longitude: lng }
    }
    let dlat = LocationUtils.transformLat(lng - 105.0, lat - 35.0);
    let dlng = LocationUtils.transformLng(lng - 105.0, lat - 35.0);
    let radlat = lat / 180.0 * Math.PI;
    let magic = Math.sin(radlat);
    magic = 1 - 0.00669342162296594323 * magic * magic;
    let sqrtmagic = Math.sqrt(magic);
    dlat = (dlat * 180.0) / ((6378245.0 * (1 - 0.00669342162296594323)) / (magic * sqrtmagic) * Math.PI);
    dlng = (dlng * 180.0) / (6378245.0 / sqrtmagic * Math.cos(radlat) * Math.PI);
    let mglat = lat + dlat;
    let mglng = lng + dlng;

    return { latitude: lat * 2 - mglat, longitude: lng * 2 - mglng }
  }

  public static outOfChina(lng: number, lat: number): boolean {
    if (lng < 72.004 || lng > 137.8347) {
      return true;
    }
    if (lat < 0.8293 || lat > 55.8271) {
      return true;
    }
    return false;
  }

  public static transformLat(lng: number, lat: number): number {
    let ret = -100.0 + 2.0 * lng + 3.0 * lat + 0.2 * lat * lat + 0.1 * lng * lat + 0.2 * Math.sqrt(Math.abs(lng));
    ret += (20.0 * Math.sin(6.0 * lng * Math.PI) + 20.0 * Math.sin(2.0 * lng * Math.PI)) * 2.0 / 3.0;
    ret += (20.0 * Math.sin(lat * Math.PI) + 40.0 * Math.sin(lat / 3.0 * Math.PI)) * 2.0 / 3.0;
    ret += (160.0 * Math.sin(lat / 12.0 * Math.PI) + 320 * Math.sin(lat * Math.PI / 30.0)) * 2.0 / 3.0;
    return ret;
  }

  public static transformLng(lng: number, lat: number): number {
    let ret = 300.0 + lng + 2.0 * lat + 0.1 * lng * lng + 0.1 * lng * lat + 0.1 * Math.sqrt(Math.abs(lng));
    ret += (20.0 * Math.sin(6.0 * lng * Math.PI) + 20.0 * Math.sin(2.0 * lng * Math.PI)) * 2.0 / 3.0;
    ret += (20.0 * Math.sin(lng * Math.PI) + 40.0 * Math.sin(lng / 3.0 * Math.PI)) * 2.0 / 3.0;
    ret += (150.0 * Math.sin(lng / 12.0 * Math.PI) + 300.0 * Math.sin(lng / 30.0 * Math.PI)) * 2.0 / 3.0;
    return ret;
  }
}