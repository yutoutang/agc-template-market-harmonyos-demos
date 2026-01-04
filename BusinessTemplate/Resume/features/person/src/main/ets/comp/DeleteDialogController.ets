import { ComponentContent, promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 删除确认弹窗参数
 */
export class DeleteDialogParams {
  title: string = '确认删除?'
  onConfirm: () => void = () => {}
  onCancel: () => void = () => {}
}

/**
 * 删除确认弹窗控制器
 * 使用 promptAction.openCustomDialog API，自动处理安全区域
 */
export class DeleteDialogController {
  private static ctx: UIContext | null = null
  private static contentNode: ComponentContent<DeleteDialogParams> | null = null

  /**
   * 打开删除确认弹窗
   */
  static openDialog(uiContext: UIContext, params: DeleteDialogParams): void {
    DeleteDialogController.ctx = uiContext
    const data = new DeleteDialogParams()
    data.title = params.title
    data.onConfirm = params.onConfirm
    data.onCancel = params.onCancel

    DeleteDialogController.contentNode = new ComponentContent(
      uiContext,
      wrapBuilder(deleteDialogBuilder),
      data
    )

    uiContext.getPromptAction().openCustomDialog(DeleteDialogController.contentNode, {
      alignment: DialogAlignment.Center,
      autoCancel: false
    })
      .then(() => {
      })
      .catch((error: BusinessError) => {
      })
  }

  /**
   * 关闭删除确认弹窗
   */
  static closeDialog(): void {
    if (DeleteDialogController.contentNode && DeleteDialogController.ctx) {
      DeleteDialogController.ctx.getPromptAction().closeCustomDialog(DeleteDialogController.contentNode)
        .then(() => {
          DeleteDialogController.contentNode = null
        })
        .catch((error: BusinessError) => {
        })
    }
  }
}

/**
 * 删除确认弹窗内容构建器
 */
@Builder
function deleteDialogBuilder(params: DeleteDialogParams) {
  Column() {
    // 标题
    Text(params.title)
      .fontSize(17)
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_primary'))
      .margin({ top: 24, bottom: 32 })

    // 分隔线
    Divider()
      .color($r('sys.color.comp_divider'))
      .strokeWidth('1px')

    // 按钮区域
    Row() {
      Text('取消')
        .fontSize(17)
        .fontColor($r('sys.color.font_secondary'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .height(56)
        .onClick(() => {
          DeleteDialogController.closeDialog()
          params.onCancel()
        })

      Divider()
        .vertical(true)
        .color($r('sys.color.comp_divider'))
        .strokeWidth('1px')
        .height(56)

      Text('确认')
        .fontSize(17)
        .fontColor('#FF3B30')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .height(56)
        .onClick(() => {
          DeleteDialogController.closeDialog()
          params.onConfirm()
        })
    }
    .width('100%')
  }
  .width('80%')
  .backgroundColor($r('sys.color.comp_background_primary'))
  .borderRadius(32)
}
