import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { audio } from '@kit.AudioKit';
import { Constants } from '../constants/Constants';
import { AVPlayerManager, AVPlayerSession, registerAVPlayerCallback } from '../controller/AVPlayerManager';
import { VideoPlayerData } from '../type/Index';
import { Logger } from '../utils/Logger';
import { VideoNetworkModel } from '../models/VideoNetworkModel';
import { handleSandboxVideoUrl } from '../utils/Util';

const TAG = '[VideoPlayerModel]'

@ObservedV2
export class VideoPlayerModel {
  @Trace xComponentWidth: Length = Constants.FULL_PERCENT;
  @Trace xComponentHeight: Length = Constants.VIDEO_CARD_HEIGHT;
  // 视频默认宽高
  @Trace videoWidth: Length = Constants.VIDEO_CARD_WIDTH;
  @Trace videoHeight: Length = Constants.VIDEO_CARD_HEIGHT;
  // 视频窗口ID
  @Trace surfaceId: string = ''
  @Trace showCover: boolean = true;
  @Trace isBuffering: boolean = false;
  @Trace isPause: boolean = false;
  @Trace isCompleted: boolean = false;
  // 是否是通过点击全屏播放按钮跳转到横屏页面
  @Trace isClickFullScreenBtn: boolean = false;
  // AVPlayer管理器
  avPlayerManager: AVPlayerManager = AVPlayerManager.getInstance()
  // 播放器id
  playerId: string = ''
  // videoIndex
  index: number = 0
  // 视频播放会话
  playerSession: AVPlayerSession = new AVPlayerSession();
  network?: VideoNetworkModel
  uiContext?: UIContext
  windowClass?: window.Window
  // 视频数据
  private videoData?: VideoPlayerData
  // 播放器状态监听
  private playerStateListeners: Array<(state: string) => void> = [];
  private preparedListeners: Array<() => void> = []
  private initializedListeners: Array<(avPlayer: media.AVPlayer) => void> = []
  private playingListeners: Array<() => void> = []
  private completedListeners: Array<() => void> = []
  private errorListeners: Array<() => void> = []
  private bufferingUpdateListeners: Array<(infoType: media.BufferingInfoType) => void> = []
  private videoSizeChangedListeners: Array<() => void> = []
  private startRendFrameListeners: Array<() => void> = []
  private timeUpdateListeners: Array<(timeMs: number) => void> = []

  constructor(uiContext: UIContext, index: number = 0) {
    try {
      this.uiContext = uiContext;
      this.windowClass = (uiContext.getHostContext() as common.UIAbilityContext).windowStage.getMainWindowSync();
      this.index = index
    } catch (e) {
      Logger.error(TAG, 'constructor getMainWindowSync fail, error: ' + JSON.stringify(e));
    }
  }

  setSurfaceId(surfaceId: string) {
    this.surfaceId = surfaceId
  }

  // 初始化播放管理器
  initPlayerManager(data: VideoPlayerData) {
  }

  // 初始化AVPlayer实例
  initAVPlayer() {
  }

  initPlayerListener(avPlayer: media.AVPlayer) {
    // 设置状态监听
    this.onStateChangeListener(avPlayer);
    // 设置播放器事件回调
    this.setAVPlayerCallback(avPlayer);
    // 设置音频事件回调
    this.setAVPlayerInterruptCallback(avPlayer)
  }

  setVideoData(data: VideoPlayerData) {
    this.videoData = data
  }

  setDataSource() {
    if (this.videoData!.getVideoUrl().startsWith('http')) {
      this.playerSession!.getAVPlayer()!.url = this.videoData!.getVideoUrl()
    } else {
      this.playerSession!.getAVPlayer()!.url = handleSandboxVideoUrl(this.videoData!.getVideoUrl())
    }
  }

  getVideData(): VideoPlayerData {
    return this.videoData!
  }

  onPlayerStateListener(listener: (state: string) => void) {
    this.playerStateListeners.push(listener)
  }

