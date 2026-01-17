import { media } from '@kit.MediaKit'
import { AppStorageV2, display, window } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'module_transition'
import { AVPlayerState, BreakpointNameEnum, PageNameEnum, VideoPlayerData } from '../type/Index'
import { secondToTime, setOrientation, toast } from '../utils/Util'
import { Constants } from '../constants/Constants'
import { VideoProgressBar } from './VideoProgressBar'
import { AVPlayerManager, AVPlayerSession } from '../controller/AVPlayerManager'
import { VideoCardModel } from '../viewmodel/VideoCardModel'
import { VideoNetworkModel, VideoNetworkSetting } from '../models/VideoNetworkModel'
import { BreakpointModel } from '../models/BreakpointModel'
import { BaseImage } from './BaseImage'
import { PiPWindowModel } from '../models/PiPWindowModel'
import { Logger } from '../utils/Logger';

@ObservedV2
export class VideoCardPlayerController {
  pause: () => void = () => {
  }
  play: () => void = () => {
  }
  switchPlayPause: () => void = () => {
  }
  videoUrlChange: (url: string) => void = () => {
  }
  seek: (seekTime: number) => void = () => {
  }
  getAvplayer: () => media.AVPlayer | undefined = () => undefined;
}

const TAG = '[VideoCard]';

@ComponentV2({ freezeWhenInactive: true })
export struct VideoCard {
  // 列表视频信息
  @Param @Require videoData: VideoPlayerData
  // List显示区域内中间子组件索引值
  @Param currentIndex: number = 0
  // 列表视频的索引
  @Param index: number = 0;
  // 组件所在页面是否显示
  @Param isShown: boolean = false
  // 是否是详情页的视频卡片
  @Param isFromDetailCard: boolean = false
  // 是否可以滑动进度条
  @Param canChangeSlide: boolean = false
  // 是否隐藏进度条
  @Param isHideSlide: boolean = false
  // 视频卡片控制器
  @Param videoCardPlayerController: VideoCardPlayerController = new VideoCardPlayerController()
  // 网络
  @Param videoNetwork: VideoNetworkModel | undefined = undefined
  @Param videoNetworkSetting: VideoNetworkSetting | undefined = undefined
  // 一多适配的断点
  @Param currentBreakpoint: BreakpointNameEnum = BreakpointNameEnum.SM;
  // 路由栈
  @Param pathStack: NavPathStack | undefined = undefined
  // 全屏自定义图标
  @Param fullScreenIcon: Resource | undefined = undefined
  // 是否隐藏静音图标
  @Param isNeedMuteIcon: boolean = false
  // 路由变化的监听事件
  @Local pipWindowModel: PiPWindowModel = AppStorageV2.connect(PiPWindowModel, () => new PiPWindowModel())!;
  // 视频信息view
  @BuilderParam videoInfoViewBuilder: CustomBuilder;
  @BuilderParam videoProgressBar: CustomBuilder;
  // 视频播放完后，界面展示的内容
  @Param completedBtnBuilder: WrappedBuilder<[AVPlayerSession]> | undefined = undefined;
  // 点击title，回调事件
  @Event onClickEvent: (playerSession: AVPlayerSession | undefined, callback: () => void) => void;
  // 播放list某个item的视频
  @Event onPlayItem: (playIndex: number) => void
  // 在移动网络下点击播放按钮，默认为是同意使用流量播放
  @Event setUseMobileData: () => void
  // 播放状态回调
  @Event playerStateCallback: (state: string, id: string) => void = (state: string, id: string) => {
  }
  @Param isMute: boolean = false
  // xComponent ready回调
  @Event xComponentReadyCallback: (controller: XComponentController) => void;
  @Event onMute: (value: boolean) => void = () => {};
  // XComponent控制器
  private xComponentController: XComponentController = new XComponentController();
  vm: VideoCardModel = new VideoCardModel(this.getUIContext(), this.index)

