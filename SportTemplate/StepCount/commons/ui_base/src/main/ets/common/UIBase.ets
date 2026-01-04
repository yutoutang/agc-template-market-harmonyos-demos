import { window } from '@kit.ArkUI';
import { Callback } from '@kit.BasicServicesKit';
import { UiLogger } from './UiLogger';
import { AvoidAreaCallback } from './Model';

export class UIBase {
  static readonly windowStageName: string = 'UI.WindowStage';

  // 初始化窗口管理器
  static init(windowStage: window.WindowStage) {
    AppStorage.setOrCreate(UIBase.windowStageName, windowStage);
  }

  // 获取主窗口
  static getWindow(): window.Window | undefined {
    const windowStage: window.WindowStage | undefined = AppStorage.get(UIBase.windowStageName);
    if (!windowStage) {
      return undefined;
    }
    try {
      return windowStage.getMainWindowSync();
    } catch (e) {
      UiLogger.error(`UIBase getWindow failed, exception: ${JSON.stringify(e)}`);
      return undefined;
    }
  }

  // 开启系统规避区域的监听
  static onAvoidAreaChange(callback: Callback<AvoidAreaCallback>) {
    const windowCur = UIBase.getWindow();
    if (!windowCur) {
      return;
    }
    try {
      windowCur.on('avoidAreaChange', callback);
    } catch (e) {
      UiLogger.error(`UIBase onAvoidAreaChange failed, exception: ${JSON.stringify(e)}`);
    }
  }

  // 关闭系统规避区域的监听
  static offAvoidAreaChange(callback: Callback<AvoidAreaCallback>) {
    const windowCur = UIBase.getWindow();
    if (!windowCur) {
      return;
    }
    try {
      windowCur.off('avoidAreaChange', callback);
    } catch (e) {
      UiLogger.error(`UIBase offAvoidAreaChange failed, exception: ${JSON.stringify(e)}`);
    }
  }

  // 监听窗口大小变化
  static onWindowSizeChange(callback: Callback<Size>) {
    const windowCur = UIBase.getWindow();
    if (!windowCur) {
      return;
    }
    try {
      windowCur.on('windowSizeChange', callback);
    } catch (e) {
      UiLogger.error('UIBase on windowSizeChange fail, error: ' + JSON.stringify(e));
    }
  }

  // 取消监听窗口大小变化
  static offWindowSizeChange(callback: Callback<Size>) {
    const windowCur = UIBase.getWindow();
    if (!windowCur) {
      return;
    }
    try {
      windowCur.off('windowSizeChange', callback);
    } catch (e) {
      UiLogger.error('UIBase off windowSizeChange fail, error: ' + JSON.stringify(e));
    }
  }

  // 获取窗口属性
  public static getWindowProperties(): window.WindowProperties | undefined {
    const windowClass: window.Window | undefined = UIBase.getWindow();

    try {
      return windowClass?.getWindowProperties();
    } catch (e) {
      UiLogger.error(`AvoidAreaInfo getWindowRect failed, exception: ${JSON.stringify(e)}`);
      return undefined;
    }
  }

  // 获取窗口Rect
  public static getWindowRect() {
    const windowProperties: window.WindowProperties | undefined = UIBase.getWindowProperties();
    return windowProperties?.windowRect;
  }

  // 判断窗口是否沉浸式
  public static isWindowLayoutFullScreen() {
    const windowProperties: window.WindowProperties | undefined = UIBase.getWindowProperties();
    return windowProperties?.isLayoutFullScreen;
  }
}