import { media } from '@kit.MediaKit';
import { window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Constants } from '../constants/Constants'
import { AVPlayerSession } from '../controller/AVPlayerManager';
import { isDisplayModeFull, pauseVideo, playVideo, setOrientation } from '../utils/Util';
import { VolumeAndBright } from '../utils/VolumeAndBright';
import { AVPlayerState, BreakpointNameEnum, PageNameEnum } from '../type/Index';
import { ProgressController } from '../components/VideoProgressBar';
import { BreakpointModel } from '../models/BreakpointModel';
import { LongTakeAnimationProperties, LongTakeTransitionParam } from 'module_transition';
import { Logger } from '../utils/Logger';

const TAG = '[LandscapeVideoVM]';

@ObservedV2
export class LandscapeVideoVM {
  player: media.AVPlayer | undefined;
  @Trace xComponentWidth: Length = Constants.FULL_PERCENT;
  @Trace xComponentHeight: Length = Constants.FULL_PERCENT;
  @Trace videoWidth: number = Constants.SURFACE_WIDTH;
  @Trace videoHeight: number = Constants.SURFACE_HEIGHT;
  // 当前跳转过来的路由栈
  @Trace pathStack: NavPathStack = new NavPathStack()
  // 当前视频的标题
  @Trace videoTitle: string = ''
  // 当前视频播放会话
  @Trace playerSession: AVPlayerSession | undefined = undefined;
  // 定时隐藏
  @Trace showBar: boolean = true
  @Trace time: number = 0
  // 是否锁屏
  @Trace showLock: boolean = true
  @Trace isLockScreen: boolean = false
  // 返回标识
  @Trace isBackFlag: boolean = false
  // 是否播放
  @Trace isPlaying: boolean = true;
  // 是否缓存
  @Trace isBuffering: boolean = false;
  @Trace trackThicknessSize: number = Constants.TRACK_SIZE_MIN;
  // 倍速
  @Trace isAccelerate: boolean = false;
  @Trace leftRateOpacity: number = 0;
  @Trace rightRateOpacity: number = 1;
  @Trace volumeUtil: VolumeAndBright = new VolumeAndBright()
  // 进度条跟随手势滑动
  @Trace panStartTime: number = 0
  @Trace panEndTime: number = 0
  // 一多适配的断点
  @Trace breakpointModel: BreakpointModel = new BreakpointModel();
  @Trace isFullMode: boolean = false;
  @Trace isMute: boolean = true
  // 是否隐藏进度条
  @Trace isHideSlide = false;
  positionX: number = 0;
  positionY: number = 0;
  progressController: ProgressController = new ProgressController();
  uiContext?: UIContext
  windowClass?: window.Window

  constructor(uiContext: UIContext) {
    try {
      this.uiContext = uiContext
      const context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext
      this.windowClass = context.windowStage!.getMainWindowSync();

      AppStorage.setAndRef('windowClass', this.windowClass)
    } catch (e) {
      Logger.error(TAG, 'getMainWindowSync fail, error: ' + JSON.stringify(e));
    }
  }

