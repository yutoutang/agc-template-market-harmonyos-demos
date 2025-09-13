import { AppStorageV2, display, UIContext, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from './Logger';

const TAG: string = '[WindowUtil]';

@ObservedV2
export class WindowUtil {
  @Trace
  private static _context: Context | undefined;

  public static get context(): Context | undefined {
    return WindowUtil._context;
  }

  @Trace
  private static _uiContext: UIContext;

  public static get uiContext(): UIContext {
    return WindowUtil._uiContext;
  }

  public static async initWindowUtil(uiContext: UIContext) {
    if (WindowUtil._uiContext) {
      return;
    }
    WindowUtil._uiContext = uiContext;
    WindowUtil._context = WindowUtil._uiContext.getHostContext();
  }

  public static toast(message: string) {
    try {
      WindowUtil._uiContext.getPromptAction().showToast({ message });
    } catch (err) {
      Logger.error(TAG, 'open toast failed. error:' + JSON.stringify(err));
    }
  }
}
