import { window } from '@kit.ArkUI';
import { harmonyShare } from '@kit.ShareKit';
import { Logger } from 'lib_common';
import { SharePicker, ShareRecordData } from 'module_share';

const TAG = '[ShareUtils]';

/**
 * 分享工具类
 */
export class ShareUtils {
  /**
   * 直接分享到微信
   * @param uiContext
   */
  public shareToWX(uiContext: UIContext, shareData: ShareRecordData) {
    const picker = new SharePicker(shareData);
    picker.shareToWX(uiContext);
  }

  /**
   * 注册隔空传送的事件监听
   * @param context
   * @param callback
   */
  public registerGestureShareListener(context: Context, callback: Callback<harmonyShare.SharableTarget>) {
    if (canIUse('SystemCapability.Collaboration.HarmonyShare')) {
      window.getLastWindow(context).then((data) => {
        try {
          const mainWindowID: number = data.getWindowProperties().id;
          harmonyShare.on('gesturesShare', { windowId: mainWindowID }, (target: harmonyShare.SharableTarget) => {
            callback(target);
          });
        } catch (error) {
          Logger.error(TAG, `getWindowProperties error: ${error.code} ${error.message}`);
        }
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `registerGestureShareListener getLastWindow error: ${error.code} ${error.message}`);
      })
    }
  }

  /**
   * 取消注册隔空传送的事件监听
   * @param context
   * @param callback
   */
  public unRegisterGestureShareListener(context: Context, callback: Callback<harmonyShare.SharableTarget>) {
    if (canIUse('SystemCapability.Collaboration.HarmonyShare')) {
      window.getLastWindow(context).then((data) => {
        try {
          const mainWindowID: number = data.getWindowProperties().id;
          harmonyShare.off('gesturesShare', { windowId: mainWindowID }, callback);
        } catch (error) {
          Logger.error(TAG, `getWindowProperties error ${error.code} ${error.message}`);
        }
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `unRegisterGestureShareListener getLastWindow error ${error.code} ${error.message}`);
      })
    }
  }
}