  async playAVPlayer(avplayer: media.AVPlayer | undefined) {
    try {
      await avplayer?.play()
    } catch (e) {
      Logger.error(TAG, 'play fail, error: ' + JSON.stringify(e));
    }
  }

  async pauseAVPlayer(avplayer: media.AVPlayer | undefined) {
    try {
      await avplayer?.pause();
    } catch (e) {
      Logger.error(TAG, 'pause fail, error: ' + JSON.stringify(e));
    }
  }

  // 播放器状态监听
  private playerStateListener = (state: string) => {
    if (this.index === this.currentIndex && this.videoNetwork) {
      // 播放时，才能使用画中画
      if (this.isFromDetailCard && this.videoNetworkSetting?.enableLivePiP) {
        this.pipWindowModel.isEnablePiP = state === AVPlayerState.PLAYING
        this.pipWindowModel.videoPlayerStatus = state;
      }
    }
  }
  // 准备状态监听事件
  private preparedListener = () => {
    // 自动播放开关打开，才会播放
    if (this.index === this.currentIndex && this.isShown &&
      this.videoNetworkSetting?.autoPlayTabRecommend
    ) {
      this.playerStateCallback && this.playerStateCallback(AVPlayerState.PREPARED, this.videoData.getVideoId())
      this.vm.playerSession.play()
    }
  }
  // 播放状态监听
  private playingListener = () => {
    if (this.index === this.currentIndex && this.videoNetwork) {
      this.videoNetwork.canUseMobileData = true;
      // 播放状态回调
      this.playerStateCallback && this.playerStateCallback(AVPlayerState.PLAYING, this.videoData.getVideoId())
    }
  }
  // 播放完成状态监听事件
  private completedListeners = () => {
    if (this.isFromDetailCard) {
      return
    }
    // 设置自动播放下一个，且推荐视频自动播放开关打开，则当前视频播放完之后，继续播放下一个
    if (this.videoNetworkSetting?.autoPlayNext && this.videoNetworkSetting?.autoPlayTabRecommend) {
      this.vm.isPause = true;
      this.vm.playerSession.avPlayer!.seek(0, media.SeekMode.SEEK_CLOSEST);
      this.onPlayItem?.(this.currentIndex + 1)
      this.playAVPlayer(this.vm.avPlayerManager.getAVPlayer(this.currentIndex + 1))
      return
    }
    // 其他情况，重头开始播放
    this.vm.playerSession.play()
  }
  // 视频播放错误事件监听
  private errorListener = () => {
    if (this.videoNetwork && !this.videoNetwork.hasNet && this.vm.isBuffering) {
      toast(this.vm.uiContext!, {
        message: '网络连接不可用',
        alignment: Alignment.Center,
        textColor: Color.Red,
      })
      this.vm.isBuffering = false;
      this.vm.isPause = true;
    }
  }
  // 缓存事件监听
  private buffingUpdateListener = (infoType: media.BufferingInfoType) => {
    if (this.currentIndex === this.index) {
      if (infoType === media.BufferingInfoType.BUFFERING_START) {
        if (this.videoNetworkSetting?.autoPlayTabRecommend) {
          this.vm.isPause = false;
        }
        this.vm.isBuffering = true;
      }
      if (infoType === media.BufferingInfoType.BUFFERING_END) {
        this.vm.isBuffering = false;
        if (!this.isShown) {
          this.vm.playerSession.pause();
        }
      }
    }
  }

  @Monitor('currentIndex')
  onIndexChanged() {
    this.onChangeListIndex();
  }

  @Monitor('videoNetwork.isNetworkAvailable','currentIndex')
  onCellularChange(monitor: IMonitor) {
    let isNetworkAvailable = monitor.value()?.now as boolean
    if (this.videoNetworkSetting?.remindWithoutWlan === 1) {
      this.videoNetwork!.hasUseMobileDataTip = false
    }
    if (this.currentIndex === this.index) {
      if (isNetworkAvailable && this.videoNetwork?.isCellular && !this.videoNetwork?.hasUseMobileDataTip) {
        toast(this.getUIContext(), {
          message: '正在使用流量播放',
          alignment: Alignment.Center,
        })
        if (this.videoNetwork && this.videoNetworkSetting?.remindWithoutWlan === 0) {
          this.videoNetwork.hasUseMobileDataTip = true
        }
        return
      }
      if (this.videoNetwork && this.videoNetwork.hasNet) {
        this.playAVPlayer(this.vm.playerSession.getAVPlayer())
      }
    }
  }

