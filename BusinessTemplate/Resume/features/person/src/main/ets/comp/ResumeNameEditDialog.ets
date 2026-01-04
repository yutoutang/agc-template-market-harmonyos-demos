import { ComponentContent, promptAction } from '@kit.ArkUI'

export interface ResumeNameEditParams {
  currentName: string
  onConfirm: (name: string) => void
  onCancel: () => void
}

class ResumeNameEditData {
  currentName: string = ''
  onConfirm: (name: string) => void = () => {
  }
  onCancel: () => void = () => {
  }

  constructor(params: ResumeNameEditParams) {
    this.currentName = params.currentName
    this.onConfirm = params.onConfirm
    this.onCancel = params.onCancel
  }
}

export class ResumeNameEditDialogController {
  private static ctx: UIContext
  private static contentNode: ComponentContent<ResumeNameEditData> | null = null

  static openDialog(uiContext: UIContext, params: ResumeNameEditParams) {
    ResumeNameEditDialogController.ctx = uiContext
    const data = new ResumeNameEditData(params)
    ResumeNameEditDialogController.contentNode =
      new ComponentContent(uiContext, wrapBuilder(resumeNameEditDialogBuilder), data)
    uiContext.getPromptAction().openCustomDialog(ResumeNameEditDialogController.contentNode, {
      alignment: DialogAlignment.Center,
      autoCancel: false
    })
  }

  static closeDialog() {
    if (ResumeNameEditDialogController.contentNode && ResumeNameEditDialogController.ctx) {
      ResumeNameEditDialogController.ctx.getPromptAction().closeCustomDialog(ResumeNameEditDialogController.contentNode)
      ResumeNameEditDialogController.contentNode = null
    }
  }
}

@Builder
function resumeNameEditDialogBuilder(data: ResumeNameEditData) {
  ResumeNameEditDialog({ data: data })
}

@ComponentV2
struct ResumeNameEditDialog {
  @Require @Param data: ResumeNameEditData
  @Local editingName: string = ''

  aboutToAppear(): void {
    this.editingName = this.data.currentName
  }

  build() {
    Column() {
      Text('编辑简历名称')
        .fontSize(18)
        .fontColor($r('sys.color.black'))
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ bottom: 16 })

      // 输入框
      TextInput({ text: this.editingName, placeholder: '请填写简历名称' })
        .fontSize(16)
        .lineHeight(19)
        .fontColor($r('sys.color.black'))
        .height(48)
        .width('100%')
        .margin({ bottom: 8 })
        .padding({ left: 0, right: 0 })
        .borderRadius(0)
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .onChange((value: string) => {
          this.editingName = value
        })

      // 分隔线
      Divider()
        .color($r('sys.color.comp_divider'))
        .strokeWidth('1px')
        .margin({ bottom: 0 })

      // 按钮区域
      Row() {
        Text('取消')
          .fontSize(16)
          .lineHeight(22)
          .fontColor('#99000000')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .height(56)
          .onClick(() => {
            this.data.onCancel()
            ResumeNameEditDialogController.closeDialog()
          })

        Divider()
          .vertical(true)
          .color('#E5E5E5')
          .strokeWidth('1px')
          .height(32)

        Text('确定')
          .fontSize(16)
          .lineHeight(22)
          .fontColor('#0A59F7')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .height(56)
          .onClick(() => {
            if (this.editingName.trim() === '') {
              promptAction.showToast({ message: '简历名称不能为空' })
              return
            }
            this.data.onConfirm(this.editingName)
            ResumeNameEditDialogController.closeDialog()
          })
      }
      .width('100%')
    }
    .width('90%')
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(32)
    .padding({ left: 20, right: 20, top: 24 })
  }
}
