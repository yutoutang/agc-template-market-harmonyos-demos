import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import { bundleManager, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class PermissionUtils {
  static async checkPermission(permission: Permissions): Promise<boolean> {
    let result: boolean = true;
    let permissionCheck = await PermissionUtils.checkPermissions(permission)
    if (!permissionCheck) {
      let requestResult = await PermissionUtils.reqPermissionsFromUser([permission])
      return requestResult.some(item => item !== 0)
    }
    return result;
  }

  static async checkPermissionsList(permissions: Permissions[]): Promise<boolean> {
    for (let per of permissions) {
      const grant = await PermissionUtils.checkPermissions(per)
      if (!grant) {
        return false
      }
    }
    return true
  }

  /**
   * 判断是否授权
   * @param permissions  待判断的权限
   * @returns 已授权true,未授权false
   */
  static async checkPermissions(permissions: Permissions): Promise<boolean> {
    //判断是否授权
    let grantStatus: abilityAccessCtrl.GrantStatus = await PermissionUtils.checkAccessToken(permissions);
    if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      //已经授权
      return true;
    } else {
      //未授权
      return false;
    }
  }

  /**
   * 发起授权
   * @param permissions  需要授权的权限
   * @param callBack  授权成功后的回调,1为用户同意授权，-1为用户拒绝授权
   * @returns
   */
  static async reqPermissionsFromUser(permissions: Permissions[]): Promise<number[]> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
    try {
      let request = await atManager.requestPermissionsFromUser(getContext() as common.UIAbilityContext, permissions);
      return request.authResults
    } catch (e) {
      return permissions.map(item => 2)
    }
  }

  /**
   * 发起授权 以Promise方式返回
   * @param permissions 需要授权的权限
   * @returns 1表示授权成功继续业务操作,-1表示用户拒绝授权
   */
  static async reqPermissions(permissions: Permissions): Promise<number> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
    let request = await atManager.requestPermissionsFromUser(getContext() as common.UIAbilityContext, [permissions]);
    let grantStatus: number[] = request.authResults;
    let length: number = grantStatus.length;
    for (let i = 0; i < length; i++) {
      if (grantStatus[i] === 0) {
        // 用户授权，可以继续访问目标操作
        return 1;
      } else {
        // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
        return -1;
      }
    }
    return -1;
  }

  /**
   * 检查是否授权
   * @param permission 待检查权限
   * @returns 授权状态
   */
  static async checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;
    // 获取应用程序的accessTokenID
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
    }
    // 校验应用是否被授予权限
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
    }

    return grantStatus;
  }

  /**
   * 批量检查权限并判断是否需要显示弹窗
   * @param permissions
   * @returns [0] true:已申请到权限  [1] true:需要二次弹窗引导获取权限
   */
  static async checkPermissionAndNeedShowDialog(permissions: Permissions[]) {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
    try {
      const requestResult =
        await atManager.requestPermissionsFromUser(getContext() as common.UIAbilityContext, permissions);
      const hasPermissions = requestResult.authResults.some(item => item !== 0)
      if (!hasPermissions) {
        return [true, false]
      }
      const showDialog = requestResult.dialogShownResults?.some(item => !(item ?? true)) ?? true
      return [false, showDialog]
    } catch (e) {
    }
    return [false, false]
  }
}