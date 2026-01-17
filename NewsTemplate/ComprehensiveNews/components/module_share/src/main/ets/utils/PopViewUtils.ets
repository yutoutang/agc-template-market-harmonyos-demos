import { ComponentContent } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../common/Logger';

enum PopViewShowType {
  OPEN
}

interface PopViewModel {
  com: ComponentContent<Object>;
  popType: PopViewShowType;
}

const TAG = '[SharePopViewUtils]';

/**
 * 全局弹窗类
 */
export class PopViewUtils {
  private static popShare: PopViewUtils;
  private sheetList: PopViewModel[] = [];

  private static shareInstance(): PopViewUtils {
    if (!PopViewUtils.popShare) {
      PopViewUtils.popShare = new PopViewUtils();
    }
    return PopViewUtils.popShare;
  }

  private static async showSheetView<T extends Object>(uiContext: UIContext, type: PopViewShowType,
    contentView: WrappedBuilder<[T]> | WrappedBuilder<[]>, args?: T,
    options?: SheetOptions): Promise<void> {
    let componentContent: ComponentContent<Object> | null = null;
    if (args) {
      componentContent = new ComponentContent(uiContext, contentView, args);
    } else {
      componentContent = new ComponentContent(uiContext, contentView as WrappedBuilder<[]>);
    }
    uiContext.openBindSheet(componentContent, options).then(() => {
      if (componentContent) {
        let sheetList = PopViewUtils.shareInstance().sheetList;
        let info: PopViewModel = {
          com: componentContent,
          popType: type,
        };
        sheetList[0] = info;
      }
    }).catch((e: BusinessError) => {
      Logger.error(TAG, 'openBindSheet fail, error: ' + JSON.stringify(e));
    });
  }

  private static async closeSheetView(uiContext: UIContext, type: PopViewShowType): Promise<void> {
    let sameTypeList = PopViewUtils.shareInstance().sheetList.filter((model) => {
      return model.popType === type;
    })
    let info = sameTypeList[sameTypeList.length - 1];
    if (info?.com) {
      PopViewUtils.shareInstance().sheetList = PopViewUtils.shareInstance().sheetList.filter((model) => {
        return model.com !== info.com;
      })
      uiContext.closeBindSheet(info.com).catch((e: BusinessError) => {
        Logger.error(TAG, 'closeBindSheet fail, error: ' + JSON.stringify(e));
      });
    }
  }


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
  public static closeSheet(uiContext: UIContext): void {
    PopViewUtils.closeSheetView(uiContext, PopViewShowType.OPEN);
  }
}