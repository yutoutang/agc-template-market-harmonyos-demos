import { serviceNotification } from '@kit.PushKit';
import { abilityAccessCtrl, PermissionRequestResult, Permissions, bundleManager } from '@kit.AbilityKit';
import { calendarManager } from '@kit.CalendarKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = '[SystemSceneUtils]';
const FORMAT = '%{public}s';

/**
 * 系统Utils
 */
export class SystemSceneUtils {
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
      hilog.error(DOMAIN, TAG, FORMAT,
        `Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }

    // 校验应用是否被授予权限
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(DOMAIN, TAG, FORMAT, `Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }

    return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  }

  /**
   * 根据上下文获取日程管理器对象calendarMgr，用于对日历账户进行相关管理操作
   * @returns
   */
  public static async getCalendarMgr() {
    const permissions: Permissions[] = [
      'ohos.permission.READ_CALENDAR',
      'ohos.permission.WRITE_CALENDAR',
    ];
    const mContext = getContext();

    const isGrantedRead = await SystemSceneUtils.checkPermissionGrant(permissions[0]);
    const isGrantedWrite = await SystemSceneUtils.checkPermissionGrant(permissions[1]);

    if (isGrantedRead && isGrantedWrite) {
      hilog.info(DOMAIN, TAG, FORMAT, 'already granted calendar permission')
      return calendarManager.getCalendarManager(mContext);
    }

    const atManager = abilityAccessCtrl.createAtManager();

    return atManager.requestPermissionsFromUser(mContext, permissions).then(async (result: PermissionRequestResult) => {
      hilog.info(DOMAIN, TAG, FORMAT, `get Permission success, result: ${JSON.stringify(result)}`);
      if (result.authResults.every(v => v === 0)) {
        return calendarManager.getCalendarManager(mContext);
      }
      // 首次拒绝后，二次弹窗申请
      if (result.dialogShownResults?.some(v => !v)) {
        const arr: Array<abilityAccessCtrl.GrantStatus> =
          await atManager.requestPermissionOnSetting(mContext, permissions);
        if (arr.every(v => v === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)) {
          return calendarManager.getCalendarManager(mContext);
        }
        return null;
      }

      return null;
    })
  }

  /**
   * 发起订阅请求
   * @returns
   */
  public static async requestSubscribeNotification(entityIdStr: string):
    Promise<serviceNotification.RequestResult | null> {
    try {
      const entityIds: string[] = entityIdStr.split(',');
      const type: serviceNotification.SubscribeNotificationType =
        serviceNotification.SubscribeNotificationType.SUBSCRIBE_WITH_HUAWEI_ID;
      const res = await serviceNotification.requestSubscribeNotification(getContext(), entityIds, type);
      hilog.info(DOMAIN, TAG, FORMAT, 'Succeeded in requesting serviceNotification: %{public}s' + JSON.stringify(res));
      return res!;
    } catch (err) {
      hilog.error(DOMAIN, TAG, FORMAT,
        'Failed to request serviceNotification: ' + JSON.stringify(err as BusinessError));
      return null;
    }
  }
}