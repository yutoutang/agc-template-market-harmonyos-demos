import { MediaTools } from './MediaTools';

export class SubUtils {
  /**
   * 销毁子窗口
   * @param windowName 子窗口名
   */
  public static destroySubWindow(windowName: string) {
    MediaTools.destroySubWindow(windowName)
  }

  public static async createSession() {
    await MediaTools.createSession()
  }


  /**
   * 创建子窗口
   * @param uiContext
   * @param isNotCreate 默认不创建子窗口
   */
  public static createSubWindow(uiContext: UIContext, isNotCreate = true) {
    MediaTools.createSubWindow(uiContext, isNotCreate)
  }

}