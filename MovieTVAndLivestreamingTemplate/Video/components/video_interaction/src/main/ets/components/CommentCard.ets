import dayjs from 'dayjs'
import { BuilderParams, CommentInfo } from '../model/Model'
import { CommentEventDispatcher } from '../utils/EventDispatcher'
import { commentSheetOpen } from '../utils/Utils'
import { FeedCommentVM } from '../viewModel/FeedCommentVM'
import { confirmDialogView } from './PressAction'
import { promptAction } from '@kit.ArkUI'
import { PopViewUtils } from '../utils/PopViewUtils'

@ComponentV2
export struct CommentCard {
  @Require @Param commentInfo: CommentInfo
  @Param articleInfo: CommentInfo = new CommentInfo()
  @Param navPathStack: NavPathStack = new NavPathStack()
  @Param isDark: boolean = false
  @BuilderParam replyComponentBuilder: () => void;
  @BuilderParam totalCommentBuilder: () => void;
  @Event onDeleteComment: (commentId: string) => void = () => {
  }
  @Local feedCommentVM: FeedCommentVM = FeedCommentVM.instance;
  @Param isNeedReply: boolean = false
  private customDialogComponentId: number = 0

  @Computed
  get getDarkLike() {
    return this.isDark ? $r('app.media.give_like_dark') : $r('app.media.give_like')
  }

  @Builder
  customDialogComponent() {
    Column() {
      Text('是否删除此评论')
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      Row({ space: 50 }) {
        Button('取消').onClick(() => {
          promptAction.closeCustomDialog(this.customDialogComponentId)
        })
          .backgroundColor(Color.Transparent)
          .fontColor($r('sys.color.font_primary'))
        Button('删除').onClick(() => {
          this.onDeleteComment(this.commentInfo.commentId)
          CommentEventDispatcher.dispatchToDeleteComment(this.commentInfo.commentId)
          PopViewUtils.closePopView()
          promptAction.closeCustomDialog(this.customDialogComponentId)
        })
          .backgroundColor(Color.Transparent)
          .fontColor($r('sys.color.warning'))
      }
    }.height(120).padding({ top: 32, bottom: 8 }).justifyContent(FlexAlign.SpaceBetween)
  }

  @Computed
  get isReplyShow() {
    return this.commentInfo.parentComment?.author?.authorNickName && this.isNeedReply &&
      this.commentInfo.parentComment.author.authorNickName !== this.articleInfo.author.authorNickName
  }

  pressReply = () => {
    PopViewUtils.closePopView()
    commentSheetOpen(this.commentInfo.author.authorNickName, (replyContent: string) => {
      this.feedCommentVM.addComment(this.commentInfo, replyContent, true)
    })
  }
  pressDelete = () => {
    promptAction.openCustomDialog({
      builder: () => {
        this.customDialogComponent()
      },
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        if (dismissDialogAction.reason !== DismissReason.TOUCH_OUTSIDE) {
          dismissDialogAction.dismiss()
        }
      },
    }).then((dialogId: number) => {
      this.customDialogComponentId = dialogId
    })
  }

  pressCancel() {
    PopViewUtils.closePopView()
  }

  build() {
    Column() {
      Row() {
        Row({ space: 8 }) {
          Stack({ alignContent: Alignment.BottomEnd }) {
            Image(this.commentInfo.author.authorIcon || $r('app.media.icon_default'))
              .width(32)
              .height(32)
              .borderRadius('50%')
              .clip(true)
              .onClick(() => {
                CommentEventDispatcher.dispatchToUserHome(this.commentInfo.author.authorId)
              })
          }

          Text(this.commentInfo.author.authorNickName)
            .fontColor($r('sys.color.font_secondary')).fontSize(12 * this.feedCommentVM.fontSizeRatio)
        }.width('100%').justifyContent(FlexAlign.Start)
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)

      Column() {
        Column({ space: 8 }) {
          Row() {
            Row() {
              Text() {
                Span('回复')
                Span(`@${this.commentInfo.parentComment?.author?.authorNickName}:`)
                  .fontColor($r('app.color.app_theme'))
                  .onClick(() => {
                    const authorId: string = this.commentInfo.parentComment?.author?.authorId as string
                    CommentEventDispatcher.dispatchToUserHome(authorId);
                  })
              }
              .fontSize(14 * this.feedCommentVM.fontSizeRatio)
              .visibility(this.isReplyShow ? Visibility.Visible : Visibility.None)

              Text(this.commentInfo.commentBody).fontColor($r('app.color.common_title_font'))
                .fontColor($r('sys.color.font_primary')).fontSize(14 * this.feedCommentVM.fontSizeRatio)
            }
          }

          Row({ space: 20 }) {
            Text(dayjs(this.commentInfo.createTime).format('YYYY-MM-DD HH:mm'))
              .fontSize(10 * this.feedCommentVM.fontSizeRatio)
              .fontColor($r('sys.color.font_secondary'))
            Text('回复')
              .fontSize(12 * this.feedCommentVM.fontSizeRatio)
              .fontColor($r('app.color.app_theme'))
              .onClick(() => {
                if (!this.commentInfo.isReply) {
                  commentSheetOpen(this.commentInfo.author.authorNickName, (replyContent: string) => {
                    this.feedCommentVM.addComment(this.commentInfo, replyContent, true)
                  })
                }
              }).visibility(this.commentInfo.isReply ? Visibility.None : Visibility.Visible)
            Blank()
            Row({ space: 5 }) {
              Image(this.commentInfo.isLiked ? $r('app.media.give_like_active') : this.getDarkLike)
                .width(16)
                .height(14)
              Text(`${this.commentInfo.commentLikeNum}`)
                .fontSize(10 * this.feedCommentVM.fontSizeRatio)
                .fontColor($r('sys.color.font_secondary'))
            }
            .onClick(() => {
              this.feedCommentVM.giveLike(this.commentInfo, !this.commentInfo.isLiked)
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ top: 9 })

          if (this.replyComponentBuilder) {
            Column() {
              this.replyComponentBuilder()
            }
            .onClick(() => {
              this.navPathStack.pushPathByName('TotalCommentCopy', this.commentInfo)
            })
            .visibility(this.commentInfo.replyComments?.length ?
            Visibility.Visible :
            Visibility.None)
          }
        }.width('100%').alignItems(HorizontalAlign.Start)
        .gesture(
          LongPressGesture({ repeat: false })
            .onAction(() => {
              let builderParams: BuilderParams = {
                reply: this.pressReply,
                delete: this.pressDelete,
                cancel: this.pressCancel,
                isCommentOwner: this.commentInfo.author.authorId === this.feedCommentVM.userInfo.authorId,
                fontSizeRatio: this.feedCommentVM.fontSizeRatio,
                isReply: !!this.commentInfo.isReply
              }
              if (!this.commentInfo.isReply ||
                this.commentInfo.author.authorId === this.feedCommentVM.userInfo.authorId) {
                PopViewUtils.showPopView<BuilderParams>(wrapBuilder(confirmDialogView), {
                  alignment: DialogAlignment.Bottom,
                }, builderParams)
              }
            }),
        )
      }.width('100%').alignItems(HorizontalAlign.Start).padding({ left: 42 })

      if (this.totalCommentBuilder) {
        Column() {
          this.totalCommentBuilder()
        }
        .visibility(this.commentInfo.replyComments?.length ?
        Visibility.Visible :
        Visibility.None)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ top: 8 })
  }
}