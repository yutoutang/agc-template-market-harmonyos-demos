import { geoLocationManager } from '@kit.LocationKit';
import { map, mapCommon } from '@kit.MapKit';
import { Logger } from './Logger';

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
      const location: geoLocationManager.Location = await geoLocationManager.getCurrentLocation()
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
      Logger.error(TAG, `Failed to get GCJ02 Current Location, code: ${err.code}, message: ${err.message}`);
      return wgs84Position;
    }
  }
}