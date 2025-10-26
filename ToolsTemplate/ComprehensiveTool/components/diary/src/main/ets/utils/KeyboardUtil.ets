import { window } from '@kit.ArkUI';

export class KeyboardUtil {
  uiContext: UIContext

  constructor(context: UIContext) {
    this.uiContext = context;
  }

  registerKeyboardListener(onKeyboardShow: () => void, onKeyboardHide: () => void) {
    window.getLastWindow(this.uiContext.getHostContext()).then(currentWindow => {
      currentWindow.on('keyboardHeightChange', (data: number) => {
        const keyboardHeight = this.uiContext.px2vp(data)
        if (keyboardHeight > 0) {
          onKeyboardShow()
        } else {
          onKeyboardHide()
        }
      })
    })
  }

  unregisterKeyboardListener() {
    window.getLastWindow(this.uiContext.getHostContext()).then(currentWindow => {
      currentWindow.off('keyboardHeightChange')
    })
  }

  hideKeyboard() {
    this.uiContext.getFocusController().clearFocus();
  }

  showKeyboard(focusId: string) {
    this.uiContext.getFocusController().requestFocus(focusId);
  }
}