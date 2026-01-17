import { ComponentContent, promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from './Logger';

enum PopViewShowType {
  OPEN
}

interface PopViewModel {
  com: ComponentContent<Object>;
  popType: PopViewShowType;
}

const TAG = '[AppSettingPopViewUtils]';

/**
 * 全局弹窗类
 */
export class PopViewUtils {
  private static popShare: PopViewUtils;
  private static uiContext: UIContext;
  private infoList: PopViewModel[] = [];

  private static shareInstance(): PopViewUtils {
    if (!PopViewUtils.popShare) {
      PopViewUtils.popShare = new PopViewUtils();
    }
    return PopViewUtils.popShare;
  }

  private static async showDialog<T extends Object>(uiContext: UIContext, type: PopViewShowType,
    contentView: WrappedBuilder<[T]> | WrappedBuilder<[]>, args?: T,
    options?: promptAction.BaseDialogOptions): Promise<void> {
    PopViewUtils.uiContext = uiContext;
    if (PopViewUtils.uiContext) {
      let prompt = PopViewUtils.uiContext.getPromptAction();
      let componentContent: ComponentContent<Object> | null = null;
      if (args) {
        componentContent = new ComponentContent(PopViewUtils.uiContext, contentView, args);
      } else {
        componentContent = new ComponentContent(PopViewUtils.uiContext, contentView as WrappedBuilder<[]>);
      }

      let customOptions: promptAction.BaseDialogOptions = {
        alignment: options?.alignment ?? DialogAlignment.Center,
        autoCancel: options?.autoCancel ?? true,
        maskColor: options?.maskColor,
        onWillDismiss: (v: DismissDialogAction) => {
          if (options?.autoCancel ?? true) {
            v.dismiss();
          }
        },
      };
      prompt.openCustomDialog(componentContent, customOptions).then(() => {
        if (componentContent) {
          let infoList = PopViewUtils.shareInstance().infoList;
          let info: PopViewModel = {
            com: componentContent,
            popType: type,
          };
          infoList[0] = info;
        }
      }).catch((e: BusinessError) => {
        Logger.error(TAG, 'openCustomDialog fail, error: ' + JSON.stringify(e));
      });
    }
  }

  private static async closeDialog(uiContext: UIContext, type: PopViewShowType): Promise<void> {
    PopViewUtils.uiContext = uiContext;
    if (PopViewUtils.uiContext) {
      let prompt = PopViewUtils.uiContext.getPromptAction();
      let sameTypeList = PopViewUtils.shareInstance().infoList.filter((model) => {
        return model.popType === type;
      })
      let info = sameTypeList[sameTypeList.length - 1];
      if (info?.com) {
        PopViewUtils.shareInstance().infoList = PopViewUtils.shareInstance().infoList.filter((model) => {
          return model.com !== info.com;
        })
        prompt.closeCustomDialog(info.com).catch((e: BusinessError) => {
          Logger.error(TAG, 'closeCustomDialog fail, error: ' + JSON.stringify(e));
        });
      }
    }
  }

  /**
   * 打开弹窗
   * @param uiContext
   * @param contentView
   * @param options
   * @param args
   */
  public static showPopView<T extends Object>(uiContext: UIContext,
    contentView: WrappedBuilder<[T]> | WrappedBuilder<[]>,
    options?: promptAction.BaseDialogOptions, args?: T): void {
    PopViewUtils.showDialog(uiContext, PopViewShowType.OPEN, contentView, args, options);
  }

  /**
   * 关闭弹窗
   * @param uiContext
   */
  public static closePopView(uiContext: UIContext): void {
    PopViewUtils.closeDialog(uiContext, PopViewShowType.OPEN);
  }
}