  @Monitor('videoNetwork.hasNet')
  onNetworkChange(monitor: IMonitor) {
    let hasNet = monitor.value()?.now as boolean;
    let playerState = this.vm.playerSession.avPlayer?.state
    if (this.currentIndex === this.index && playerState === 'idle' && hasNet) {
      this.vm.playerSession.avPlayer!.url = this.videoData.getVideoUrl()
    }
  }

  @Monitor('currentBreakpoint')
  onCurrentBreakpointChange(monitor: IMonitor) {
    // 设置断点
    let breakpoint = monitor.value()?.now as BreakpointNameEnum;
    this.vm.currentBreakpoint = breakpoint;
  }

  @Monitor('pipWindowModel.isReleaseVideoPlayer')
  onReleaseVideoPlayer() {
    if (this.pipWindowModel.isReleaseVideoPlayer) {
      this.vm.handlerDisappear()
    }
  }

  @Computed
  get durationStringTime() {
    const durationTime = Math.floor(this.videoData.getVideoDuration() / 1000)
    return secondToTime(durationTime);
  }

  aboutToAppear() {
    if (this.isFromDetailCard) {
      this.vm.avPlayerManager = new AVPlayerManager()
    }
    this.vm.initPlayerManager(this.videoData)
    this.vm.initXComponentId()
    // 播放器状态监听
    this.vm.onPlayerStateListener(this.playerStateListener);
    // 准备状态监听事件
    this.vm.onPreparedListener(this.preparedListener);
    // 视频播放状态监听事件
    this.vm.onPlayingListener(this.playingListener)
    // 完成状态监听事件
    this.vm.onCompletionListener(this.completedListeners);
    // 播放错误状态监听事件
    this.vm.onErrorListener(this.errorListener)
    // 缓存事件监听
    this.vm.onBuffingUpdateListener(this.buffingUpdateListener)
    // 监听首帧事件
    this.vm.onStartRenderFrameListener(() => {
      if (this.index === this.currentIndex) {
        this.vm.showCover = false;
      }
    })
    // 视频尺寸变化监听
    this.vm.onVideoSizeChangedListener(() => {
      this.vm.adaptiveVideoSize()
    })

    // 网络是否可用
    this.handlerNetwork()
    this.vm.videoNetwork = this.videoNetwork

    // 绑定控制器
    this.videoCardPlayerController.pause = (): void => this.pause();
    this.videoCardPlayerController.play = (): void => this.play();
    this.videoCardPlayerController.seek = (seekTime: number): void => this.seek(seekTime);
    this.videoCardPlayerController.switchPlayPause = (): void => this.switchPlayPause();
    this.videoCardPlayerController.videoUrlChange = (url: string): void => this.videoUrlChange(url);
    this.videoCardPlayerController.getAvplayer = (): media.AVPlayer | undefined => this.vm.playerSession.avPlayer
  }


  aboutToDisappear(): void {
    if (this.pipWindowModel.isReleaseVideoPlayer) {
      this.vm.handlerDisappear()
    }
  }

  pause() {
    this.vm.playerSession?.pause()
  }

  seek(seekTime: number) {
    this.vm.playerSession?.seek(seekTime)
  }

  play() {
    this.vm.playerSession?.play()
  }

  // 处理无网络情况
  handlerNetwork() {
    // 无网络且没有提示过，则提示
    if (this.videoNetwork && !this.videoNetwork.hasNet && !this.videoNetwork.hasOfflineTip) {
      toast(this.vm.uiContext!, {
        message: '网络连接不可用',
        alignment: Alignment.Center,
        textColor: Color.Red,
      })
      this.videoNetwork.hasOfflineTip = true
    }
  }

