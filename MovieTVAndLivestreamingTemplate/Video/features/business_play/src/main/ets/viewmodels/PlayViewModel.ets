import { AppStorageV2, PersistenceV2, UIUtils } from '@kit.ArkUI';
import { BaseViewModel, Logger } from 'lib_common';
import {
  CommentServiceApi,
  HistoryModel,
  HistoryResponse,
  MineServiceApi,
  PublishCommentRequest,
  VideoResponse,
  VideoServiceApi
} from 'lib_video_api';
import { JSON, util } from '@kit.ArkTS';
import { MovieItem, PlayerVM } from 'recorded_player';
import { CommentInfo, MakeObCommentServed, QueueDownloader } from 'video_interaction';
import { CastService } from 'module_cast';
import { CastSessionListenerImpl } from '../utils/CastSessionListenerImpl';
import { common } from '@kit.AbilityKit';
import { LoginSheetUtils } from 'lib_account';


const TAG = 'PlayViewModel'

@ObservedV2
export class PlayViewModel extends BaseViewModel {
  @Trace videoInfo: VideoResponse = {} as VideoResponse;
  @Trace recommendVideoList: VideoResponse[] = []
  history: HistoryModel = AppStorageV2.connect(HistoryModel, () => new HistoryModel())!;
  @Trace playerVM: PlayerVM = PlayerVM.instance;
  videoItems: MovieItem[] = [];
  @Trace isLayoutFullScreen: boolean = false;
  @Trace totalTime: number = 0
  @Trace playTime: number = 0
  @Trace queueDownloader: QueueDownloader =
    PersistenceV2.connect(QueueDownloader, () => new QueueDownloader(getContext()))!;
  @Trace castService: CastService = CastService.getInstance()
  @Trace listener: CastSessionListenerImpl = new CastSessionListenerImpl()
  // 评论
  @Trace commentList: CommentInfo[] = [];

  init(videoId: string, index: number) {
    // 开启投屏
    this.castService.init(getContext() as common.UIAbilityContext)
    // 投屏监听
    this.castService.registerSessionListener(this.listener)

    Logger.info(TAG, `videoId: ${videoId}, index: ${index}`);
    // 关键：等待异步接口返回结果（假设 queryVideoDetail 返回 Promise）
    const videoInfo = VideoServiceApi.queryVideoDetail(videoId) as VideoResponse
    // 设置视频信息（确保响应式）
    this.videoInfo = UIUtils.makeObserved(videoInfo)

    // 转换视频播放路径为播放器可识别的 model
    videoInfo.videoUrl.forEach((url, index) => {
      let progress: number = 0
      if (videoInfo.currentEpisode === index) {
        progress = videoInfo.currentProgress
      }

      this.videoItems.push(new MovieItem(
        videoInfo.videoId + index,
        `第${index + 1}集`,
        progress,
        this.filterUri(url as string),
        videoInfo.coverUrl
      ));
      this.listener.videoList.push({
        index: index,
        url: url as string,
        name: `第${index + 1}集`,
        head: videoInfo.coverUrl,
        duration: videoInfo.urlDuration?.[index] || 100000
      })
    });
    // 播放当前集
    this.listener.currentIndex = index ?? (videoInfo?.currentEpisode || 0)

    //同步投屏数据，设置投屏信息
    setTimeout(() => {
      this.castService.setAVMetadata(this.listener.videoList[0], this.listener.videoList[0]?.duration)
      this.castService.play()
    }, 100)

    // 获取相关推荐（若也是异步，需加 await）
    this.recommendVideoList = VideoServiceApi.queryRecommendVideo(videoInfo);
    Logger.info(TAG, `videoInfo: ${JSON.stringify(this.videoInfo)}`);
    // 获取评论
    let commentInfo = CommentServiceApi.queryCommentList(videoId) as CommentInfo[]
    this.commentList = commentInfo?.map((value: CommentInfo) => {
      return new MakeObCommentServed(value)
    }) ?? [];
  }

  /**
   * 增加播放历史
   */
  addHistory() {
    // 历史中存在，就移除
    const index = this.history.historyList.findIndex((item) => {
      return item.videoId === this.videoInfo.videoId && item.url === this.videoInfo.videoUrl[this.listener.currentIndex]
    })
    if (index > -1) {
      this.history.historyList.splice(index, 1)
    }
    // 在添加到历史
    const history: HistoryResponse = {
      historyId: Date.now().toString(36) + util.generateRandomUUID().replace(/-/g, '').substring(2, 15),
      videoId: this.videoInfo.videoId,
      videoInfo: this.videoInfo,
      url: this.videoInfo.videoUrl[this.listener.currentIndex],
      sectionNo: this.listener.currentIndex,
      totalTime: this.totalTime,
      playTime: this.playTime,
      time: new Date()
    }
    this.history.historyList.unshift(history)
  }

  saveSectionNoAndTime() {
    VideoServiceApi.saveCurrentInfo(this.videoInfo.videoId, this.listener.currentIndex,
      this.playTime / this.totalTime * 100)
  }

  filterUri(currentUrl: string): string {
    const tasks = this.queueDownloader.tasks.find((item) => {
      return item.videoId === this.videoInfo.videoId && item.url.url === currentUrl && item.status === 'completed'
    })
    if (tasks && tasks.uri) {
      return tasks.uri
    }
    return currentUrl
  }

  getUserInfo() {
    return this.userInfoModel
  }

  public addSingleComment(comment: CommentInfo, parentCommentId: string) {
    const params: PublishCommentRequest = {
      videoId: comment.videoId,
      content: comment.commentBody,
      parentCommentId: parentCommentId,
    };
    MineServiceApi.publishComment(params)
  }

  public async addNewsComment(commentContent: string) {
    this.videoInfo.commentCount++
    const params: PublishCommentRequest = {
      videoId: this.videoInfo.videoId,
      content: commentContent,
      parentCommentId: '',
    };
    let addComment = await MineServiceApi.publishComment(params) as CommentInfo
    this.commentList.unshift(new MakeObCommentServed(addComment))
  }

  // 点赞评论
  public addLike(comment: CommentInfo, isLike: boolean) {
    if (!this.userInfoModel.isLogin) {
      LoginSheetUtils.open()
      return
    }
    this.setCommentInfo(this.commentList, comment, isLike)
    if (comment.isLiked) {
      CommentServiceApi.addCommentLike(comment.commentId)
      return
    }
    CommentServiceApi.cancelCommentLike(comment.commentId)
  }

  public setCommentInfo(commentInfoList: CommentInfo[], comment: CommentInfo, isLike: boolean) {
    if (commentInfoList.length) {
      commentInfoList.forEach(item => {
        if (item.commentId === comment.commentId) {
          item.isLiked = isLike
          item.commentLikeNum = isLike ? item.commentLikeNum + 1 : item.commentLikeNum - 1
        }
        this.setCommentInfo(item.replyComments, comment, isLike)
      })
    }
  }

  deleteComment(commentId: string) {
    CommentServiceApi.deleteComment(commentId)
  }
}