import { call } from '@kit.TelephonyKit';
import { promptAction } from '@kit.ArkUI';
import { site } from '@kit.MapKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { abilityAccessCtrl, bundleManager, common, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { CurrentAddressInfo } from '../model/Index';
import { IBasicHouse } from '../model/IResponse';
import { HouseType } from '../constants/Enum';
import { RouterModule } from '../router/RouterModule';
import { AppStorageBank } from './AppStorageBank';
import { Logger } from './Logger';

/**
 * 通用Utils
 */
export class CommonUtils {
  /**
   * 一键登录
   */
  static login() {
    RouterModule.stack.pushPathByName('QuickLoginPage', null, (popInfo: ESObject) => {
      let nickName = AppStorageBank.getUserInfo().nickName;
      let avatar = AppStorageBank.getUserInfo().avatar;
      AppStorageBank.setUserInfo(nickName.length ? nickName : '华为用户',
        avatar.toString().length ? avatar : $r('app.media.avatar'), popInfo.result.phone,
        popInfo.result.uid);
    });
  }

  /**
   * 获取当前日期
   * @returns
   */
  static getDate() {
    return `${new Date().getFullYear()}-${(new Date().getMonth() + 1).toString()
      .padStart(2, '0')}-${(new Date().getDate()).toString().padStart(2, '0')}`;
  }

  /**
   * 获取房屋面积
   * @param house
   * @returns
   */
  static getHouseSpace(house: IBasicHouse) {
    let space: string = `${house.space[0]}`;
    if (house.type === HouseType.NEW) {
      space = `${house.space[0]}~${house.space[1]}`;
    }
    return space;
  }

  /**
   * 月份及日期补零
   * @param url
   * @returns
   */
  static padZero = (input: number) => {
    return input.toString().padStart(2, '0');
  };

  /**
   * 处理图片url
   * @param url
   * @returns
   */
  static handleImgUrl(url: string, context: Context): string {
    if (!url) {
      return '';
    }
    if (url.startsWith('https')) {
      return url;
    }

    // 处理mock图片资源
    if (url.startsWith('mockImage://')) {
      const resourceName = url.split('mockImage://')[1];
      const prefixUrl: string = '';
      return `${prefixUrl}${resourceName}`;
    }
    // resources下的资源通过resourceImage://xxx表达
    if (url.startsWith('resourceImage://')) {
      const resourceName = url.split('//')[1];
      try {
        const resource = context.resourceManager.getMediaBase64ByNameSync(resourceName);
        return resource;
      } catch (err) {
        Logger.error(`get image resource failed, ${err}, ${resourceName}`);
        return '';
      }
    }

    return url;
  };
}

/**
 * 系统Utils
 */
export class SystemUtils {
  static isApplyLocPermAgain: boolean = false;
  static context: Context;

  /**
   * 系统拨号
   * @param phoneNo
   * @returns
   */
  static consult(phoneNo: string) {
    call.makeCall(phoneNo, (err) => {
      if (err) {
        Logger.error('make call failed');
      } else {
        Logger.info('make call success');
      }
    });
  }

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
      Logger.info('reverseGeocodeResult=' + JSON.stringify(reverseGeocodeResult));
      return {
        city: reverseGeocodeResult.addressComponent.city?.cityName ?? '',
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
      };
    } catch (e) {
      Logger.error('getCurrentCityInfo fail, error: ' + JSON.stringify(e));
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
    SystemUtils.context = context;
    const permissions: Permissions[] = [
      'ohos.permission.APPROXIMATELY_LOCATION',
    ];

    const isGrantedAppLo = await SystemUtils.checkPermissionGrant(permissions[0]);

    if (isGrantedAppLo) {
      Logger.info('already granted location and approximate location permissions');
      return true;
    }
    // 向用户申请
    const atManager = abilityAccessCtrl.createAtManager();
    return atManager.requestPermissionsFromUser(SystemUtils.context, permissions)
      .then(async (result: PermissionRequestResult) => {
        if (result.authResults.every(v => v === 0)) {
          return true;
        }
        // 二次向用户申请
        if (SystemUtils.isApplyLocPermAgain) {
          const resp = await atManager.requestPermissionOnSetting(SystemUtils.context, permissions);
          return resp.every(v => v === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED);
        }
        SystemUtils.isApplyLocPermAgain = true;
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
      Logger.error(`Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }

    // 校验应用是否被授予权限
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }

    return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  }
}