  onChangeListIndex() {
    // 当前是移动流量，且不允许使用移动流量播放
    let disabledPlay = this.videoNetwork && this.videoNetwork.isCellular && !this.videoNetwork.canUseMobileData
    if (this.index !== this.currentIndex || disabledPlay) {
      this.vm.isPause = true;
      this.vm.playerSession.pause();
      return;
    }
    this.vm.isPause = false;
    if (this.vm.playerSession.getAVPlayer()) {
      let canPlayStates = [
        AVPlayerState.PREPARED,
        AVPlayerState.PAUSED,
        AVPlayerState.COMPLETED,
      ] as media.AVPlayerState[]
      if (canPlayStates.includes(this.vm.playerSession.avPlayer?.state!)) {
        this.vm.playerSession.avPlayer?.setSpeed(1);
        this.vm.playerSession.play();
        return
      }
      // 有网络
      if (this.videoNetwork?.hasNet) {
        this.vm.playerSession.avPlayer!.url = this.videoData.getVideoUrl();
      }
    }
  }

  // 视频播放
  async onClickVideo() {
    if (this.vm.isPause && this.videoNetwork && !this.videoNetwork.hasNet) {
      toast(this.getUIContext(), {
        message: '网络连接不可用',
        alignment: Alignment.Center,
      })
      return;
    }
    if (this.vm.isPause && this.videoNetwork?.hasNet) {
      this.pauseAVPlayer(this.vm.avPlayerManager.getAVPlayer(this.currentIndex))
      this.onPlayItem?.(this.index);

      if (this.vm.playerSession.getAVPlayer()) {
        let playerState = this.vm.playerSession.avPlayer?.state;
        // idle状态
        if (playerState === AVPlayerState.IDLE) {
          this.vm.playerSession.avPlayer!.url = this.videoData.getVideoUrl();
          return;
        }
        await this.vm.playerSession.play()
      } else {
        await this.vm.initAVPlayer();
      }
    }
  }

  // 跳转详情页
  pushToVideoDetailPage() {
    let avPlayer = this.vm.playerSession?.avPlayer;
    let callback = async () => {
      if (this.index === this.currentIndex) {
        avPlayer!.surfaceId = this.vm.surfaceId;
        this.vm.playerSession!.avPlayer = avPlayer
        this.vm.showCover = false;
        this.vm.isPause = false;
        this.vm.onCompletionListener(this.completedListeners);
        this.vm.initPlayerListener(this.vm.playerSession.avPlayer!)
        // 退出详情页时，推荐页面需要播放视频
        await this.vm.playerSession?.pause();
        await this.vm.playerSession?.play();
      }
    }
    this.onClickEvent?.(this.vm.playerSession, callback)
  }

  // 处理点击卡片title
  async handleClickItemCard() {
    await this.onClickVideo()
    this.pushToVideoDetailPage()
  }

  switchPlayPause() {
    if (!this.vm.isBuffering && this.isFromDetailCard) {
      let playerState = this.vm.playerSession.avPlayer?.state;
      if (playerState === AVPlayerState.PLAYING) {
        this.vm.playerSession.pause()
      } else {
        this.onClickVideo()
      }
    }
  }

  videoUrlChange(url: string) {
    if (this.vm.playerSession.avPlayer) {
      this.vm.playerSession.avPlayer!.reset().then(() => {
        this.vm.playerSession.avPlayer!.url = url
      }).catch((e: BusinessError) => {
        Logger.error(TAG, 'reset fail, error: ' + JSON.stringify(e));
      });
    }
  }

