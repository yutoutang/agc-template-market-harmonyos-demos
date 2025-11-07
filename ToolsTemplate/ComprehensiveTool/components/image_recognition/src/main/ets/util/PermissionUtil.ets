import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { MyLog } from './MyLogUtil';
import { PermissionStatus } from '../model/Index';


export class PermissionUtil {
  private static _atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  private static _context: Context;

  // 申请权限
  public static async requestPermissions(permissions: Permissions[]) {
    const needAuthorized: Permissions[] = [];
    let permissive = true;
    for (let permission of permissions) {
      const isGranted: boolean = await PermissionUtil._checkPermissions(permission);
      if (!isGranted) {
        needAuthorized.push(permission);
      }
    }
    if (!needAuthorized.length) {
      return permissive;
    }
    if (!PermissionUtil._context) {
      PermissionUtil._context = getContext() as common.UIAbilityContext;
    }
    // 向用户申请授权
    const data = await PermissionUtil._atManager.requestPermissionsFromUser(PermissionUtil._context, needAuthorized);
    let grantStatus: number[] = data.authResults;
    let length: number = grantStatus.length;

    const needAuthorizedAgain: Permissions[] = [];
    for (let i = 0; i < length; i++) {
      if (grantStatus[i] === PermissionStatus.GRANTED) {
        MyLog.info('request permission success' + needAuthorized[i]);
      } else if (grantStatus[i] === PermissionStatus.DENIED) {
        needAuthorizedAgain.push(needAuthorized[i]);
      } else {
        permissive = false;
      }
    }

    PermissionUtil._requestPermissionsOnSetting(needAuthorizedAgain);
    return permissive;
  }

  // 用户首次拒绝后二次申请授权
  private static async _requestPermissionsOnSetting(permissions: Permissions[]) {
    PermissionUtil._atManager.requestPermissionOnSetting(PermissionUtil._context, permissions);
  }

  // 检查是否拥有权限
  public  static async _checkPermissions(permission: Permissions): Promise<boolean> {
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
      const bundleInfo: bundleManager.BundleInfo =
        bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      if (appInfo) {
        tokenId = appInfo.accessTokenId;
      }
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      MyLog.error(`Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }
    try {
      grantStatus = await PermissionUtil._atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      MyLog.error(`Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }
    return grantStatus;
  }
}