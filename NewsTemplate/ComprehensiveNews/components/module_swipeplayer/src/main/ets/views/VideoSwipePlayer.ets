import { deviceInfo, emitter } from '@kit.BasicServicesKit';
import { display, uiObserver, window } from '@kit.ArkUI';
import { SwipePlayerController } from '../controller/SwipePlayerController';
import { PlayerDataSource } from '../datasource/PlayerDataSource';
import { AVPlayerSession } from '../controller/AVPlayerManager';
import { VideoPlayerView } from '../components/VideoPlayerView';
import { AVPlayerState, BreakpointNameEnum, PageNameEnum, VideoPlayerData } from '../type/Index';
import { isDisplayModeFull, setOrientation, toast } from '../utils/Util';
import { PlayerLayoutSize } from '../controller/PlayerLayoutSize';
import { VideoNetworkModel, VideoNetworkSetting } from '../models/VideoNetworkModel';
import { BreakpointModel } from '../models/BreakpointModel';

@ComponentV2({ freezeWhenInactive: true })
export struct VideoSwipePlayer {
  // 当前视频索引
  @Local currentIndex: number = 0;
  // 播放控制器
  @Param swipePlayerController: SwipePlayerController = new SwipePlayerController();
  // 懒加载数据源
  @Param datasource: PlayerDataSource<VideoPlayerData> = new PlayerDataSource<VideoPlayerData>();
  // 视频播放的外层交互组件
  @Param videoLayerBuilder:
  WrappedBuilder<[ESObject, AVPlayerSession, SwipePlayerController, PlayerLayoutSize]> | undefined = undefined;
  // 全屏按钮
  @BuilderParam fullBtnBuilder: () => void = this.defaultFullBtnBuilder
  // 配置项信息
  @Param options: SwipePlayerOptions | undefined = undefined
  // 底部tab的高度
  @Provider() bottomTabHeight: Length | undefined = this.options?.bottomTabHeight;
  // 点击列表页的视频卡片对应的视频
  @Param videoItemPlayerSession: AVPlayerSession | undefined = undefined
  // 网络
  @Param videoNetwork: VideoNetworkModel | undefined = undefined
  @Param videoNetworkSetting: VideoNetworkSetting | undefined = undefined
  // 路由栈
  @Param @Require pathStack: NavPathStack
  // 当前组件所在的页面是否显示
  @Param isShown: boolean = false;
  // 是否横屏
  @Param isLandscape: boolean = false;
  // 一多适配的断点
  @Param currentBreakpoint: BreakpointNameEnum = BreakpointNameEnum.SM;
  // 播放状态回调
  @Event playerStateCallback: (state: string, id: string) => void = (state: string, id: string) => {
  }
  // 播放进度变化的回调
  @Event playerTimeUpdateCallback: (id: string, timeMs: number) => void = (id: string, timeMs: number) => {
  }
  // 滑动控制器
  swiperController: SwiperController = new SwiperController();
  @Local videoState: AVPlayerState = AVPlayerState.IDLE;
  @Local videoStateIndex: number = 0
  @Provider() navDestinationUpdateListeners: Map<string, (info: uiObserver.NavDestinationInfo) => void> = new Map();
  @Local breakpointModel: BreakpointModel = new BreakpointModel();

  private displayFoldStatusChangeCallback = (data: display.FoldStatus) => {
    if (data === display.FoldStatus.FOLD_STATUS_FOLDED) {
      let isFullMode = isDisplayModeFull();
      if (isFullMode) {
        setOrientation(window.Orientation.FOLLOW_DESKTOP)
      } else {
        setOrientation(window.Orientation.USER_ROTATION_PORTRAIT)
      }
    }
  }

  @Computed
  get avPlayerManager() {
    return this.swipePlayerController.getAVPlayerMgr()!
  }

  @Monitor('videoNetwork.isCellular', 'videoState', 'videoStateIndex')
  onNetworkChange() {
    let videoState = this.avPlayerManager.getAVPlayer(this.currentIndex)?.state
    if (this.videoNetworkSetting?.remindWithoutWlan === 1) {
      this.videoNetwork!.hasUseMobileDataTip = false
    }
    if (videoState === AVPlayerState.PLAYING) {
      if (this.videoNetwork?.isCellular && !this.videoNetwork?.hasUseMobileDataTip) {
        toast(this.getUIContext(), {
          message: '正在使用流量播放',
          alignment: Alignment.Center,
        })
        if (this.videoNetwork && this.videoNetworkSetting?.remindWithoutWlan === 0) {
          this.videoNetwork.hasUseMobileDataTip = true
        }
      }
    }
  }

  @Monitor('currentBreakpoint')
  onCurrentBreakpointChange() {
    // 设置断点
    this.breakpointModel.currentBreakpoint = this.currentBreakpoint;
  }