  // 处理横屏按钮事件
  async handleFullScreen() {
    let param: Record<string, Object | AVPlayerSession | BreakpointModel | boolean> = {};
    param.playerSession = this.vm.playerSession;
    param.surfaceId = this.vm.surfaceId;
    param.videoWidth = this.vm.videoWidth;
    param.videoHeight = this.vm.videoHeight;
    param.videoTitle = this.videoData.getVideoTitle();
    let breakpointModel = new BreakpointModel()
    breakpointModel.currentBreakpoint = this.currentBreakpoint;
    param.breakpointModel = breakpointModel
    param.isMute = this.isMute
    param.isHideSlide = this.isHideSlide;
    // 视频播放，跨页面流转
    this.pipWindowModel.navDestinationUpdateListeners.clear();
    this.pipWindowModel.navDestinationUpdateListeners.set('landscapeListener', (info) => {
      if (info.name === PageNameEnum.VIDEO_LANDSCAPE_PAGE && info.state === 3) {
        let avPlayer = (param.playerSession as AVPlayerSession).getAVPlayer() as media.AVPlayer;
        if (avPlayer) {
          avPlayer.surfaceId = param.surfaceId as string;
        }
      }
    })

    try {
      // 窗口旋转
      let displayClass = display.getDefaultDisplaySync();
      let orientation = displayClass.orientation;
      if (orientation === display.Orientation.LANDSCAPE) {
        await setOrientation(this.getUIContext(), window.Orientation.USER_ROTATION_LANDSCAPE_INVERTED)
      } else if (orientation === display.Orientation.LANDSCAPE_INVERTED) {
        await setOrientation(this.getUIContext(), window.Orientation.USER_ROTATION_LANDSCAPE)
      } else if (orientation === display.Orientation.PORTRAIT) {
        await setOrientation(this.getUIContext(), window.Orientation.USER_ROTATION_LANDSCAPE)
      } else if (orientation === display.Orientation.PORTRAIT_INVERTED) {
        await setOrientation(this.getUIContext(), window.Orientation.USER_ROTATION_LANDSCAPE_INVERTED)
      }
      this.vm.isClickFullScreenBtn = true;
      this.pushToLandscapePage(param)
    } catch (e) {
      Logger.error(TAG, 'handleFullScreen fail, error: ' + JSON.stringify(e));
    }
  }

  // 跳转到横屏页
  pushToLandscapePage(
    param: Record<string, Object | AVPlayerSession | BreakpointModel | LongTakeTransitionParam | undefined>,
  ) {
    let longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(this.getUIContext(), 'videoCard' + this.index, 9);
    if (longTakeTransitionParam) {
      param.longTakeTransitionParam = longTakeTransitionParam;
    }
    this.pathStack?.pushPathByName(PageNameEnum.VIDEO_LANDSCAPE_PAGE, param);
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        // 视频播放
        XComponent({
          id: this.vm.xComponentId,
          type: XComponentType.SURFACE,
          controller: this.xComponentController,
        })
          .aspectRatio(Number(this.vm.videoWidth) / Number(this.vm.videoHeight))
          .onLoad(() => {
            let surfaceId = this.xComponentController.getXComponentSurfaceId();
            // 设置视频窗口ID
            this.vm.setSurfaceId(surfaceId)
            // 初始化
            this.vm.initAVPlayer();
            this.xComponentReadyCallback?.(this.xComponentController);
          })

        // 封面
        if (this.vm.showCover && this.videoData.getCoverUrl()) {
          BaseImage({
            url: this.videoData.getCoverUrl(),
            videoNetwork: this.videoNetwork,
            videoNetworkSetting: this.videoNetworkSetting,
          })
            .width(Constants.FULL_PERCENT)
            .onAreaChange((ov: Area, nv: Area) => {
              this.vm.coverImgHeight = nv.height
            })
        }
        if (this.isFromDetailCard && this.vm.isCompleted) {
          this.completedBtnBuilder?.builder(this.vm.playerSession)
        } else {
          if (this.vm.isPause) {
            Image($r('app.media.ic_paused'))
              .width(44)
              .height(44)
          }
        }
        // 缓冲中
        if (this.vm.isBuffering && this.index === this.currentIndex) {
          Column() {
            LoadingProgress()
              .width(50)
              .height(50)
              .color(Color.White);
            Text('缓冲中...')
              .fontSize(12)
              .fontColor(Color.White)
          }
        }

        RelativeContainer() {
          // 进度条
          Column() {
            // 视频的进度控制器
            VideoProgressBar({
              playerSession: this.vm.playerSession,
              canChangeSlide: this.canChangeSlide,
              isHideSlide: this.isHideSlide,
              isProgressFullWidth: !this.isFromDetailCard,
              showSlideBlock: this.isFromDetailCard,
              selectedColor: this.isFromDetailCard ? Color.White : $r('app.color.slide_selected_color'),
              showProgressBarLeft: this.isFromDetailCard,
              showProgressBarRight: this.isFromDetailCard,
              trackColor: this.isFromDetailCard ?
                $r('app.color.landscape_slide_track_color') : $r('app.color.slide_default_track_color'),
              slideHeight: this.isFromDetailCard ? 20 : 14,
              fullScreenIcon: this.fullScreenIcon,
              isNeedMuteIcon: this.isNeedMuteIcon,
              isMute: this.isMute,
              onMute:(value) => {
                this.onMute(value)
              },
              onSwitchPlayCallback: () => {
                this.switchPlayPause()
              },
              onSwitchFullScreenCallback: () => {
                if (this.isFromDetailCard && this.pathStack) {
                  this.handleFullScreen()
                }
              },
            })
          }
          .visibility(this.index === this.currentIndex ? Visibility.Visible : Visibility.Hidden)
          .alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            middle: { anchor: '__container__', align: HorizontalAlign.Center },
          })

