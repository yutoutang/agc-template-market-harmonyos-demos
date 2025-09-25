import { ComponentContent, promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

export class PromptActionClass {
  static ctx: UIContext;
  static contentNode: ComponentContent<Object>;
  static options: promptAction.BaseDialogOptions;

  static setContext(context: UIContext) {
    PromptActionClass.ctx = context;
  }

  static setContentNode(node: ComponentContent<Object>) {
    PromptActionClass.contentNode = node;
  }

  static setParam(param:Params){
    let contentNode: ComponentContent<Object> =
      new ComponentContent(PromptActionClass.ctx, wrapBuilder(buildText), param);
    PromptActionClass.setContentNode(contentNode)
  }

  static setOptions(options: promptAction.BaseDialogOptions) {
    PromptActionClass.options = options;
  }

  static openDialog() {
    if (PromptActionClass.contentNode !== null) {
      PromptActionClass.ctx.getPromptAction()
        .openCustomDialog(PromptActionClass.contentNode, PromptActionClass.options)
        .then(() => {
          console.info('OpenCustomDialog complete.');
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          console.error(`OpenCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
  }

  static closeDialog() {
    if (PromptActionClass.contentNode !== null) {
      PromptActionClass.ctx.getPromptAction()
        .closeCustomDialog(PromptActionClass.contentNode)
        .then(() => {
          console.info('CloseCustomDialog complete.');
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          console.error(`CloseCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
  }

  static updateDialog(options: promptAction.BaseDialogOptions) {
    if (PromptActionClass.contentNode !== null) {
      PromptActionClass.ctx.getPromptAction()
        .updateCustomDialog(PromptActionClass.contentNode, options)
        .then(() => {
          console.info('UpdateCustomDialog complete.');
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
          console.error(`UpdateCustomDialog args error code is ${code}, message is ${message}`);
        })
    }
  }
}

export interface CustomButton {
  content: string;
  action: Function
}

export class Params {
  title: string = '';
  buttons: CustomButton[] = []

  constructor(title: string, buttons: CustomButton[]) {
    this.title = title;
    this.buttons = buttons;
  }
}

@Builder
function buildText(params: Params) {
  Column() {
    Text(params.title)
      .fontSize(16)
      .fontWeight(400)
      .textAlign(TextAlign.Center)
      .height(21)
      .fontColor($r('sys.color.font_on_primary'))
      .margin({ bottom: 24 })

    Row() {
      Text(params.buttons[0]?.content)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .width(144)
        .height(21)
        .textAlign(TextAlign.Center)
        .fontColor($r('sys.color.font_on_primary'))
        .onClick(() => {
          params.buttons[0]?.action?.()
        })

      Divider()
        .vertical(true)
        .height(24)
        .color($r('sys.color.font_primary'))
      Text(params.buttons[1]?.content)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .fontColor('#FF7500')
        .width(144)
        .onClick(() => {
          params.buttons[1]?.action?.()
        })
    }
    .height(40)
  }
  .borderRadius(32)
  .height(125)
  .width(328)
  .backgroundColor('#2E3033')
  .alignItems(HorizontalAlign.Center)
  .padding({
    top: 24,
    left: 24,
    right: 24,
    bottom: 16
  })
}