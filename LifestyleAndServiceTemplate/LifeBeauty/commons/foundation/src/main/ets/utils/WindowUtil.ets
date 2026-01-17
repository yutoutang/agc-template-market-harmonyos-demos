import { window } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[WindowUtil]'

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

  public static async init(uiContext: UIContext) {
    if (WindowUtil._uiContext) {
      return;
    }
    WindowUtil._uiContext = uiContext;
    WindowUtil._context = WindowUtil._uiContext.getHostContext();
  }

  public static async getTopPadding() {
    let topPadding = 39;
    if (!WindowUtil.context) {
      return topPadding;
    }
    try {
      const win: window.Window = await window.getLastWindow(WindowUtil.context);
      const area = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      topPadding = WindowUtil.uiContext.px2vp(area.topRect.height);
    } catch (e) {
      UtilLog.error(TAG, `Failed to get window avoid area. ${JSON.stringify(e)}`)
    }

    return topPadding
  }
}
