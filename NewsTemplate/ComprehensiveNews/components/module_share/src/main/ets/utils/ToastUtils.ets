import { promptAction } from '@kit.ArkUI';
import { Logger } from '../common/Logger';

const TAG = '[ToastUtils]';

export function showToast(uiContext: UIContext | undefined, options: promptAction.ShowToastOptions) {
  try {
    uiContext?.getPromptAction().showToast(options);
  } catch (error) {
    Logger.error(TAG, 'showToast fail, error: ' + JSON.stringify(error));
  }
}