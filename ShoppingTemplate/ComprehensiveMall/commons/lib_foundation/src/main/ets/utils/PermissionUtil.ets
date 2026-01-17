import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { notificationManager } from '@kit.NotificationKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { WindowUtil } from './WindowUtil';

const TAG: string = '[PermissionUtil]';

export class PermissionUtil {
  /**
   * 获取推送授权
   */
  public static requestNotificationPermission(callback?:()=>void) {
    if (!WindowUtil.globalContext) {
      Logger.error(TAG, 'cannot get context')
      return;
    }
    notificationManager.isNotificationEnabled().then((data: boolean) => {
      Logger.info(TAG, 'isNotificationEnabled success, data: ' + JSON.stringify(data));
      callback?.()
      if (!data) {
        notificationManager.requestEnableNotification(WindowUtil.globalContext as common.UIAbilityContext).then(() => {
          Logger.info(TAG, `requestEnableNotification success`);
          callback?.()
        }).catch((err: BusinessError) => {
          if (1600004 === err.code) {
            Logger.error(TAG,
              `requestEnableNotification refused, code is ${err.code}, message is ${err.message}`);
          } else {
            Logger.error(TAG, `requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
          }
        });
      }
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `isNotificationEnabled fail, code is ${err.code}, message is ${err.message}`);
    });
  }
}
