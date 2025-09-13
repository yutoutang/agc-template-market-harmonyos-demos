import fs from '@ohos.file.fs';
import { abilityAccessCtrl, PermissionRequestResult, Permissions, bundleManager, common, Want } from '@kit.AbilityKit';
import { map, mapCommon } from '@kit.MapKit';
import { geoLocationManager } from '@kit.LocationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { Logger } from './Logger';

const TAG = '[SystemSceneUtils]';

/**
 * 系统Utils
 */
export class SystemSceneUtils {
  /**
   * 跳转到华为地图
   * @param address
   * @param coords
   */
  public static async jumpPetalMap(context: common.UIAbilityContext, address: string, coords: string[]) {
    if (coords.length < 2) {
      return;
    }
    const bundleInfo = await SystemSceneUtils.getBundleInfo();
    let petalMapWant: Want = {
      bundleName: 'com.huawei.hmos.maps.app',
      uri: 'maps://routes',
      parameters: {
        // 接入方业务名或包名，Link请求来源
        linkSource: bundleInfo.name,
        // 终点纬度
        destinationLatitude: coords[1],
        // 终点经度
        destinationLongitude: coords[0],
        // 终点名称
        destinationName: address,
      },
    }

    context?.startAbility(petalMapWant);
  }

  /**
   * 计算距离
   * @param coords 经度.纬度
   * @returns
   */
  public static async getDistance(coordsStr: string) {
    let requestInfo: geoLocationManager.CurrentLocationRequest = {
      priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
      timeoutMs: 1000,
    };
    try {
      const fromLocation = await geoLocationManager.getCurrentLocation(requestInfo);
      let fromLatLng: mapCommon.LatLng = {
        latitude: fromLocation.latitude,
        longitude: fromLocation.longitude,
      };
      Logger.info(TAG, 'fromLocation = [' + fromLocation.latitude + ', ' + fromLocation.longitude + ']');

      const coords = coordsStr.split(',');
      let toLatLng: mapCommon.LatLng = {
        longitude: Number(coords[0]),
        latitude: Number(coords[1]),
      };
      Logger.info(TAG, 'toLatLng = [' + toLatLng.latitude + ', ' + toLatLng.longitude + ']');

      const distance = map.calculateDistance(fromLatLng, toLatLng);
      Logger.info(TAG, 'distance=' + distance);

      if (isNaN(distance)) {
        return '0m';
      }
      if (distance < 1000) {
        return `${distance}m`;
      } else {
        return `${(distance / 1000).toFixed(1)}km`;
      }
    } catch (err) {
      Logger.error(TAG, 'getDistance errCode:' + (err as BusinessError).code + ',errMessage:' +
      (err as BusinessError).message);
      return '0m';
    }
  }

  /**
   * 向用户申请位置权限
   * @returns
   */
  public static async applyLocationPermission(): Promise<boolean> {
    const permissions: Permissions[] = [
      'ohos.permission.LOCATION',
      'ohos.permission.APPROXIMATELY_LOCATION',
    ];

    const isGrantedLo = await SystemSceneUtils.checkPermissionGrant(permissions[0]);
    const isGrantedAppLo = await SystemSceneUtils.checkPermissionGrant(permissions[1]);

    if (isGrantedLo && isGrantedAppLo) {
      Logger.info(TAG, 'already granted location and approximate location permissions')
      return true;
    }

    const atManager = abilityAccessCtrl.createAtManager();
    return atManager.requestPermissionsFromUser(getContext(), permissions).then((result: PermissionRequestResult) => {
      if (result.authResults.every(v => v === 0)) {
        return true;
      }
      return false;
    });
  }

  /**
   * 检查用户是否授权
   * @param permission
   * @returns
   */
  public static async checkPermissionGrant(permission: Permissions): Promise<boolean> {
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
      Logger.error(TAG, `Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }

    // 校验应用是否被授予权限
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }

    return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  }

  /**
   * 写入沙箱
   * @param uri
   * @returns
   */
  public static handleUri(uri: string) {
    if (!uri) {
      return '';
    }
    let file: fs.File | null = null;
    try {
      file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      const newPath: string = getContext().filesDir + `/${util.generateRandomUUID(false)}.png`;
      fs.copyFileSync(file.fd, newPath);
      return 'file://' + newPath;
    } catch (error) {
      Logger.error(TAG, 'fs.copyFileSync error: ' + JSON.stringify(error));
      return '';
    } finally {
      if (file) {
        fs.closeSync(file);
      }
    }
  }

  /**
   * 获取包信息
   * @returns
   */
  public static async getBundleInfo() {
    const bundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
    return bundleInfo;
  }
}