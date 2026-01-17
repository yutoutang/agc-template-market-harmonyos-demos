import { ComponentContent } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[LoginPopViewUtils]';

enum PopViewShowType {
  OPEN
}

interface PopViewModel {
  com: ComponentContent<Object>;
  popType: PopViewShowType;
}

/**
 * 全局弹窗类
 */
export class PopViewUtils {
  private static popShare: PopViewUtils;
  private static uiContext: UIContext;
  private sheetList: PopViewModel[] = [];

  /**
   * 打开半模态弹窗
   * @param contentView
   * @param args
   * @param options
   */
  public static showSheet<T extends Object>(uiContext: UIContext, contentView: WrappedBuilder<[T]> | WrappedBuilder<[]>,
    options?: SheetOptions, args?: T): void {
    PopViewUtils.showSheetView(uiContext, PopViewShowType.OPEN, contentView, args, options);
  }

  /**
   * 关闭半模态弹窗
   */
  public static closeSheet(): void {
    PopViewUtils.closeSheetView(PopViewShowType.OPEN);
  }

  private static shareInstance(): PopViewUtils {
    if (!PopViewUtils.popShare) {
      PopViewUtils.popShare = new PopViewUtils();
    }
    return PopViewUtils.popShare;
  }

  private static async showSheetView<T extends Object>(uiContext: UIContext, type: PopViewShowType,
    contentView: WrappedBuilder<[T]> | WrappedBuilder<[]>, args?: T,
    options?: SheetOptions): Promise<void> {
    PopViewUtils.uiContext = uiContext;
    if (PopViewUtils.uiContext) {
      let componentContent: ComponentContent<Object> | null = null;
      if (args) {
        componentContent = new ComponentContent(PopViewUtils.uiContext, contentView, args);
      } else {
        componentContent = new ComponentContent(PopViewUtils.uiContext, contentView as WrappedBuilder<[]>);
      }
      PopViewUtils.uiContext.openBindSheet(componentContent, options).then(() => {
        if (componentContent) {
          let sheetList = PopViewUtils.shareInstance().sheetList;
          let info: PopViewModel = {
            com: componentContent,
            popType: type,
          };
          sheetList[0] = info;
          UtilLog.info(TAG, 'sheet open, options: ' + JSON.stringify(options));
        }
      }).catch((e: BusinessError) => {
        UtilLog.error(TAG, 'openBindSheet fail, error: ' + JSON.stringify(e));
      });
    }
  }

  private static async closeSheetView(type: PopViewShowType): Promise<void> {
    if (PopViewUtils.uiContext) {
      let sameTypeList = PopViewUtils.shareInstance().sheetList.filter((model) => {
        return model.popType === type;
      })
      let info = sameTypeList[sameTypeList.length - 1];
      if (info?.com) {
        PopViewUtils.shareInstance().sheetList = PopViewUtils.shareInstance().sheetList.filter((model) => {
          return model.com !== info.com;
        })
        PopViewUtils.uiContext.closeBindSheet(info.com).catch((e: BusinessError) => {
          UtilLog.error(TAG, 'closeBindSheet fail, error: ' + JSON.stringify(e));
        });
      }
    }
  }
}