          if (!this.isFromDetailCard) {
            Text(this.durationStringTime)
              .fontSize(10)
              .fontColor($r('sys.color.white'))
              .padding(4)
              .borderRadius(4)
              .backgroundColor($r('app.color.color_black_40'))
              .offset({ bottom: 8, right: 12 })
              .visibility(this.vm.isPause ? Visibility.Visible : Visibility.Hidden)
              .alignRules({
                bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
                right: { anchor: '__container__', align: HorizontalAlign.End },
              })
          }
        }
        .aspectRatio(Number(this.vm.videoWidth) / Number(this.vm.videoHeight))
        .onClick(() => {
          let playerState = this.vm.playerSession.avPlayer?.state;
          if (playerState === AVPlayerState.PLAYING) {
            this.pushToVideoDetailPage()
          } else {
            this.onClickVideo()
          }
        })

        // 流量提示
        if (this.currentIndex === this.index && this.videoNetwork &&
        this.videoNetwork.isCellular && !this.videoNetwork.canUseMobileData
        ) {
          Column({ space: Constants.SPACE_M }) {
            Row({ space: Constants.SPACE_S }) {
              Image($r('app.media.ic_playback')).width(12).height(13)
              Text('继续播放')
                .fontSize(14)
                .fontColor(Color.White)
                .lineHeight(20)
            }
            .padding({
              left: 10,
              right: 10,
              top: 4,
              bottom: 4,
            })
            .borderRadius(20)
            .backgroundColor('#1b1a1b')
            .onClick(() => {
              this.setUseMobileData && this.setUseMobileData()
              this.vm.playVideoWithMobileData()
            })

            Text('当前非Wi-Fi网络，继续播放将产生流量费用')
              .fontSize(14)
              .fontColor(Color.White)
              .lineHeight(20)
          }
          .width(Constants.FULL_PERCENT)
          .height(this.vm.coverImgHeight)
          .backgroundColor(Color.Black)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width(Constants.FULL_PERCENT)
      .onSizeChange(() => {
        this.vm.adaptiveVideoSize()
      })

      // 视频信息view
      if (this.videoInfoViewBuilder) {
        Row() {
          this.videoInfoViewBuilder()
        }
        .onClick(() => {
          this.handleClickItemCard()
        })
      }
    }
    .width(Constants.FULL_PERCENT)
    .id('videoCard' + this.index)
  }
}