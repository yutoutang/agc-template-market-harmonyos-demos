import { UIContext } from '@kit.ArkUI';

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
    if (!WindowUtil._uiContext) {
      WindowUtil._uiContext = uiContext;
      WindowUtil._context = WindowUtil._uiContext.getHostContext();
    }
  }
}
