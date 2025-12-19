import { geoLocationManager } from '@kit.LocationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { abilityAccessCtrl, bundleManager, common, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { CurrentAddressInfo } from './AppStorageBank';
import { site } from '@kit.MapKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 系统Utils
 */
export class SystemUtil {
  static isApplyLocPermAgain: boolean = false;
  static context: Context;

  /**
   * 获取当前所在城市位置
   * @returns
   */
  static async getCurrentCityInfo(): Promise<CurrentAddressInfo> {
    try {
      const requestInfo: geoLocationManager.CurrentLocationRequest = {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        timeoutMs: 1000,
      };
      const currentLocation = await geoLocationManager.getCurrentLocation(requestInfo);

      const reverseGeoCodeReq: site.ReverseGeocodeParams = {
        location: currentLocation,
        language: 'zh_CN',
      };
      const reverseGeocodeResult = await site.reverseGeocode(reverseGeoCodeReq);
      hilog.info(0xff00, 'SystemUtil', 'reverseGeocodeResult =' + JSON.stringify(reverseGeocodeResult));
      return {
        city: reverseGeocodeResult.addressComponent.city?.cityName ?? '',
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
      };
    } catch (e) {
      hilog.info(0xff00, 'SystemUtil', 'getCurrentCityInfo fail, error msg: ' + JSON.stringify(e));
      return {
        city: '',
        latitude: 0,
        longitude: 0,
      };
      ;
    }
  }

  /**
   * 向用户申请位置权限
   * @returns
   */
  static async applyLocationPermission(context: Context): Promise<boolean> {
    SystemUtil.context = context as common.UIAbilityContext
    const permissions: Permissions[] = [
      'ohos.permission.APPROXIMATELY_LOCATION',
    ];

    const isGrantedAppLo = await SystemUtil.checkPermissionGrant(permissions[0]);

    if (isGrantedAppLo) {
      hilog.info(0xff00, 'SystemUtil', 'already granted location and approximate location permission');
      return true;
    }
    // 向用户申请
    const atManager = abilityAccessCtrl.createAtManager();
    return atManager.requestPermissionsFromUser(SystemUtil.context, permissions)
      .then(async (result: PermissionRequestResult) => {
        if (result.authResults.every(v => v === 0)) {
          return true;
        }
        // 二次向用户申请
        if (SystemUtil.isApplyLocPermAgain) {
          const resp = await atManager.requestPermissionOnSetting(SystemUtil.context, permissions);
          return resp.every(v => v === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED);
        }
        SystemUtil.isApplyLocPermAgain = true;
        return false;
      });
  }

  /**
   * 检查用户是否授权
   * @param permission
   * @returns
   */
  static async checkPermissionGrant(permission: Permissions): Promise<boolean> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

    // 获取应用程序的accessTokenID
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      tokenId = bundleInfo.appInfo.accessTokenId;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.info(0xff00, 'SystemUtil',
        `Failed to get bundle info for self. Code is ${err.code}, msg is ${err.message}`);
    }

    // 校验应用是否被授予权限
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.info(0xff00, 'SystemUtil', `Failed to check access token. Code is ${err.code}, msg is ${err.message}`);
    }

    return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  }
}