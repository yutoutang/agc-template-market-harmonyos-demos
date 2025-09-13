import { CommentUtils } from '../utils/CommentUtils'
import { FeedCommentVM } from '../viewmodel/FeedCommentVM'

@ComponentV2
export struct CommentOperation {
  @Param commentCount: number = 0
  @Param markCount: number = 0
  @Param shareCount: number = 0
  @Param isMarked: boolean = false
  @Param fontSizeRatio: number = 1
  @Param isDark: boolean = false
  @Local isShowComment: boolean = false
  @Event $isMarked: (value: boolean) => void = () => {
  };
  @Event $markCount: (count: number) => void = () => {
  };
  @Event onComment: (commentContent: string) => void = () => {
  }
  @Event onShare: () => void = () => {
  }
  @Event onMarked: (value: boolean) => void = () => {
  }
  @Event onScrollToComment: () => void = () => {
  }
  @BuilderParam shareBuilder: () => void
  @Local feedCommentVM: FeedCommentVM = FeedCommentVM.instance;

  @Monitor('fontSizeRatio')
  fontSizeRatioChange() {
    this.feedCommentVM.setFontSizeRatio(this.fontSizeRatio)
  }

  @Computed
  get getDarkLike() {
    return this.isDark ? $r('app.media.comment_like_active_dark') : $r('app.media.comment_like_active')
  }

  aboutToAppear(): void {
    this.fontSizeRatioChange()
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row({ space: 5 }) {
        Text('发表评论').fontSize(16 * this.fontSizeRatio).fontColor($r('sys.color.font_secondary'))
      }
      .justifyContent(FlexAlign.Start)
      .padding({ left: 12, top: 12, bottom: 12 })
      .borderRadius(24)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        CommentUtils.commentSheetOpen(null, (commentContent: string) => {
          this.onComment(commentContent)
        })
      })
      .width('45%')
      .flexGrow(1)

      Row() {
        Column({ space: 5 }) {
          Image($r('app.media.message_active')).width(22).height(21).fillColor($r('sys.color.font_primary'))
          Text(CommentUtils.formatToK(this.commentCount))
            .fontSize(10 * this.fontSizeRatio)
            .fontColor($r('sys.color.font_primary'))
        }
        .accessibilityText('评论' + CommentUtils.formatToK(this.commentCount))
        .onClick(() => {
          this.onScrollToComment()
        })
        .margin({ right: 24 })

        Column({ space: 5 }) {
          Image(this.isMarked ? $r('app.media.comment_like') : this.getDarkLike)
            .width(22)
            .height(21)
          Text(CommentUtils.formatToK(this.markCount))
            .fontSize(10 * this.fontSizeRatio)
            .fontColor($r('sys.color.font_primary'))
        }
        .accessibilityText('收藏' + CommentUtils.formatToK(this.markCount))
        .onClick(() => {
          this.onMarked(!this.isMarked)
        })
        .margin({ right: 24 })

        if (this.shareBuilder) {
          this.shareBuilder()
        } else {
          Column({ space: 5 }) {
            Image($r('app.media.share_active'))
              .width(21)
              .height(21)
              .fillColor($r('sys.color.font_primary'))
            Text(CommentUtils.formatToK(this.shareCount))
              .fontSize(10 * this.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
          }
          .accessibilityText('分享' + CommentUtils.formatToK(this.shareCount))
          .onClick(() => {
            this.onShare()
          })
        }
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ left: 16 })
    }
  }
}