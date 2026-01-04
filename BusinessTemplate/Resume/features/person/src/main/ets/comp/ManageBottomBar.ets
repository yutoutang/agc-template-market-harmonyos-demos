import { BreakpointModel } from 'common'
import { AppStorageV2 } from '@kit.ArkUI'

/**
 * 管理模式底部操作栏组件
 * 包含全选和删除按钮
 */
@ComponentV2
export struct ManageBottomBar {
  // 当前选中的数量
  @Param selectedCount: number = 0
  // 总数量
  @Param totalCount: number = 0
  // 全选按钮点击回调
  @Param @Require onSelectAll?: () => void
  // 删除按钮点击回调
  @Param @Require onDelete?: () => void
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  build() {
    Stack() {
      // 背景层：使用负 margin 突破父容器 padding，覆盖全屏宽度
      Row()
        .width(`calc(100% + ${this.breakPointModel.pagePadding * 2}vp)`)
        .height(60)
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .margin({ left: -this.breakPointModel.pagePadding, right: -this.breakPointModel.pagePadding })

      // 内容层：保持安全边距
      Row() {
        Column() {
          Image($r('app.media.ic_selectAll'))
            .width(24)
          Text('全选')
            .fontSize(10)
            .lineHeight(12)
            .fontColor($r('sys.color.font_primary'))
            .margin({ top: 2 })
        }
        .onClick(() => {
          this.onSelectAll?.()
        })

        Column() {
          Image($r('app.media.ic_public_delete'))
            .width(24)
          Text('删除')
            .fontSize(10)
            .lineHeight(12)
            .fontColor($r('sys.color.font_primary'))
            .margin({ top: 2 })
        }
        .margin({ left: 28 })
        .onClick(() => {
          this.onDelete?.()
        })
      }
      .width('100%')
      .height(60)
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .height(60)
  }
}
