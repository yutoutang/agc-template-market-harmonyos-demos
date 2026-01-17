import { display, window } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import * as AudioSubWindow from '../components/AudioSubWindowPlayer';
import { AudioConstants } from '../constants/Constants';
import { MediaViewModel } from '../viewmodel/MediaViewModel';

const TAG = '[MediaTools]';

export class MediaTools {
  /**
   * 创建子窗口
   * @param uiContext
   * @param isNotCreate 默认不创建子窗口
   */
  static async createSubWindow(uiContext: UIContext, isNotCreate = true) {
    const windowStage = MediaViewModel.windowStage!
    let hasSubWindow: boolean = await MediaTools.getSubWindow()
    if ((!MediaViewModel.getInstance().isPlaying || hasSubWindow) && isNotCreate) {
      return
    }
    windowStage.createSubWindow(AudioConstants.AUDIO_SUB_NAME, async (err, windowClass) => {
      if (err.code > 0) {
        return;
      }
      try {
        // 设置子窗口加载页
        windowClass.loadContentByName(AudioSubWindow.entryName, () => {
          windowClass.setWindowBackgroundColor('#00000000');
        });
        await windowClass.moveWindowTo(uiContext.vp2px(16),
          display.getDefaultDisplaySync().height - uiContext.vp2px(200));
        await windowClass.resize(uiContext.vp2px(AudioConstants.SUB_WIN_STATE_0_WIDTH),
          uiContext.vp2px(AudioConstants.SUB_WIN_HEIGHT));
        await windowClass.showWindow();
        emitter.on('destroy_sub_window',() => {
          MediaTools.destroySubWindow(AudioConstants.AUDIO_SUB_NAME)
        })
      } catch (err) {
        UtilLog.error(TAG, `failed to create subWindow Cause:${err}`);
      }
    })
  }

  /**
   * 获取子窗口
   */

  static async getSubWindow() {
    try {
      const windowStage = MediaViewModel.windowStage!
      let windowClass = await windowStage.getSubWindow();
      let windowNameList = windowClass.map(item => item.getWindowProperties().name)
      return windowNameList.includes(AudioConstants.AUDIO_SUB_NAME)
    } catch (e) {
      UtilLog.error(TAG, `failed to getSubWindow Cause:${e}`);
      return false;
    }
  }

  /**
   * 聚焦到主窗口
   * @param windowStage 窗口管理器
   * @param windowName 子窗口名
   */
  static changeFocus(windowStage: window.WindowStage, windowName: string) {
    setTimeout(async () => {
      try {
        // 获取子窗口ID
        let subWindowID: number = window.findWindow(windowName).getWindowProperties().id;
        // 获取主窗口ID
        let mainWindowID: number = windowStage.getMainWindowSync().getWindowProperties().id;
        // 将焦点从子窗口转移到主窗口
        await window.shiftAppWindowFocus(subWindowID, mainWindowID);
      } catch (e) {
        UtilLog.info('subwindow error' + `${e}`)
      }
    }, 500);
  }

  /**
   * 销毁子窗口
   * @param windowName 子窗口名
   */
  static async destroySubWindow(windowName: string) {
    try {
      let hasSubWindow = await MediaTools.getSubWindow()
      if (hasSubWindow) {
        emitter.off('destroy_sub_window')
        await window.findWindow(windowName).destroyWindow()
      }
    } catch (e) {
      UtilLog.info('destroySubWindow error' + `${e}`)
    }
  }

  static async pause() {
    MediaViewModel.getInstance().pause()
  }

  static async createSession() {
    MediaViewModel.getInstance().createSession()
  }
}