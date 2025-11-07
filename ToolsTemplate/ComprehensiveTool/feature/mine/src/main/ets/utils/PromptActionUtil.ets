import { BusinessError } from '@kit.BasicServicesKit';
import { ComponentContent, promptAction, UIContext } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class PromptActionUtil {
  static ctx: UIContext;
  static contentNode: ComponentContent<Object>;
  static options: promptAction.BaseDialogOptions;

  static setContext(context: UIContext) {
    PromptActionUtil.ctx = context;
  }

  static setContentNode(node: ComponentContent<Object>) {
    PromptActionUtil.contentNode = node;
  }

  static setOptions(options: promptAction.BaseDialogOptions) {
    PromptActionUtil.options = options;
  }

  static openDialog() {
    if (PromptActionUtil.contentNode !== null) {
      PromptActionUtil.ctx.getPromptAction().openCustomDialog(PromptActionUtil.contentNode, PromptActionUtil.options)
        .then(() => {
          hilog.info(0xFF00, 'TAG', 'OpenCustomDialog complete');
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          hilog.info(0xFF00, 'TAG', `OpenCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
  }

  static closeDialog(contentNode: ComponentContent<Object>) {
    if (PromptActionUtil.contentNode !== null) {
      PromptActionUtil.ctx.getPromptAction().closeCustomDialog(contentNode)
        .then(() => {
          hilog.info(0xFF00, 'TAG', 'CloseCustomDialog complete');
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          hilog.info(0xFF00, 'TAG', `CloseCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
  }

  static updateDialog(options: promptAction.BaseDialogOptions) {
    if (PromptActionUtil.contentNode !== null) {
      PromptActionUtil.ctx.getPromptAction().updateCustomDialog(PromptActionUtil.contentNode, options)
        .then(() => {
          hilog.info(0xFF00, 'TAG', 'UpdateCustomDialog complete');
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          hilog.info(0xFF00, 'TAG', `UpdateCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
  }
}