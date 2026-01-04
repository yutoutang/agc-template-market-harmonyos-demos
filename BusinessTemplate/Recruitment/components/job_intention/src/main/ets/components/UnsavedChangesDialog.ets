import { ComponentContent } from '@kit.ArkUI'
import { GlobalContext } from '../common/GlobalContext'

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

export interface UnsavedChangesDialogParams {
  onConfirm: () => void
  onCancel: () => void
}

@Builder
function unsavedDialogBuilder(data: UnsavedDialogData) {
  Column() {
    Text('确认退出?')
      .fontSize(18)
      .fontColor($r('sys.color.black'))
      .margin({ top: 24, bottom: 16 })
      .fontWeight(FontWeight.Medium)

    Text('修改内容将不会保存！')
      .fontSize(14)
      .margin({ bottom: 24 })
      .fontColor('#666666')

    Row()
      .width('100%')
      .backgroundColor('#E5E5E5')
      .height(0.5)

    Row() {
      Text('取消')
        .fontSize(16)
        .textAlign(TextAlign.Center)
        .fontColor('#666666')
        .width('50%')
        .padding({ top: 12, bottom: 12 })
        .onClick(() => {
          data.onCancel()
          UnsavedChangesDialogController.closeDialog()
        })

      Row()
        .height(48)
        .width(0.5)
        .backgroundColor('#E5E5E5')

      Text('确认')
        .fontSize(16)
        .textAlign(TextAlign.Center)
        .fontColor('#0A59F7')
        .padding({ top: 12, bottom: 12 })
        .width('50%')
        .onClick(() => {
          data.onConfirm()
          UnsavedChangesDialogController.closeDialog()
        })
    }
    .width('100%')
  }
  .width(280)
  .backgroundColor($r('sys.color.comp_background_list_card'))
  .borderRadius(12)
}

export class UnsavedChangesDialogController {
  private static ctx: UIContext
  private static contentNode: ComponentContent<UnsavedDialogData> | null = null

  static closeDialog() {
    if (UnsavedChangesDialogController.contentNode && UnsavedChangesDialogController.ctx) {
      UnsavedChangesDialogController.ctx.getPromptAction().closeCustomDialog(UnsavedChangesDialogController.contentNode)
      UnsavedChangesDialogController.contentNode = null
    }
  }

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
}

/**
 * 未保存更改确认弹窗组件
 * 用于在用户有未保存的修改时，点击返回按钮时弹出二次确认
 */
@ComponentV2
export struct UnsavedChangesDialog {
  /** 是否显示弹窗 */
  @Param @Require visible: boolean
  /** 确认回调 */
  @Event onConfirm?: () => void
  /** 取消回调 */
  @Event onCancel?: () => void

  build() {
    if (this.visible) {
      Stack() {
        // 半透明背景遮罩
        Column()
          .width('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .position({ x: 0, y: 0 })
          .height('100%')

        // 弹窗内容
        Column() {
          // 标题
          Text('确认退出?')
            .fontSize(18)
            .fontColor('#000000')
            .fontWeight(FontWeight.Medium)
            .margin({ top: 24, bottom: 16 })

          // 提示信息
          Text('修改内容将不会保存！')
            .fontColor('#666666')
            .fontSize(14)
            .margin({ bottom: 24 })

          // 分割线
          Row()
            .height(0.5)
            .width('100%')
            .backgroundColor('#E5E5E5')

          // 按钮区域
          Row() {
            // 取消按钮
            Text('取消')
              .fontSize(16)
              .padding({ top: 12, bottom: 12 })
              .width('50%')
              .fontColor('#666666')
              .textAlign(TextAlign.Center)
              .onClick(() => {
                if (this.onCancel) {
                  this.onCancel()
                }
              })

            // 垂直分割线
            Row()
              .width(0.5)
              .height(48)
              .backgroundColor('#E5E5E5')

            // 确认按钮
            Text('确认')
              .fontColor('#0A59F7')
              .fontSize(16)
              .width('50%')
              .padding({ top: 12, bottom: 12 })
              .textAlign(TextAlign.Center)
              .onClick(() => {
                if (this.onConfirm) {
                  this.onConfirm()
                }
              })
          }
          .width('100%')
        }
        .width(280)
        .borderRadius(12)
        .backgroundColor('#FFFFFF')
      }
      .width('100%')
      .position({ x: 0, y: 0 })
      .height('100%')
      .zIndex(1000)
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
