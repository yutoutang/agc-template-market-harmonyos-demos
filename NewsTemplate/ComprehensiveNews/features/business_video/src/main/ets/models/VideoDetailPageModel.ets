import { AbilityConstant, common } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { ContinueModel, Logger, RouterMap, RouterUtils } from 'lib_common';
import { MineServiceApi, NewsEnum } from 'lib_news_api';
import { AVPlayerManager, AVPlayerSession, SwipePlayerController } from 'module_swipeplayer';
import { LongTakeAnimationProperties, LongTakeTransitionParam } from 'module_transition';
import { VideoService } from '../services/VideoService';
import { BaseParamType } from '../types/Index';
import { VideoSwipePageVM } from '../viewmodels/VideoSwipePageVM';

const TAG = '[VideoDetailPageModel]';

@ObservedV2
export class VideoDetailPageModel extends VideoSwipePageVM {
  // 滑动播放控制器
  swipePlayerController: SwipePlayerController = new SwipePlayerController();
  avPlayerManager: AVPlayerManager = new AVPlayerManager();
  videoItemPlayerSession: AVPlayerSession | undefined;
  // 用户
  userId: string = '';
  // 视频列表总数
  totalCount: number = 0;
  // 是否需要无限滚动
  isInfiniteScroll: boolean = false;
  // 页面上手势滑动距离
  @Trace offsetX: number = 0;
  @Trace continueModel: ContinueModel = AppStorageV2.connect(ContinueModel, () => new ContinueModel())!;
  // 是否需要释放播放资源
  @Trace needReleasePlayer: boolean = true
  // 页面是否显示
  @Trace isShown: boolean = false;
  @Trace needLongTake: boolean = true;

  initAVPlayerMgr(param: Record<string, string | number | AVPlayerSession | undefined | Object>) {
    let playerSession = param.playerSession as AVPlayerSession
    if (playerSession) {
      this.videoItemPlayerSession = playerSession
      this.needReleasePlayer = false
      this.needLongTake = false;
    }
    if (!param.longTakeTransitionParam) {
      this.needLongTake = false;
    }
    this.swipePlayerController.setAVPlayerMgr(this.avPlayerManager)
  }

  async initVideoListDataSource(param: Record<string, string | number | AVPlayerSession | undefined | Object>) {
    const videoId = param.newsId as string;
    this.userId = param.authorId as string;
    this.isInfiniteScroll = !this.userId;
    let type = param.type as number;
    let videoList = await VideoService.queryVideoList(this.userId || '', type);
    if (videoId) {
      videoList = videoList.filter((item) => item.id !== videoId);
      const videoDetailInfo = await VideoService.queryVideoDataById(videoId);
      if (videoDetailInfo) {
        videoList.unshift(videoDetailInfo);
      }
    }
    // 模拟无限上滑
    this.totalCount = this.isInfiniteScroll ? Number.POSITIVE_INFINITY : videoList.length;
    this.videoDataSources.setData(videoList);
  }

  // 处理swiper动画开始事件
  async handleSwiperAnimationStart(_index: number, targetIndex: number) {
    let totalNum = this.videoDataSources.totalCount();
    // 加载更多，无限上滑
    if (this.isInfiniteScroll || totalNum < this.totalCount) {
      if (totalNum - targetIndex <= 5) {
        let videoList = await VideoService.queryVideoList(this.userId);
        this.videoDataSources.pushDataArray(...videoList);
        this.totalCount = this.videoDataSources.totalCount();
      }
    }
  }

  // 处理从右向左滑的手势事件
  handleSwiperRightAction() {
    if (this.offsetX < 0) {
      const idx = this.swipePlayerController.curentIndex;
      const data = this.videoDataSources.getData(idx);
      const userId = data?.author?.authorId;
      if (userId) {
        RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, userId);
      }
    }
  }

  // 监听播放状态
  onPlayerStateListen(state: string, id: string) {
    if (state === 'playing') {
      this.addHistoryList(id)
      this.videoSeek();
    }
  }

  // 添加到历史记录
  addHistoryList(id: string) {
    MineServiceApi.addToHistory(id);
  }

  // 设置播放进度
  videoSeek() {
    if (!this.continueModel.isTargetDevice) {
      return;
    }
    // 对端还原参数
    if (this.continueModel.playerProgress) {
      this.swipePlayerController.seek(this.continueModel.playerProgress);
      Logger.info(TAG, 'onPlayerStateListen seek: ' + this.continueModel.playerProgress);
    }
    this.continueModel.isTargetDevice = false;
  }

  // 开启迁移能力
  enableContinue(context: common.UIAbilityContext) {
    context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE).then(() => {
      Logger.info(TAG, 'setMissionContinueState ACTIVE result: ACTIVE');
    }).catch((e: BusinessError) => {
      Logger.error(TAG, 'setMissionContinueState fail, error: ' + JSON.stringify(e));
    });
  }

  // 设置流转数据
  setContinueData(id: string, progress: number) {
    if (this.continueModel.isTargetDevice) {
      return;
    }
    // 源端保存参数
    this.continueModel.newsId = id;
    this.continueModel.newsType = NewsEnum.Video;
    this.continueModel.playerProgress = progress;
    this.continueModel.breakpoint = this.breakPointModel.currentBreakpoint;
    Logger.debug(TAG, 'continueModel avPlayer progress: ' + this.continueModel.playerProgress);
  }

  // 初始化一镜到底参数
  registerCustomTransition(param: Record<string, AVPlayerSession | BaseParamType | Object>,
    longTakeSession: LongTakeAnimationProperties, context: NavDestinationContext) {
    let longTakeTransitionParam: LongTakeTransitionParam | undefined = undefined;
    longTakeTransitionParam = param.longTakeTransitionParam as LongTakeTransitionParam;
    if (longTakeTransitionParam) {
      longTakeSession.init(context, longTakeTransitionParam, {
        pop: () => {
          context.pathStack.pop()
        },
      });
    }
  }
}