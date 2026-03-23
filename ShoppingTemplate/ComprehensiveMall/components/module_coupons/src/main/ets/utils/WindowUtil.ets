import { AppStorageV2, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { LOG_TAG } from '../constants/Contants';

const TAG = 'WindowUtil';

@ObservedV2
export class AvoidAreaSize {
  @Trace top: number = 0;
  @Trace bottom: number = 0;
}

export class WindowUtil {
  private static _uiContext: UIContext;
  private static _currentWindow: window.Window | null = null;
  private static _avoidAreaSize: AvoidAreaSize = AppStorageV2.connect(
    AvoidAreaSize,
    () => new AvoidAreaSize(),
  )!;

  public static init(window: window.Window, uiContext: UIContext) {
    WindowUtil._currentWindow = window;
    WindowUtil._uiContext = uiContext;
    WindowUtil.addWindowAvoidAreaListener();
  }

  public static setFullWindow(isFull: boolean = true) {
    if (WindowUtil._currentWindow) {
      WindowUtil._currentWindow
        .setWindowLayoutFullScreen(isFull)
        .then(() => {
          Logger.info(TAG, 'Set full window success');
        })
        .catch((error: BusinessError) => {
          WindowUtil._dealAllError(error);
        });
    }
  }

  public static addWindowAvoidAreaListener() {
    try {
      if (WindowUtil._currentWindow) {
        const systemArea = WindowUtil._currentWindow.getWindowAvoidArea(
          window.AvoidAreaType.TYPE_SYSTEM,
        );
        WindowUtil._avoidAreaSize.top = WindowUtil._uiContext.px2vp(systemArea.topRect.height);
        const bottomArea = WindowUtil._currentWindow.getWindowAvoidArea(
          window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR,
        );
        WindowUtil._avoidAreaSize.bottom = WindowUtil._uiContext.px2vp(bottomArea.bottomRect.height);
      }
    } catch (err) {
      Logger.error(LOG_TAG, 'add window avoid area failed. error: ' + JSON.stringify(err));
    }
  }

  public static getAvoidArea() {
    return WindowUtil._avoidAreaSize;
  }

  private static _dealAllError(error: BusinessError): void {
    Logger.error(
      TAG,
      `Failed to use WindowUtil, errorCode: ${error.code}, errorMsg: ${error.message}`,
    );
  }
}
