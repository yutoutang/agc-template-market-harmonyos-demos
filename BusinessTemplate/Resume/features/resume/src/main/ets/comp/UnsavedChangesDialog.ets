/**
 * 二次确认弹窗组件
 * 用于各个页面修改内容后不保存返回的提示
 */

import { GlobalContext } from 'common'
import { ComponentContent } from '@kit.ArkUI'

export interface UnsavedChangesDialogParams {
  onConfirm: () => void
  onCancel: () => void
}

class UnsavedDialogData {
  onConfirm: () => void = () => {
  }
  onCancel: () => void = () => {
  }

  constructor(params: UnsavedChangesDialogParams) {
    this.onConfirm = params.onConfirm
    this.onCancel = params.onCancel
  }
}

@Builder
function unsavedDialogBuilder(data: UnsavedDialogData) {
  Column() {
    Text('确认退出?')
      .fontSize(18)
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.black'))
      .margin({ top: 24, bottom: 16 })

    Text('修改内容将不会保存！')
      .fontSize(14)
      .fontColor('#666666')
      .margin({ bottom: 24 })

    Row()
      .width('100%')
      .height(0.5)
      .backgroundColor('#E5E5E5')

    Row() {
      Text('取消')
        .fontSize(16)
        .fontColor('#666666')
        .width('50%')
        .textAlign(TextAlign.Center)
        .padding({ top: 12, bottom: 12 })
        .onClick(() => {
          data.onCancel()
          UnsavedChangesDialogController.closeDialog()
        })

      Row()
        .width(0.5)
        .height(48)
        .backgroundColor('#E5E5E5')

      Text('确认')
        .fontSize(16)
        .fontColor('#0A59F7')
        .width('50%')
        .textAlign(TextAlign.Center)
        .padding({ top: 12, bottom: 12 })
        .onClick(() => {
          data.onConfirm()
          UnsavedChangesDialogController.closeDialog()
        })
    }
    .width('100%')
  }
  .width(280)
  .backgroundColor($r('sys.color.comp_background_list_card'))
  .borderRadius(32)
}

export class UnsavedChangesDialogController {
  private static ctx: UIContext
  private static contentNode: ComponentContent<UnsavedDialogData> | null = null

  static openDialog(uiContext: UIContext, params: UnsavedChangesDialogParams) {
    UnsavedChangesDialogController.ctx = uiContext
    const data = new UnsavedDialogData(params)
    UnsavedChangesDialogController.contentNode =
      new ComponentContent(uiContext, wrapBuilder(unsavedDialogBuilder), data)
    uiContext.getPromptAction().openCustomDialog(UnsavedChangesDialogController.contentNode, {
      alignment: DialogAlignment.Center,
      autoCancel: false
    })
  }

  static closeDialog() {
    if (UnsavedChangesDialogController.contentNode && UnsavedChangesDialogController.ctx) {
      UnsavedChangesDialogController.ctx.getPromptAction().closeCustomDialog(UnsavedChangesDialogController.contentNode)
      UnsavedChangesDialogController.contentNode = null
    }
  }
}

/**
 * 使用系统原生弹窗的工具函数
 * 适用于无法使用自定义组件的场景
 */
export function showUnsavedChangesDialog(onConfirm: () => void): void {
  const pa = GlobalContext.getUIContext().getPromptAction()
  pa.showDialog({
    title: '确认退出?',
    message: '修改内容将不会保存！',
    buttons: [
      { text: '取消', color: '#666666' },
      { text: '确认', color: '#0A59F7' }
    ]
  }).then((data) => {
    if (data.index === 1) {
      onConfirm()
    }
  })
}
