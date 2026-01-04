import { Share } from 'module_share'
import { MediaItemModel } from '../model/MediaItemModel'
import { DownloadView } from './DownloadView'
import { FeedComment } from '../views/FeedComment'
import { CommentInfo, UserInfoModel } from '../model/Model'
import { CommonConstants } from '../constants/CommonConstants'
import { commentSheetOpen } from '../utils/Utils'
import { TopBottomModel } from '../model/TopBottomModel'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct VideoInteraction {
  context: Context = this.getUIContext().getHostContext() as Context
  @Param windowBottomPadding: number = 0
  @Local topBottom: TopBottomModel = AppStorageV2.connect(TopBottomModel, () => new TopBottomModel())!;
  @Require @Param mediaItem: MediaItemModel
  @Event changeIsLike?: (isLike: boolean) => void
  @Event changeIsMark?: (isMark: boolean) => void
  @Local commentShowSheet: boolean = false
  @Local isShowKeyboard: boolean = false
  @Local downloadShowSheet: boolean = false
  @Event goDownloadPage?: () => void
  @Local isShowComment: boolean = false
  @BuilderParam shareRenderBuilder: () => void;
  @Provider() navPathStack: NavPathStack = new NavPathStack();
  @Provider() showKeyboard: boolean = this.isShowKeyboard;
  @Require @Param commentList: CommentInfo[] = []
  @Require @Param userInfo: UserInfoModel = new UserInfoModel()
  @Event addComment: (commentInfo: CommentInfo, parentCommentId: string) => void = () => {
  };
  @Event giveLike: (commentInfo: CommentInfo, isLike: boolean) => void = () => {
  };
  @Event onGoAuthorInfo: (authorId: string) => void = () => {
  };
  @Event onInterceptLogin: (cb: (isLogin: boolean) => void) => void = () => {
  };
  @Event onDeleteComment: (commentId: string) => void = () => {
  };
  @Event onFirstComment: (commentContent: string) => void = () => {
  }

  aboutToAppear(): void {
    this.topBottom.windowBottomPadding = this.windowBottomPadding
  }

  @Monitor('isShowComment')
  onChangeShowComment(monitor: IMonitor) {
    if (!(monitor.value()?.now as boolean)) {
      this.isShowKeyboard = false
    }
  }

  build() {
    GridRow({
      columns: 5,
      direction: GridRowDirection.Row
    }) {
      GridCol() {
        Stack() {
          Image($r('app.media.icon_tv_comment'))
            .width(24)
            .height(24)
          Text(this.mediaItem.commentCount.toString())
            .fontSize(10)
            .lineHeight(12)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .position({ top: -8, left: 18 })
            .visibility(this.mediaItem.commentCount ? Visibility.Visible : Visibility.None)
        }
        .bindSheet($$this.isShowComment, this.commentViewBuilder(), {
          height: SheetSize.MEDIUM,
          dragBar: false,
          blurStyle: BlurStyle.Thick,
          showClose: true,
          mode: SheetMode.EMBEDDED,
          maskColor: Color.Transparent,
          backgroundColor: $r('sys.color.background_secondary'),
          preferType: SheetType.CENTER,
          onWillDismiss: (action: DismissSheetAction) => {
            action.dismiss()
            this.navPathStack.clear()
          }
        })
        .onClick(() => {
          this.isShowComment = !this.isShowComment;
        })
      }

      GridCol() {
        Stack() {
          if (this.mediaItem.isLike) {
            Image($r('app.media.icon_tv_like_active'))
              .width(24)
              .height(24)
          } else {
            Image($r('app.media.icon_tv_like'))
              .width(24)
              .height(24)
              .colorFilter(Color.White)
          }
          Text(this.mediaItem.likeCount.toString())
            .fontSize(10)
            .lineHeight(12)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .position({ top: -8, left: 18 })
            .visibility(this.mediaItem.likeCount ? Visibility.Visible : Visibility.None)
        }.onClick(() => {
          this.changeIsLike?.(!this.mediaItem.isLike)
        })
      }

      GridCol() {
        Stack() {
          Image(this.mediaItem.isMark ? $r('app.media.icon_tv_collect_active') : $r('app.media.icon_tv_collect'))
            .width(24)
            .height(24)
        }.onClick(() => {
          this.changeIsMark?.(!this.mediaItem.isMark)
        })
      }

      GridCol() {
        Stack() {
          Image($r('app.media.icon_tv_download')).width(24).height(24)
        }
        .bindSheet(this.downloadShowSheet, this.downloadSheet(), {
          height: SheetSize.MEDIUM,
          dragBar: false,
          preferType: SheetType.CENTER
        })
        .onClick(() => {
          this.downloadShowSheet = !this.downloadShowSheet;
        })
      }

      GridCol() {
        Share({
          qrCodeInfo: {
            id: this.mediaItem.videoId,
            type: this.mediaItem.type,
            title: this.mediaItem.title,
            createTime: this.mediaItem.createTime,
            coverUrl: this.mediaItem.coverUrl,
            isVideo: true
          },
          shareRenderBuilder: () => {
            this.shareCommentBuilder()
          },
        })
      }
    }
  }

  @Builder
  shareCommentBuilder() {
    Stack() {
      Column({ space: 4 }) {
        Image($r('app.media.icon_tv_share'))
          .width(24)
          .height(24)
      }
    }
  }

  @Builder
  downloadSheet() {
    DownloadView({
      mediaItem: this.mediaItem,
      goDownloadPage: this.goDownloadPage,
      exitDownloadShow: () => {
        this.downloadShowSheet = false
      }
    })
  }

  @Builder
  commentViewBuilder() {
    Navigation(this.navPathStack) {
      Column() {
        Column() {
          FeedComment({
            commentList: this.commentList,
            userInfo: this.userInfo,
            navPathStack: this.navPathStack,
            commentTopViewBuilder: () => {
              this.commentTopView()
            },
            addComment: (comment: CommentInfo, parentCommentId: string) => {
              this.addComment(comment, parentCommentId)
            },
            onFirstComment: (commentContent: string) => {
              this.onFirstComment(commentContent)
            },
            giveLike: (comment: CommentInfo, isLike: boolean) => {
              this.giveLike(comment, isLike)
            },
            onInterceptLogin: (loginInterceptCb: (isLogin: boolean) => void) => {
              this.onInterceptLogin(loginInterceptCb)
            },
            onDeleteComment: (commentId: string) => {
              this.onDeleteComment(commentId)
            }
          })
        }
        .width(CommonConstants.FULL_PERCENT)
        .padding({
          left: CommonConstants.PADDING_L,
          right: CommonConstants.PADDING_L,
        })
        .layoutWeight(1)

        Row() {
          Text('发表评论')
            .fontSize(16)
            .fontColor($r('sys.color.font_primary'))
            .layoutWeight(1)
            .height(40)
            .borderRadius(24)
            .padding({
              left: CommonConstants.PADDING_M,
              top: CommonConstants.PADDING_S,
              right: CommonConstants.PADDING_M,
              bottom: CommonConstants.PADDING_S,
            })
            .backgroundColor($r('app.color.comment_input_bg'))
            .onClick(() => {
              commentSheetOpen(null, (commentContent: string) => {
                this.onFirstComment(commentContent)
              })
            })
        }
        .width(CommonConstants.FULL_PERCENT)
        .padding({
          top: CommonConstants.PADDING_S,
          left: CommonConstants.PADDING_PAGE,
          right: CommonConstants.PADDING_PAGE,
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({ top: CommonConstants.PADDING_PAGE, bottom: this.topBottom.windowBottomPadding })
      .alignItems(HorizontalAlign.Start)
    }
    .hideTitleBar(true)
  }

  @Builder
  commentTopView() {
    Row() {
      Text(this.commentList.length + '条评论')
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(700)
        .lineHeight(26)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      top: CommonConstants.PADDING_M,
      bottom: CommonConstants.PADDING_M,
    })
  }
}
