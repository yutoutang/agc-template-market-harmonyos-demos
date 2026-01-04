/**
 * 文本编辑对话框组件
 * 用于学校名称、专业名称、公司名称等单行文本的编辑
 */

import { ComponentContent } from '@kit.ArkUI'

export interface CenterEditDialogParams {
  title: string
  placeholder: string
  value: string
  onCancel: () => void
  onConfirm: (value: string) => void
}

class EditDialogData {
  title: string = ''
  placeholder: string = ''
  value: string = ''
  temp: string = ''
  onCancel: () => void = () => {}
  onConfirm: (value: string) => void = () => {}

  constructor(params: CenterEditDialogParams) {
    this.title = params.title
    this.placeholder = params.placeholder
    this.value = params.value
    this.temp = params.value
    this.onCancel = params.onCancel
    this.onConfirm = params.onConfirm
  }
}

@Builder
function editDialogBuilder(data: EditDialogData) {
  Column() {
    Text(data.title)
      .width('100%')
      .textAlign(TextAlign.Start)
      .fontSize(20)
      .fontWeight(FontWeight.Normal)
      .fontColor($r('sys.color.black'))
    TextInput({ text: data.temp, placeholder: data.placeholder })
      .padding({
        left: '0vp',
        right: '0vp',
        top: '8vp',
        bottom: '8vp'
      })
      .fontSize(16)
      .fontColor($r('sys.color.font_primary'))
      .backgroundColor($r('sys.color.background_primary'))
      .constraintSize({ minHeight: 48 })
      .margin({ top: 16 })
      .onChange((value: string) => {
        data.temp = value
      })
    Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
    Row() {
      Button('取消')
        .width('44%')
        .height(40)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_tertiary'))
        .backgroundColor('#00000000')
        .onClick(() => {
          data.onCancel()
          CenterEditDialogController.closeDialog()
        })
      Text('|')
        .fontColor($r('sys.color.comp_divider'))
      Button('确定')
        .width('44%')
        .height(40)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_emphasize'))
        .backgroundColor('#00000000')
        .onClick(() => {
          data.onConfirm(data.temp)
          CenterEditDialogController.closeDialog()
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: 12 })
  }
  .width('90%')
  .padding({
    left: 16,
    right: 16,
    top: 16,
    bottom: 16
  })
  .borderRadius(32)
  .backgroundColor($r('sys.color.background_primary'))
}

export class CenterEditDialogController {
  private static ctx: UIContext
  private static contentNode: ComponentContent<EditDialogData> | null = null

  static openDialog(uiContext: UIContext, params: CenterEditDialogParams) {
    CenterEditDialogController.ctx = uiContext
    const data = new EditDialogData(params)
    CenterEditDialogController.contentNode = new ComponentContent(uiContext, wrapBuilder(editDialogBuilder), data)
    uiContext.getPromptAction().openCustomDialog(CenterEditDialogController.contentNode, {
      alignment: DialogAlignment.Center,
      autoCancel: false
    })
  }

  static closeDialog() {
    if (CenterEditDialogController.contentNode && CenterEditDialogController.ctx) {
      CenterEditDialogController.ctx.getPromptAction().closeCustomDialog(CenterEditDialogController.contentNode)
      CenterEditDialogController.contentNode = null
    }
  }
}