import { window } from "@kit.ArkUI";

// 短消息提示时长
const SHORT_TIME = 2000;
// 长消息提示时长
const LONG_TIME = 3500;

const windowStage: window.WindowStage = AppStorage.get('windowStage')

export class ToastUtil {
  private constructor() {
  }

  /**
   * 短消息提示
   * @param {string} content 提示内容
   */
  public static shortToast(content: string, distance?: number): void {
    windowStage.getMainWindowSync().getUIContext().getPromptAction().showToast({
      message: content,
      duration: SHORT_TIME,
      bottom: distance,
    });
  }

  /**
   * 长消息提示
   * @param {string} content
   */
  public static longToast(content: string): void {
    windowStage.getMainWindowSync().getUIContext().getPromptAction().showToast({
      message: content,
      duration: LONG_TIME,
    });
  }
}

