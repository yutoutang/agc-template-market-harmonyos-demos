import { Permissions } from '@kit.AbilityKit';
import { map, mapCommon, site } from '@kit.MapKit';
import { PermissionUtil } from './PermissionUtil';
import { geoLocationManager } from '@kit.LocationKit';

const TAG: string = '[LocationUtil]';

export interface AddressParam {
  addressName?: string | undefined,
  latitude: number ,
  longitude: number
}

export class LocationUtil {
  public static async getLocationName(): Promise<AddressParam> {
    const permissions: Permissions[] = ['ohos.permission.APPROXIMATELY_LOCATION', 'ohos.permission.LOCATION'];
    let addressName: string | undefined;
    const allowGetPosition = await PermissionUtil.requestPermissions(permissions);
    const addressParam:AddressParam = {
      latitude:0,
      longitude:0
    }
    if (allowGetPosition) {
      let request: geoLocationManager.SingleLocationRequest = {
        'locatingPriority': geoLocationManager.LocatingPriority.PRIORITY_LOCATING_SPEED,
        'locatingTimeoutMs': 10000
      }
      const location = await geoLocationManager.getCurrentLocation(request);
      if (location) {
        let wgs84Position: mapCommon.LatLng = {
          latitude: location.latitude,
          longitude: location.longitude
        }
        try {
          let gcj02Position: mapCommon.LatLng =
            map.convertCoordinateSync(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, wgs84Position);
          const res = await site.nearbySearch({
            location: gcj02Position,
            language: 'zh',
            radius: 100
          });
          if (res && res.sites) {
            addressName = res.sites[0].name;
          }
        } catch (err) {
          console.error(TAG, `'get address failed with err: ${JSON.stringify(err)}`);
        }
        addressParam.addressName = addressName;
        addressParam.latitude = location.latitude;
        addressParam.longitude = location.longitude;
      }
    }


    return addressParam;
  }

  public static  calculateDistance(lat1:number, lon1:number, lat2:number, lon2:number):number {
    let fromLatLng: mapCommon.LatLng = {
      latitude: lat1,   // 起点纬度
      longitude: lon1   // 起点经度
    };
    let toLatLng: mapCommon.LatLng = {
      latitude: lat2,    // 终点纬度
      longitude: lon2    // 终点经度
    };
    return map.calculateDistance(fromLatLng, toLatLng);  // 单位：米
  }

}