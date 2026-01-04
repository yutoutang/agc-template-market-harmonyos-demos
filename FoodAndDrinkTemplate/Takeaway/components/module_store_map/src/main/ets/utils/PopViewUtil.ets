import { ComponentContent, promptAction, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from 'module_ui_base';

const TAG: string = '[PopViewUtil]';

export class PopViewUtil {
  private static _ctx: UIContext;
  private static _dialogNodes: ComponentContent<Object>[] = [];

  private static async _getUIContext() {
    if (!PopViewUtil._ctx) {
      try {
        const win = await window.getLastWindow(getContext());
        PopViewUtil._ctx = win.getUIContext();
      } catch (err) {
        Logger.error(TAG, 'get ui context failed.' + JSON.stringify(err));
      }
    }
  }

  public static async openDialog<T extends Object>(
    builder: WrappedBuilder<[T]> | WrappedBuilder<[]>,
    options: promptAction.BaseDialogOptions,
    args?: T,
  ) {
    await PopViewUtil._getUIContext();
    if (!PopViewUtil._ctx) {
      return;
    }
    if (args) {
      PopViewUtil._dialogNodes.push(
        new ComponentContent(PopViewUtil._ctx, builder, args),
      );
    } else {
      PopViewUtil._dialogNodes.push(
        new ComponentContent(PopViewUtil._ctx, builder as WrappedBuilder<[]>),
      );
    }

    if (PopViewUtil._dialogNodes.length) {
      const latest = PopViewUtil._dialogNodes[PopViewUtil._dialogNodes.length - 1];
      try {
        if (!options.onWillDismiss) {
          options.onWillDismiss = () => {
            PopViewUtil.closeDialog();
          };
        }
        await PopViewUtil._ctx.getPromptAction().openCustomDialog(latest, options);
        Logger.info(TAG, 'open custom dialog complete.');
      } catch (err) {
        Logger.error(TAG, `open custom dialog failed. error: ${JSON.stringify(err)}`);
      }
    }
  }

  public static closeDialog() {
    if (PopViewUtil._dialogNodes.length) {
      const latest = PopViewUtil._dialogNodes[PopViewUtil._dialogNodes.length - 1];
      PopViewUtil._ctx
        .getPromptAction()
        .closeCustomDialog(latest)
        .then(() => {
          Logger.info(TAG, 'close custom dialog complete.');
          PopViewUtil._dialogNodes.pop();
        })
        .catch((error: BusinessError) => {
          Logger.error(TAG, `close custom dialog failed. error: ${JSON.stringify(error)}`);
        });
    }
  }

  public static async closeAllSheet() {
    if (PopViewUtil._dialogNodes.length) {
      PopViewUtil._dialogNodes.forEach(async (item) => {
        try {
          await PopViewUtil._ctx.getPromptAction().closeCustomDialog(item);
          Logger.info(TAG, 'close sheet complete.');
        } catch (err) {
          Logger.error(TAG, `close sheet failed. error: ${JSON.stringify(err)}`);
        }
      });
      PopViewUtil._dialogNodes = [];
    }
  }
}
