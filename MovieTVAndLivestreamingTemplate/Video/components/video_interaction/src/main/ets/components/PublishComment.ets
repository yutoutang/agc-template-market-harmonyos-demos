import { promptAction } from '@kit.ArkUI'
import { CommentParams } from '../utils/Utils'
import { FeedCommentVM } from '../viewModel/FeedCommentVM'
import { PopViewUtils } from '../utils/PopViewUtils'

@Builder
export function publishCommentBuilder(commentParams: CommentParams) {
  PublishComment({
    commentParams,
  })
}

@ComponentV2
export struct PublishComment {
  @Require @Param commentParams: CommentParams
  @Local commendText: string = ''
  @Local emojiActive: boolean = false
  @Local keyBordHeight: number = 0
  @Local feedCommentVM: FeedCommentVM = FeedCommentVM.instance;

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        TextArea({
          text: this.commendText,
          placeholder: this.commentParams.reNickName ? `回复 ${this.commentParams.reNickName}` : '发表评论',
        })
          .fontColor($r('sys.color.font_primary'))
          .fontSize(14 * this.feedCommentVM.fontSizeRatio)
          .placeholderFont({
            size: 14 * this.feedCommentVM.fontSizeRatio,
          })
          .constraintSize({
            minHeight: 40,
          })
          .defaultFocus(true)
          .padding({ left: 16 })
          .borderRadius(24)
          .onChange((value) => {
            this.commendText = value;
          })
          .width('85%')
        Column() {
          Image($r('app.media.publish')).width(19).height(19)
        }
        .height(40)
        .width(40)
        .onClick(() => {
          if (this.commendText.trim() === '') {
            promptAction.showToast({ message: '发表内容不能为空' })
            return
          }
          if (this.commendText.length > 50) {
            promptAction.showToast({ message: '评论不能超过50个字，请修改' });
            return;
          }
          this.commentParams?.callback?.(this.commendText)
          PopViewUtils.closeSheet()
          promptAction.showToast({ message: '发表成功' })

        })
        .justifyContent(FlexAlign.Center)
        .borderRadius(40)
        .backgroundColor(this.commendText.trim() === '' ? '#BEC9F0' : '#5C79D9')
      }

      Row() {
        Text(`${this.commendText.length}/50`)
          .fontSize(12)
          .fontColor(this.commendText.length > 50 ? '#FF0000' : '#999999')
          .margin({ top: 4, right: 16 })
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
    }.padding(16)
  }
}