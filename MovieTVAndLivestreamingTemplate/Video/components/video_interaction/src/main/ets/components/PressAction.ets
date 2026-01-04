import { BuilderParams } from '../model/Model'

@Builder
export function confirmDialogView(builderParams: BuilderParams) {
  Column({ space: 25 }) {
    Column() {
      Text('回复')
        .fontWeight(FontWeight.Medium)
        .fontSize(16 * builderParams.fontSizeRatio ?? 1)
        .fontColor($r('sys.color.font_primary'))
    }
    .width('100%')
    .onClick(() => {
      builderParams.reply()
    })
    .visibility(builderParams.isReply ? Visibility.None : Visibility.Visible)

    Column() {
      Text('删除')
        .fontSize(16 * builderParams.fontSizeRatio ?? 1)
        .fontWeight(FontWeight.Medium)
        .fontColor('#E63E24')
    }
    .width('100%')
    .onClick(() => {
      builderParams.delete()
    })
    .visibility(builderParams.isCommentOwner ? Visibility.Visible : Visibility.None)

    Column() {
      Text('取消')
        .fontSize(16 * builderParams.fontSizeRatio ?? 1)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
    }
    .width('100%')
    .onClick(() => {
      builderParams.cancel()
    })
  }
  .borderRadius(32)
  .margin({ left: 16, right: 16, bottom: 16 })
  .padding(16)
  .width('100%')
  .backgroundColor($r('sys.color.background_primary'))
}
