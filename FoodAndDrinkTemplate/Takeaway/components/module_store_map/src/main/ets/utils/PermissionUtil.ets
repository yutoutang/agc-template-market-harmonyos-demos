import { abilityAccessCtrl, bundleManager, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from 'module_ui_base';
import { WindowUtil } from './WindowUtil';

const TAG: string = '[PermissionUtil]';

enum PermissionStatus {
  GRANTED = 0,
  DENIED = -1,
  UNKNOWN = 2,
}

export class PermissionUtil {
  private static _atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();

  public static async requestPermissions(permissions: Permissions[]) {
    const needAuthorized: Permissions[] = [];
    for (let permission of permissions) {
      const isGranted: boolean = await PermissionUtil._checkPermissions(permission);
      if (!isGranted) {
        needAuthorized.push(permission);
      }
    }
    if (!needAuthorized.length) {
      return Promise.resolve(true);
    }
    const context = WindowUtil.context;
    if (!context) {
      Logger.error(TAG, 'get context failed.');
      return Promise.reject();
    }
    // 向用户申请授权
    return await PermissionUtil._atManager.requestPermissionsFromUser(context, needAuthorized)
      .then((data) => {
        let grantStatus: number[] = data.authResults;
        let length: number = grantStatus.length;
        let permissive = true;
        for (let i = 0; i < length; i++) {
          if (grantStatus[i] === PermissionStatus.GRANTED) {
            Logger.info(TAG, 'request permission success::' + needAuthorized[i]);
            break;
          } else {
            permissive = false;
            Logger.info(TAG, 'request permission failed:: user denied');
            break;
          }
        }
        if (permissive) {
          return Promise.resolve(true);
        }
        return Promise.reject();
      })
      .catch((err: BusinessError) => {
        Logger.error(TAG, `Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
      });
  }

  private static async _checkPermissions(permission: Permissions): Promise<boolean> {
    let grantStatus: abilityAccessCtrl.GrantStatus = await PermissionUtil._checkAccessToken(permission);
    if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      return true;
    }
    return false;
  }

  // 校验应用是否被授予权限
  private static async _checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }
    try {
      grantStatus = await PermissionUtil._atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }
    return grantStatus;
  }
}