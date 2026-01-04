import { BreakpointModel, BreakpointNameEnum, CommonConstants, RouterMap, RouterUtils } from 'lib_common';
import { CommentServiceApi, ContentType, VideoServiceApi } from 'lib_video_api';
import { CommentInfo, MakeObCommentServed, MediaItemModel, VideoInteraction } from 'video_interaction';
import { MoreRecommendView } from '../components/MoreRecommendView';
import { SelectTvView } from '../components/SelectTvView';
import { VideoInfoView } from '../components/VideoInfoView';
import { PlayViewModel } from '../viewmodels/PlayViewModel';
import { PlayerComponent } from 'recorded_player';
import { LoginSheetUtils } from 'lib_account';
import { AppStorageV2, promptAction } from '@kit.ArkUI';

@Builder
export function PlayPageBuilder() {
  PlayPage()
}

@ComponentV2
struct PlayPage {
  @Local vm: PlayViewModel = new PlayViewModel();
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  build() {
    NavDestination() {
      Column() {
        // 播放器
        Stack() {
          PlayerComponent({
            movieItems: this.vm.videoItems,
            playerIndex: this.vm.listener.currentIndex,
            fullScreen: (isLayoutFullScreen: boolean) => {
              this.vm.isLayoutFullScreen = isLayoutFullScreen
            },
            callbackTimeUpdate: (nol: number, total: number) => {
              this.vm.totalTime = total
              this.vm.playTime = nol
            },
            selectionEvent: (idx: number) => {
              this.vm.listener.currentIndex = idx
              this.vm.castService.setAVMetadata(this.vm.listener.videoList[idx],
                this.vm.listener.videoList[idx]?.duration)
              this.vm.castService.play()
            },
            listenVideoEvent: (bool) => {
              // todo 听视频功能待完善
            },
            playerPauseAndPlay: (bool) => {
              if (bool) {
                // 播放
                this.vm.castService.play()
              } else {
                //暂停
                this.vm.castService.pause()
              }
            }
          })
            .width('100%')
            .height(this.vm.isLayoutFullScreen ? '100%' :
              this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM ? 238 : 416)
            .clip(true)

          Image($r('app.media.icon_back_white'))
            .width(40)
            .height(40)
            .margin({ left: 16, top: 4 })
            .visibility(this.vm.isLayoutFullScreen ? Visibility.None : Visibility.Visible)
            .onClick(() => {
              RouterUtils.pop()
            })
        }.alignContent(Alignment.TopStart)

        // 视频内容
        Scroll() {
          Column({ space: 25 }) {
            // 视频信息
            VideoInfoView({ video: this.vm.videoInfo })
            // 视频交互组件
            VideoInteraction({
              windowBottomPadding: this.vm.windowModel.windowBottomPadding,
              mediaItem: new MediaItemModel({
                videoId: this.vm.videoInfo.videoId,
                type: this.vm.videoInfo.contentType,
                title: this.vm.videoInfo.title,
                coverUrl: this.vm.videoInfo.coverUrl,
                videoUrl: this.vm.videoInfo.videoUrl,
                createTime: this.vm.videoInfo.createTime,
                isLike: this.vm.videoInfo.isLiked,
                likeCount: this.vm.videoInfo.likeCount,
                isMark: this.vm.videoInfo.isMarked,
                commentCount: this.vm.videoInfo.commentCount,
              }),
              commentList: this.vm.commentList,
              userInfo: this.vm.getUserInfo(),
              addComment: (comment: CommentInfo, parentCommentId: string) => {
                this.vm.addSingleComment(comment, parentCommentId)
              },
              onFirstComment: (commentContent: string) => {
                this.vm.addNewsComment(commentContent)
              },
              giveLike: (comment: CommentInfo, isLike: boolean) => {
                this.vm.addLike(comment, isLike)
              },
              onInterceptLogin: (loginInterceptCb: (isLogin: boolean) => void) => {
                if (!this.vm.userInfoModel.isLogin) {
                  LoginSheetUtils.open()
                  return
                }
                loginInterceptCb(this.vm.userInfoModel.isLogin)
              },
              onDeleteComment: (commentId: string) => {
                this.vm.deleteComment(commentId)
                let commentInfo = CommentServiceApi.queryCommentList(this.vm.videoInfo.videoId) as CommentInfo[]
                this.vm.commentList = commentInfo?.map((value: CommentInfo) => {
                  return new MakeObCommentServed(value)
                }) ?? [];
                promptAction.showToast({
                  message: '已删除评论'
                })
              },
              changeIsLike: (isLiked) => {
                if (!this.vm.userInfoModel.isLogin) {
                  LoginSheetUtils.open()
                  return
                }
                this.vm.videoInfo.isLiked = isLiked
                if (isLiked) {
                  promptAction.showToast({
                    message: '已点赞',
                  })
                  this.vm.videoInfo.likeCount++
                } else {
                  promptAction.showToast({
                    message: '取消点赞'
                  })
                  this.vm.videoInfo.likeCount--
                }
                VideoServiceApi.changeLike(this.vm.videoInfo.videoId, isLiked)
              },
              changeIsMark: (isMarked) => {
                if (!this.vm.userInfoModel.isLogin) {
                  LoginSheetUtils.open()
                  return
                }
                this.vm.videoInfo.isMarked = isMarked
                if (isMarked) {
                  promptAction.showToast({
                    message: '已收藏',
                  })
                  this.vm.videoInfo.markCount++
                } else {
                  promptAction.showToast({
                    message: '取消收藏'
                  })
                  this.vm.videoInfo.markCount--
                }
                VideoServiceApi.changeMark(this.vm.videoInfo.videoId, isMarked)
              },
              goDownloadPage: () => {
                RouterUtils.pushPathByName(RouterMap.MINE_CACHE_PAGE)
              }
            })

            // 选集
            if (this.vm.videoInfo.contentType === ContentType.TvMovie) {
              SelectTvView({
                video: this.vm.videoInfo,
                currentIndex: this.vm.listener.currentIndex,
                playVideo: (index: number) => {
                  this.vm.listener.currentIndex = index
                }
              })
            }

            // 更多推荐
            MoreRecommendView({ recommendVideoList: this.vm.recommendVideoList })

          }.alignItems(HorizontalAlign.Start)
          .padding({ top: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .padding(this.vm.isLayoutFullScreen ? 0 :
        { bottom: this.vm.windowModel.windowBottomPadding, top: this.vm.windowModel.windowTopPadding })
    }
    .id(this.vm.playerVM.navId)
    .hideTitleBar(true)
    .backgroundColor('#16151A')
    .onReady((context: NavDestinationContext) => {
      if (context.pathInfo.param) {
        const params = context.pathInfo.param as Record<string, Object>;
        const videoId = params.videoId as string;
        const index = params.index as number
        // 默认（第一集）
        this.vm.init(videoId, index)
      }
    })
    .onWillDisappear(() => {
      this.vm.addHistory()
      this.vm.saveSectionNoAndTime()

    })
  }
}