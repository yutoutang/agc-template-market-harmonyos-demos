import { common } from '@kit.AbilityKit';
import { avSession } from '@kit.AVSessionKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { MediaTools } from './utils/MediaTools';
import { BackgroundUtils } from './utils/BackgroundUtils';

const TAG = '[AudioService]';

/**
 * 音频服务类
 */
export class AudioService {
  /**
   * 创建子窗口
   * @param uiContext
   * @param isNotCreate 默认不创建子窗口
   */
  public static createSubWindow(uiContext: UIContext, isNotCreate = true) {
    MediaTools.createSubWindow(uiContext, isNotCreate)
  }

  /**
   * 销毁子窗口
   * @param windowName 子窗口名
   */
  public static destroySubWindow(windowName: string) {
    MediaTools.destroySubWindow(windowName)
  }

  /**
   * 创建session
   */
  public static async createSession() {
    await MediaTools.createSession()
  }

  /**
   * 释放session
   */
  public static async destroySession(context: common.UIAbilityContext) {
    const avSession: avSession.AVSession = AppStorage.get('avSession') as avSession.AVSession
    if (avSession) {
      try {
        await avSession.destroy();
        AppStorage.setOrCreate('avSession', '');
        BackgroundUtils.stopContinuousTask(context);
      } catch (e) {
        UtilLog.error(TAG, `avSession.destroy fail. Code: ${e.code}, message: ${e.message}`);
      }
    }
  }
}