  onPreparedListener(listener: () => void) {
    this.preparedListeners.push(listener)
  }

  onInitializedListener(listener: (avPlayer: media.AVPlayer) => void) {
    this.initializedListeners.push(listener)
  }

  onPlayingListener(listener: () => void) {
    this.playingListeners.push(listener)
  }

  onCompletionListener(listener: () => void) {
    this.completedListeners.push(listener)
  }

  onErrorListener(listener: () => void) {
    this.errorListeners.push(listener)
  }

  onBuffingUpdateListener(listener: (infoType: media.BufferingInfoType) => void) {
    this.bufferingUpdateListeners.push(listener)
  }

  onVideoSizeChangedListener(listener: () => void) {
    this.videoSizeChangedListeners.push(listener)
  }

  onStartRenderFrameListener(listener: () => void) {
    this.startRendFrameListeners.push(listener)
  }

  onTimeUpdateListener(listener: (timeMs: number) => void) {
    this.timeUpdateListeners.push(listener)
  }

  onStateChangeListener(avPlayer: media.AVPlayer) {
    this.playerSession.avPlayer!.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      this.playerStateListeners.forEach((callback) => {
        callback(state);
      })
      try {
        switch (state) {
          case 'idle':
            Logger.debug(TAG, 'player state is idle');
            this.showCover = true;
            break;
          case 'initialized':
            Logger.debug(TAG, 'player state is initialized');
            this.showCover = true;
            this.playerSession.avPlayer!.surfaceId = this.surfaceId;
            this.initializedListeners.forEach((callback) => {
              callback(avPlayer)
            })
            await this.playerSession.avPlayer!.prepare();
            break;
          case 'prepared':
            Logger.debug(TAG, 'player state is prepared index: ' + this.index);
            this.showCover = true;
            this.isCompleted = false;
            this.playerSession.avPlayer!.loop = false;
            this.playerSession.avPlayer!.audioInterruptMode = audio.InterruptMode.INDEPENDENT_MODE;
            this.preparedListeners.forEach((callback) => {
              Logger.debug(TAG, 'prepared preparedListeners callback index: ' + this.index)
              callback()
            })
            break;
          case 'playing':
            Logger.debug(TAG, 'player state is playing');
            this.isPause = false;
            this.showCover = false;
            this.isBuffering = false;
            this.isCompleted = false;
            this.playingListeners.forEach((callback) => {
              callback()
            })
            await this.windowClass?.setWindowKeepScreenOn(true);
            break;
          case 'paused':
            Logger.debug(TAG, 'player state is paused');
            this.isPause = true;
            this.showCover = false;
            this.isCompleted = false;
            await this.windowClass?.setWindowKeepScreenOn(false);
            break;
          case 'stopped':
            Logger.debug(TAG, 'player state is stopped');
            this.showCover = false;
            this.isCompleted = false;
            await this.windowClass?.setWindowKeepScreenOn(false);
            break;
          case 'completed':
            Logger.debug(TAG, 'player state is completed');
            this.showCover = false;
            this.isCompleted = true;
            this.completedListeners.forEach((callback) => {
              callback()
            })
            break;
          case 'released':
            Logger.debug(TAG, 'player state is released');
            this.showCover = false;
            this.isCompleted = false;
            break;
          case 'error':
            Logger.debug(TAG, 'player state is error');
            this.showCover = false;
            this.isCompleted = false;
            this.errorListeners.forEach((callback) => {
              callback()
            })
            await this.playerSession.avPlayer!.reset();
            break;
          default:
            break;
        }
      } catch (e) {
        Logger.error(TAG, 'onStateChangeListener fail, error: ' + JSON.stringify(e));
      }

      let callArr = this.playerSession.avPlayerCallback.get('stateChange');
      callArr?.forEach((item) => {
        item(state, reason);
      });
    })
  }

  // 播放器监听
  setAVPlayerCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('videoSizeChange', (width: number, height: number) => {
      this.videoWidth = width;
      this.videoHeight = height;
      this.videoSizeChangedListeners.forEach((callback) => {
        callback()
      })

      let callArr = this.playerSession.avPlayerCallback.get('videoSizeChange');
      callArr?.forEach((item) => {
        item(width, height);
      });
    });

    registerAVPlayerCallback(avPlayer, this.playerSession.avPlayerCallback)

    this.playerSession.onEvent('bufferingUpdate', (infoType: media.BufferingInfoType, value: number) => {
      this.bufferingUpdateListeners.forEach((callback) => {
        callback(infoType)
      })
    });
    this.playerSession.onEvent('startRenderFrame', () => {
      this.startRendFrameListeners.forEach((callback) => {
        callback()
      })
    });
    // 时间进度回调
    this.playerSession.onEvent('timeUpdate', (time: number) => {
      this.timeUpdateListeners.forEach((callback) => {
        callback(time)
      })
    })
  }

  setAVPlayerInterruptCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('audioInterrupt', async (info: audio.InterruptEvent) => {
      try {
        if (info.forceType === audio.InterruptForceType.INTERRUPT_FORCE) {
          switch (info.hintType) {
            case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
              this.isPause = true;
              await this.playerSession?.avPlayer?.pause();
              break;
            case audio.InterruptHint.INTERRUPT_HINT_STOP:
              this.isPause = true;
              await this.playerSession?.avPlayer?.pause();
              break;
            case audio.InterruptHint.INTERRUPT_HINT_DUCK:
              break;
            case audio.InterruptHint.INTERRUPT_HINT_UNDUCK:
              break;
            default:
              break;
          }
        } else {
          switch (info.hintType) {
            case audio.InterruptHint.INTERRUPT_HINT_RESUME:
              await this.playerSession?.avPlayer?.play();
              break;
            default:
              break;
          }
        }
      } catch (e) {
        Logger.error(TAG, 'setAVPlayerInterruptCallback fail, error: ' + JSON.stringify(e));
      }

      let callArr = this.playerSession.avPlayerCallback.get('audioInterrupt');
      callArr?.forEach((item) => {
        item(info);
      });
    });
  }

  // 计算尺寸
  adaptiveVideoSize() {
  }

  // 处理页面销毁
  async handlerDisappear() {
    try {
      if (this.playerSession?.avPlayer) {
        await this.playerSession.avPlayer.stop();
        this.playerSession.avPlayer.off('stateChange');
        this.playerSession.avPlayer.off('videoSizeChange');
        this.playerSession.avPlayer.off('timeUpdate');
        this.playerSession.avPlayer.off('error');
        this.playerSession.avPlayer.off('durationUpdate');
        this.playerSession.avPlayer.off('seekDone');
        this.playerSession.avPlayer.off('speedDone');
        this.playerSession.avPlayer.off('bitrateDone');
        this.playerSession.avPlayer.off('availableBitrates');
        this.playerSession.avPlayer.off('volumeChange');
        this.playerSession.avPlayer.off('endOfStream');
        this.playerSession.avPlayer.off('bufferingUpdate');
        this.playerSession.avPlayer.off('startRenderFrame');
        this.playerSession.avPlayer.off('audioInterrupt');
        this.playerSession.avPlayer.off('mediaKeySystemInfoUpdate');
        this.playerSession.avPlayer.off('audioOutputDeviceChangeWithInfo');
        this.playerSession.avPlayer.off('subtitleUpdate');
        this.playerSession.avPlayer.off('trackChange');
        this.playerSession.avPlayer.off('trackInfoUpdate');
        await this.playerSession.avPlayer.release();
        this.playerSession.avPlayer = undefined;
        this.playerSession!.avPlayerCallback = new Map();
        this.avPlayerManager?.deleteSession(this.playerId);
      }
    } catch (e) {
      Logger.error(TAG, 'handlerDisappear fail, error: ' + JSON.stringify(e));
    }
  }
}