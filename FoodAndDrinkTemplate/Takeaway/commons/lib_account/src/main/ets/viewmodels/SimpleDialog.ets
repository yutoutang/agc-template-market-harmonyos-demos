import { PromptAction, UIContext } from '@ohos.arkui.UIContext';
import { ComponentContent } from '@kit.ArkUI';

import { DialogContentVM } from './DialogContentVM';

export class SimpleDialog {
  private uiContext: UIContext;
  private promptAction: PromptAction;
  private dialogContent: DialogContentVM = new DialogContentVM();
  private node: ComponentContent<DialogContentVM> | null = null;
  private _close: () => void = () => {
    if (this.node) {
      this.promptAction.closeCustomDialog(this.node);
      this.node = null;
    }
  };
  private confirm: () => void = () => this._close();
  private cancel: () => void = () => this._close();
  private willDismiss: () => boolean = () => true;

  public setMessage(value: string): SimpleDialog {
    this.dialogContent.message = value;
    return this;
  }

  public setConfirmButtonText(value: string): SimpleDialog {
    this.dialogContent.confirmButtonText = value;
    return this;
  }

  public setCancelButtonText(value: string): SimpleDialog {
    this.dialogContent.cancelButtonText = value;
    return this;
  }

  public onWillDismiss(callback: () => boolean): SimpleDialog {
    this.willDismiss = callback;
    return this;
  }

  public onConfirm(callback: () => void): SimpleDialog {
    this.confirm = () => {
      this._close();
      callback();
    };
    this.dialogContent.confirm = this.confirm;
    return this;
  }

  public onCancel(callback: () => void): SimpleDialog {
    this.cancel = () => {
      this._close();
      callback();
    };
    this.dialogContent.cancel = this.cancel;
    return this;
  }

  public open(): void {
    if (this.node) {
      return;
    }
    this.node = new ComponentContent(this.uiContext, wrapBuilder(buildSimpleDialog), this.dialogContent);
    this.promptAction
      .openCustomDialog(this.node, {
        onWillDismiss: () => {
          if (this.willDismiss()) {
            this._close();
          }
        },
      })
      .catch(() => this.node = null);
  }

  public close(): void {
    this._close();
  }

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
    this.promptAction = uiContext.getPromptAction();
    this.dialogContent.confirm = this.confirm;
    this.dialogContent.cancel = this.cancel;
  }
}

@Builder
function buildSimpleDialog(content: DialogContentVM): void {
  Column() {
    Text(content.message)
      .fontSize(16)
      .fontColor('#E6000000')
      .fontWeight(600)
      .margin({ bottom: 8 })
    Row() {
      Button() {
        Text(content.cancelButtonText)
          .fontColor($r('sys.color.font_tertiary'))
      }
      .width('50%')
      .height(40)
      .fontWeight(500)
      .type(ButtonType.Normal)
      .backgroundColor(Color.Transparent)
      .onClick(() => content.cancel())

      Button() {
        Text(content.confirmButtonText)
          .fontColor($r('sys.color.warning'))
      }
      .width('50%')
      .height(40)
      .fontWeight(500)
      .type(ButtonType.Normal)
      .backgroundColor(Color.Transparent)
      .onClick(() => content.confirm())
    }
    .width('100%')
  }
  .width('90%')
  .padding(16)
  .justifyContent(FlexAlign.Start)
  .backgroundColor(Color.White)
  .borderRadius(24)
}
