import { window } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';

export class Utils {
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
}