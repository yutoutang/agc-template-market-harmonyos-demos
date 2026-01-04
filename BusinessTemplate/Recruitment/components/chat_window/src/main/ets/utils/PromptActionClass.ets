import { BusinessError } from '@kit.BasicServicesKit';
import { ComponentContent, promptAction, UIContext } from '@kit.ArkUI';
import { BubbleMsgComponent } from '../components/BubbleMsgComponent';
import { ChatContentSingleModel } from 'chat_base';
import { POP_MENU_TYPE } from '../model/BubbleMsgModel';

class Params {
  width: number | string = 0
  height: number | string = 0
  chatVM: ChatContentSingleModel | undefined = undefined

  constructor(width: number | string, height: number | string, chatVM: ChatContentSingleModel) {
    this.width = width
    this.height = height
    this.chatVM = chatVM
  }
}

export class PromptActionClass {
  static ctx: UIContext;
  static contentNode: ComponentContent<Object>;
  static options: promptAction.BaseDialogOptions = { alignment: DialogAlignment.TopStart, offset: { dx: 0, dy: 0 } }

  static setContext(context: UIContext) {
    PromptActionClass.ctx = context;
  }

  static setContentNode(node: ComponentContent<Object>) {
    PromptActionClass.contentNode = node;
  }

  static setOptions(options: promptAction.BaseDialogOptions) {
    PromptActionClass.options = options;
  }

  static openDialog() {
    if (PromptActionClass.contentNode !== null) {
      PromptActionClass.ctx.getPromptAction()
        .openCustomDialog(PromptActionClass.contentNode, PromptActionClass.options)
        .then(() => {
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
        })
    }
  }

  static closeDialog() {
    if (PromptActionClass.contentNode !== null) {
      PromptActionClass.ctx.getPromptAction()
        .closeCustomDialog(PromptActionClass.contentNode)
        .then(() => {
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
        })
    }
  }

  static updateDialog(options: promptAction.BaseDialogOptions) {
    if (PromptActionClass.contentNode !== null) {
      PromptActionClass.ctx.getPromptAction()
        .updateCustomDialog(PromptActionClass.contentNode, options)
        .then(() => {
        })
        .catch((error: BusinessError) => {
          let message = (error as BusinessError).message;
          let code = (error as BusinessError).code;
        })
    }
  }

  //关闭气泡弹窗
  static closePop = () => {
  }
  //气泡菜单点击事件
  static menuClick = (chatVM: ChatContentSingleModel, type: POP_MENU_TYPE) => {
  }
  static getDeviceType: () => number

  static initBuilder(width: number | string, height: number | string, dx: number | string, dy: number | string,
    chatVM: ChatContentSingleModel) {
    const contentNode: ComponentContent<Object> =
      new ComponentContent(PromptActionClass.ctx, wrapBuilder(promptDialogBuilder), new Params(width, height, chatVM));
    PromptActionClass.setContentNode(contentNode)

    const options: promptAction.BaseDialogOptions =
      {
        alignment: DialogAlignment.TopStart,
        offset: { dx: dx, dy: dy },
        maskColor: '#00000000',
        transition: TransitionEffect.IDENTITY,
        isModal: false,
        onWillAppear: () => {

        },
        onWillDisappear: () => {
          PromptActionClass.closePop()
        }
      }
    PromptActionClass.setOptions(options)
  }
}

@Builder
function promptDialogBuilder(params: Params) {
  Column() {
    BubbleMsgComponent({
      chatVM: params.chatVM
    })
  }
  .width(params.width).height(params.height)

  .onClick(() => {
    PromptActionClass.closeDialog()
  })
}