  aboutToAppear(): void {
    // 设置断点
    this.breakpointModel.currentBreakpoint = this.currentBreakpoint;
    this.swipePlayerController?.setSwiperController(this.swiperController);
    // 网络
    this.handleNetwork()
    // 当前视频的状态
    emitter.on('swipeVideoPlayerState', (eventData: emitter.EventData) => {
      let state = eventData.data!.state as AVPlayerState;
      let index = eventData.data!.index as number;
      this.videoState = state;
      this.videoStateIndex = index
    })

    // 无感监听路由变化
    uiObserver.on('navDestinationUpdate', (info: uiObserver.NavDestinationInfo) => {
      this.navDestinationUpdateListeners.forEach((callback, key) => {
        if (key === 'fullScreenListener') {
          callback(info)
        }
      })
    })
  }

  handleNetwork() {
    if (this.videoNetwork && !this.videoNetwork.hasNet) {
      toast(this.getUIContext(), {
        message: '网络连接不可用',
        alignment: Alignment.Center,
        textColor: Color.Red,
      })
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Swiper(this.swiperController) {
        LazyForEach(this.datasource, (item: VideoPlayerData, index: number) => {
          VideoPlayerView({
            videoData: item,
            index: index,
            autoPlay: this.options?.autoPlay,
            currentIndex: this.currentIndex,
            totalCount: this.options?.totalCount,
            swipePlayerController: this.swipePlayerController,
            videoItemPlayerSession: this.videoItemPlayerSession,
            videoNetwork: this.videoNetwork,
            videoNetworkSetting: this.videoNetworkSetting,
            videoLayerBuilder: this.videoLayerBuilder,
            fullBtnBuilder: this.fullBtnBuilder,
            pathStack: this.pathStack,
            isLandscape: this.isLandscape,
            isShown: this.isShown,
            breakpointModel: this.breakpointModel,
            playerStateCallback: this.playerStateCallback,
            playerTimeUpdateCallback: this.playerTimeUpdateCallback,
          })
        }, (item: VideoPlayerData, index: number) => JSON.stringify(item) + index);
      }
      .cachedCount(this.options?.cachedCount ?? 2)
      .width('100%')
      .height('100%')
      .vertical(true)
      .loop(false)
      .curve(Curve.Ease)
      .duration(300)
      .indicator(false)
      .backgroundColor(Color.Black)
      .effectMode(EdgeEffect.Spring)
      .onChange((index: number) => {
        this.currentIndex = index;
        if (this.options?.swiperCallback?.onChange) {
          this.options.swiperCallback?.onChange(index);
        }
      })
      .onAnimationStart((index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
        this.currentIndex = targetIndex;
        if (this.options?.swiperCallback?.onAnimationStart) {
          this.options.swiperCallback?.onAnimationStart(index, targetIndex, extraInfo);
        }
      })
    }
    .width('100%')
    .height('100%')
    .id('player')
    .onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean, currentRatio: number) => {
      if (isExpanding && currentRatio >= 1.0) {
        let isFullMode = isDisplayModeFull();
        if (isFullMode || deviceInfo.deviceType === 'tablet') {
          setOrientation(window.Orientation.FOLLOW_DESKTOP)
        } else {
          setOrientation(window.Orientation.USER_ROTATION_PORTRAIT)
        }
        display.on('foldStatusChange', this.displayFoldStatusChangeCallback);
      }
      if (!isExpanding && currentRatio <= 0.0) {
        let allPathNames = this.pathStack.getAllPathName();
        let lastName = allPathNames[allPathNames.length - 1]
        if (lastName !== PageNameEnum.VIDEO_LANDSCAPE_PAGE) {
          setOrientation(window.Orientation.FOLLOW_DESKTOP)
        }
        display.off('foldStatusChange', this.displayFoldStatusChangeCallback);
      }
    })
  }

  // 默认全屏播放按钮
  @Builder
  defaultFullBtnBuilder() {
    Row({ space: 4 }) {
      Image($r('app.media.ic_expand_full')).width(13).height(13)
      Text('全屏播放')
        .fontColor(Color.White)
        .fontSize(14).fontWeight(500)
    }
    .padding({
      left: 10,
      top: 8,
      bottom: 8,
      right: 10,
    })
    .border({
      width: 1,
      color: '#99ffffff',
      style: BorderStyle.Solid,
      radius: 30,
    })
  }
}

export class SwipePlayerOptions {
  cachedCount?: number;
  autoPlay?: boolean;
  swiperCallback?: SwiperCallback;
  bottomTabHeight?: Length;
  totalCount?: number;
}

export class SwiperCallback {
  onChange?: (index: number) => void;
  onAnimationStart?: (index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => void;
}