  @Computed
  get isTablet() {
    return [BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(this.breakpointModel.currentBreakpoint);
  }

  init() {
    this.windowClass?.on('windowSizeChange', (size) => {
      this.xComponentWidth = this.uiContext!.px2vp(size.width);
      this.xComponentHeight = this.uiContext!.px2vp(size.height);
      // 判断是否是大折叠、阔折叠外屏、小折叠内屏
      this.isFullMode = isDisplayModeFull();
      if (!this.isBackFlag && size.width < size.height &&
      this.pathStack.getAllPathName().includes(PageNameEnum.VIDEO_LANDSCAPE_PAGE)
      ) {
        this.pathStack.pop();
      }
    })
    this.showOrHiddenBar()
  }

  disappear() {
    this.windowClass!.off('windowSizeChange')
  }

  async onBack() {
    this.isBackFlag = true;
    // 退出横屏时，设置横竖屏  平板等大屏设备跟随传感器自动旋转，其他设置为竖屏
    let orientation = this.isTablet ? window.Orientation.AUTO_ROTATION : window.Orientation.USER_ROTATION_PORTRAIT
    setOrientation(this.uiContext, orientation).then(() => {
      this.pathStack.pop();
    })
  }

  showOrHiddenBar() {
    if (this.showBar || this.showLock) {
      clearTimeout(this.time)
      this.time = setTimeout(() => {
        this.showBar = false
        this.showLock = false
      }, 4000)
    } else {
      this.time && clearTimeout(this.time)
    }
  }

  lockScreen() {
    this.isLockScreen = !this.isLockScreen
    if (this.isLockScreen) {
      this.showBar = false
      this.showOrHiddenBar()
    } else {
      this.showBar = true
      if (this.isPlaying) {
        this.showOrHiddenBar()
      } else {
        this.time && clearTimeout(this.time)
      }
    }
  }

  switchPlayOrPause() {
    if (this.isPlaying) {
      this.pause();
      this.isPlaying = false;
      this.trackThicknessSize = Constants.TRACK_SIZE_MAX;
    } else {
      this.play();
      this.isPlaying = true;
      this.trackThicknessSize = Constants.TRACK_SIZE_MIN;
    }
    this.windowClass?.setWindowKeepScreenOn(true).catch((e: BusinessError) => {
      Logger.error(TAG, 'setWindowKeepScreenOn fail, error: ' + JSON.stringify(e));
    });
  }

  play() {
    playVideo(this.player);
  }

  pause() {
    pauseVideo(this.player);
  }

  setMute() {
    if (this.isMute) {
      this.volumeUtil.playerSliderModel.volume = 0
    }
  }

  // 处理视频外层的显示和隐藏
  handleVideoLayerVisible() {
    if (this.isPlaying) {
      this.showOrHiddenBar()
    } else {
      this.showBar = true
      if (this.time) {
        clearTimeout(this.time)
      }
    }
  }

  handleClickScreen() {
    this.showBar = this.isLockScreen ? false : !this.showBar
    this.showLock = !this.showLock
    if (this.isPlaying) {
      this.showOrHiddenBar()
    }
  }

  // 长按加速
  onLongPress(event: GestureEvent) {
    if (this.playerSession?.avPlayer?.state === 'playing') {
      // 快进图标显隐变化
      this.leftRateOpacity = 1;
      this.rightRateOpacity = 0;
      if (event?.repeat) {
        this.isAccelerate = true;
        this.playerSession.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_2_00_X)
      }
    }
  }
  // 取消长按
  offLongPress() {
    if (this.playerSession?.avPlayer?.state === 'playing') {
      this.isAccelerate = false;
      this.playerSession.avPlayer.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_00_X)
    }
  }

  // 处理音量和亮度的滑动开始事件回调
  handleBrightAndVolumePanStart(event?: GestureEvent) {
    // 页面锁住时，不能进行操作
    if (this.isLockScreen) {
      return
    }
    if (!event) {
      return;
    }
    if (!event.fingerList[0]) {
      return
    }
    if (event.fingerList[0].localX >= (this.xComponentWidth as number) / 2) {
      this.volumeUtil.playerSliderModel.showVolumeProgress = true
    } else {
      this.volumeUtil.playerSliderModel.showBrightProgress = true
    }

    this.positionY = event.offsetY;
  }

  // 处理音量和亮度的滑动更新事件回调
  handleBrightAndVolumePanUpdate(event?: GestureEvent) {
    if (this.isLockScreen) {
      return
    }
    if (!event) {
      return;
    }
    if (!event.fingerList[0]) {
      return
    }

    if (event.fingerList[0].displayX >= (this.xComponentWidth as number) / 2) {
      this.onVolumeActionUpdate(event)
    } else {
      this.onBrightActionUpdate(event)
    }
  }

  // 音量
  onVolumeActionUpdate(event: GestureEvent) {
    if (!this.player) {
      return;
    }
    const canOperateState: string[] = [
      AVPlayerState.PREPARED, AVPlayerState.PLAYING, AVPlayerState.PAUSED, AVPlayerState.COMPLETED,
    ];
    if (canOperateState.indexOf(this.player.state) === -1) {
      return;
    }
    let changeVolume = (this.positionY - event.offsetY) / (this.xComponentHeight as number)
    let currentVolume = this.volumeUtil.playerSliderModel.volume + changeVolume;
    let endVolume = Math.min(Math.max(0, currentVolume), 1);
    // 处理音量进度的显隐变化
    this.volumeUtil.handleVolumeProgressChange()
    this.volumeUtil.offVolumeChangeListen();
    this.volumeUtil.playerSliderModel.onSliderChange(0, endVolume, SliderChangeMode.Moving);
    this.positionY = event.offsetY;
  }

  // 亮度更新
  onBrightActionUpdate(event: GestureEvent) {
    if (this.volumeUtil.playerSliderModel.bright !== -1 && this.volumeUtil.playerSliderModel.bright < 0) {
      this.volumeUtil.playerSliderModel.bright = 0
    }
    if (this.volumeUtil.playerSliderModel.bright > 1) {
      this.volumeUtil.playerSliderModel.bright = 1
    }
    this.volumeUtil.playerSliderModel.showBrightProgress = true
    this.volumeUtil.playerSliderModel.showVolumeProgress = false;
    this.volumeUtil.offVolumeChangeListen();
    let changeBright = (this.positionY - event.offsetY) / (this.xComponentHeight as number)
    let currentBright = this.volumeUtil.playerSliderModel.bright + changeBright;
    let endBright = Math.min(Math.max(0, currentBright), 1);
    this.volumeUtil.playerSliderModel.onSliderChange(1, endBright, SliderChangeMode.Moving);
    this.positionY = event.offsetY;
  }

  onActionEnd() {
    if (this.isLockScreen) {
      return
    }
    this.volumeUtil.playerSliderModel.showVolumeProgress = false
    this.volumeUtil.playerSliderModel.showBrightProgress = false
    this.volumeUtil.onVolumeChangeListen()
  }

  // 进度条
  handleProgressStart(event: GestureEvent) {
    if (this.isLockScreen) {
      return
    }
    if (!event) {
      return;
    }
    this.positionX = event.offsetX;
    this.panStartTime = this.progressController.currentTime;
  }

  // 更新进度条
  handleProgressUpdate(event: GestureEvent) {
    if (this.isLockScreen) {
      return
    }
    if (!event) {
      return;
    }
    let tempTime = this.positionX + event.offsetX
    let changeTime = tempTime / this.progressController.progressWidth * this.progressController.durationTime;
    let panTime = this.panStartTime + changeTime
    this.panEndTime = Math.min(Math.max(0, panTime), this.progressController.durationTime);
    this.progressController.sliderOnChange(this.panEndTime, SliderChangeMode.Moving);
  }

  // 进度条滑动结束
  handleProgressEnd() {
    if (this.isLockScreen) {
      return
    }
    this.progressController.sliderOnChange(this.panEndTime, SliderChangeMode.End);
  }

  // 自定义动画注册
  public registerCustomTransition(
    navDestContext: NavDestinationContext,
    longTakeSession: LongTakeAnimationProperties,
  ) {
    let param = navDestContext.pathInfo?.param as Record<string, Object>;
    let longTakeTransitionParam = param.longTakeTransitionParam as LongTakeTransitionParam;
    if (longTakeTransitionParam) {
      longTakeSession.init(navDestContext, longTakeTransitionParam, {
        pop: () => {
          navDestContext.pathStack.pop()
        },
      });
    }
  }
}