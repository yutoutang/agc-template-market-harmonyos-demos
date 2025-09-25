import { media } from '@kit.MediaKit';
import { audio } from '@kit.AudioKit';
import { componentUtils, window } from '@kit.ArkUI';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { pauseVideo, playVideo, releaseVideo } from '../utils/CommonUtils';
import { Constants as Const } from '../constant/Contants'
import { PlayController, PlayerLayoutSize } from '../controller/PlayController';
import { VideoPlayData } from '../datasource/VideoPlayDataSource';
import { util } from '@kit.ArkTS';
import { PlaySession } from '../controller/PlaySession';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CoverLayer } from '../components/CoverLayer';
// import { CastService } from 'module_cast';
import { VideoData } from 'module_cast/src/main/ets/model/VideoData';
import { CastService } from 'module_cast';

const TAG = '[VideoPlayer]';
const otherClickHeight = 200

export enum VideoFit {
  Contain,
  Cover,
  CoverH
}

/**
 * 功能描述：
 * 1. 展示视频，播放组件，控制条
 * 参考最佳实践[在线短视频流畅切换](https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-smooth-switching)。
 *
 */
@Preview
@ComponentV2
export struct VideoPlayView {
  @Param firstFlag: boolean = false;
  @Event firstLoaded: () => void = () => {
  };
  @Event freshLoaded: () => void = () => {
  };
  // swipe中当前的播放索引
  @Param curIndex: number = -1;
  @Param isPageShow: boolean = false;
  @Param contentBuilder: WrappedBuilder<[VideoPlayData, PlayController, PlaySession]> | undefined = undefined;
  @Param previewUri: ResourceStr = '';
  @Param @Require videoData: VideoPlayData
  @Param @Require playController: PlayController;
  @Param @Require inPage: string
  @Local xComponentWidth: number | string = '100%';
  @Local xComponentHeight: number | string = '100%';
  @Local pauseClickHeight: number = 560
  videoFit: VideoFit = VideoFit.Contain
  @Local duration: number = 0;
  @Local currentTime: number = 0;

  @Monitor('curIndex','isPageShow','onFoldStatusChange')
  onIndexChanged(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {
      console.log(`${path} change from ${monitor.value(path)?.before} to ${monitor.value(path)?.now}`);
      switch (path) {
        case 'curIndex':
          this.onIndexChange();
        case 'isPageShow':
          this.onPageShowWatch()
        case 'onFoldStatusChange':
          this.onFoldStatusChange()
      }
    })
  }

  // 本视频索引
  @Param @Once index: number = 0;
  @Local layoutSize: PlayerLayoutSize = new PlayerLayoutSize()
  @Local aspRatio: number = 0.5;
  @Local isPlaying: boolean = false;
  @Local trackThicknessSize: number = Const.TRACK_SIZE_MIN;
  @Local preparedFlag: boolean = false;
  @Local isLoading: boolean = true;
  private surfaceID: string = '';
  private xComponentController = new XComponentController();
  avPlayer: media.AVPlayer | undefined = undefined;
  private videoHeight: number = Const.SURFACE_HEIGHT;
  private videoWidth: number = Const.SURFACE_WIDTH;
  componentId: string = 'player_' + util.generateRandomUUID(true)
  private xComponentId: string = 'XComponentId' + this.componentId;
  playerSession: PlaySession = new PlaySession()

  aboutToDisappear(): void {
    hilog.info(0x0000, TAG,
      `aboutToDisappear curIndex: ${this.curIndex}, index: ${this.index}, isPageShow: ${this.isPageShow}.`);
    releaseVideo(this.avPlayer, this.curIndex, this.index);
  }

  aboutToAppear(): void {
    this.layoutSize = this.playController.playLayout
    this.backEmitter()
    this.foreEmitter()
    hilog.info(0x0000, TAG,
      `aboutToAppear playerWidth: ${this.layoutSize.playerWidth}, playerHeight: ${this.layoutSize.playerHeight}.`);
  }

  onPageShowWatch() {
    if (!this.isPageShow && this.curIndex === this.index) {
      pauseVideo(this.avPlayer, this.curIndex, this.index);
      this.isPlaying = false;
      this.trackThicknessSize = Const.TRACK_SIZE_MIN;
    }
  }

  build() {
    Stack() {
      Stack({ alignContent: Alignment.Center }) {
        Stack({ alignContent: Alignment.Center }) {
          CoverLayer({
            isPlaying: this.isPlaying,
            preparedFlag: this.preparedFlag,
            curIndex: this.curIndex,
            index: this.index,
            isLoading: this.isLoading,
            previewUri: this.previewUri,
            xComponentWidth: this.xComponentWidth,
            xComponentHeight: this.xComponentHeight
          })

          Stack() {
            XComponent({
              id: this.xComponentId,
              type: XComponentType.SURFACE,
              controller: this.xComponentController
            })
              .width(this.xComponentWidth)
              .height(this.xComponentHeight)
              .onLoad(async () => {
                this.surfaceID = this.xComponentController.getXComponentSurfaceId();
                hilog.info(0x0000, TAG,
                  `surfaceID: ${this.surfaceID}, curIndex: ${this.curIndex}, index: ${this.index}.`);
                this.initAVPlayer();

              })
              .onDestroy(() => {
                hilog.info(0x0000, TAG,
                  `surfaceID: ${this.surfaceID}, destroy`);
              })
              .id('player')
              .zIndex(1)
          }
          .id(this.componentId)
          .width(this.layoutSize.playerWidth)
          .height(this.layoutSize.playerHeight)
          .position({ y: this.layoutSize.playerPositionY })
          .onSizeChange(() => {
            hilog.info(0x0000, TAG,
              `onSizeChange.`);
            this.autoVideoSize()
          })

          Column()
            .width('100%')
            .height(this.pauseClickHeight)
            .onClick(() => {
              hilog.info(0x0000, TAG,
                `iconOnClick playerWidth: ${this.layoutSize.playerWidth},
                playerHeight: ${this.layoutSize.playerHeight}.`);
              hilog.info(0x0000, TAG,
                `iconOnClick xComponentWidth: ${this.xComponentWidth}, xComponentHeight: ${this.xComponentHeight}.`);
              if (!this.playController.isLocked) {
                this.iconOnClick();
              }
            })
            .zIndex(5)

          // 图层view, 外部提供
          if (this.contentBuilder) {
            Column() {
              this.contentBuilder?.builder(this.videoData, this.playController, this.playerSession);
            }.zIndex(7)
            .width('100%')
            .height('100%')
            .hitTestBehavior(HitTestMode.Transparent)
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Black)
      }
      .onAreaChange((oldVal, newVal) => {
        this.pauseClickHeight = parseInt(newVal.height.toString()) - otherClickHeight
        if (this.pauseClickHeight <= 30) {
          this.pauseClickHeight = 30
        }
      })
      .width('100%')
      .height('100%')
    }
  }

  async iconOnClick() {
    if (this.isPlaying) {
      pauseVideo(this.avPlayer, this.curIndex, this.index);
      this.updateIsPlay(false)
      this.isPlaying = false;
      this.trackThicknessSize = Const.TRACK_SIZE_MIN;
      let context = getContext(this);
      let windowClass = await window.getLastWindow(context);
      await windowClass.setWindowKeepScreenOn(false);
      return;
    }
    if (this.preparedFlag) {
      playVideo(this.avPlayer, this.curIndex, this.index);
      this.updateIsPlay(true)
      this.isPlaying = true;
      this.trackThicknessSize = Const.TRACK_SIZE_MIN;
    } else {
      let intervalFlag = setInterval(async () => {
        if (this.preparedFlag) {
          playVideo(this.avPlayer, this.curIndex, this.index);
          this.updateIsPlay(true)
          this.isPlaying = true;
          this.trackThicknessSize = Const.TRACK_SIZE_MIN;
          clearInterval(intervalFlag);
        }
      }, 100);
    }
    let context = getContext(this);
    let windowClass = await window.getLastWindow(context);
    await windowClass.setWindowKeepScreenOn(true);
  }

  async initAVPlayer() {
    hilog.info(0x0000, TAG, `createAVPlayer begin. curIndex: ${this.curIndex}, index: ${this.index}.`);
    media.createAVPlayer().then((player: media.AVPlayer) => {
      if (player === undefined) {
        hilog.info(0x0000, TAG, `createAVPlayer fail.`);
        return;
      }
      hilog.info(0x0000, TAG, `createAVPlayer success.`);
      this.playController.setAVPlayer(this.index, player)
      this.avPlayer = player;
      this.setAVPlayerCallback(this.avPlayer);
      // set url into state initialized.
      if (typeof this.videoData.getUrl() === 'string') {
        this.avPlayer.url = this.videoData.getUrl() as string;
        hilog.info(0x0000, TAG,
          `AVPlayer state idle. source: ${this.videoData.getUrl()}, curIndex: ${this.curIndex}, index: ${this.index}.`);
      }
      this.playController.setAVPlayer(this.index, player)
      this.playerSession.setAVPlayer(player)
      hilog.info(0x0000, TAG, `createAVPlayer success. curIndex: ${this.curIndex}, index: ${this.index}.`);
    })
  }

  setAVPlayerCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('timeUpdate', (time: number) => {
      this.playerSession.timeUpdateCallbacks.get('timeUpdate')?.forEach((item) => {
        item(time);
      });
    })

    avPlayer.on('speedDone', (speed: number) => {
      this.playerSession.avPlayerCallback.get('speedDone')?.forEach((item) => {
        item(speed);
      });
    })

    avPlayer.on('seekDone', (time: number) => {
      this.updateIsPlay(this.isPlaying)
    })

    avPlayer.on('videoSizeChange', (width: number, height: number) => {
      this.videoHeight = height;
      this.videoWidth = width;
      hilog.info(0x0000, TAG, `videoSizeChange videoWidth${this.videoWidth}, videoHeight${this.videoHeight}`)
      this.autoVideoSize()
    })

    avPlayer.on('audioInterrupt', async (interruptEvent: audio.InterruptEvent) => {
      if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_FORCE) {
        // 强制打断类型（INTERRUPT_FORCE）：音频相关处理已由系统执行，应用需更新自身状态，做相应调整
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
            avPlayer.pause();
            break;
          case audio.InterruptHint.INTERRUPT_HINT_STOP:
            avPlayer.pause();
            break;

          default:
            break;
        }
      } else if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_SHARE) {
        // 共享打断类型（INTERRUPT_SHARE）：应用可自主选择执行相关操作或忽略音频打断事件
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_RESUME:
            avPlayer.play();
            break;
          default:
            break;
        }
      }
    })

    avPlayer.on('audioOutputDeviceChangeWithInfo', (data: audio.AudioStreamDeviceChangeInfo) => {
      if (data.changeReason === audio.AudioStreamDeviceChangeReason.REASON_OLD_DEVICE_UNAVAILABLE) {
        hilog.info(0x0001, TAG, `Device connect: ${data.changeReason}`);
        avPlayer.pause();
      }
    });

    //error listen, when the avPlayer is error, to load reset interface
    avPlayer.on('error', (err: BusinessError) => {
      hilog.info(0x0000, TAG, `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}.` +
        `----state: ${avPlayer.state}, curIndex: ${this.curIndex}, index: ${this.index}.`);
      avPlayer.reset();
    })

    this.setAVPlayerStateListen(avPlayer);
  }

  setAVPlayerStateListen(avPlayer: media.AVPlayer) {
    avPlayer.on('stateChange', async (state: string) => {
      switch (state) {
        case 'idle':
          hilog.info(0x0000, TAG, `AVPlayer state idle called. curIndex: ${this.curIndex}, index: ${this.index}.`);
          this.updateIsPlay(false)
          break;
        case 'initialized':
          hilog.info(0x0000, TAG,
            `AVPlayer state initialized called. curIndex: ${this.curIndex}, index: ${this.index}.`);
          avPlayer.surfaceId = this.surfaceID;
          avPlayer.prepare();
          this.updateIsPlay(false)
          break;
        case 'prepared':
          hilog.info(0x0000, TAG, `AVPlayer state prepared called. curIndex: ${this.curIndex}, index: ${this.index}.`);
          avPlayer.audioInterruptMode = audio.InterruptMode.INDEPENDENT_MODE;
          this.preparedFlag = true;
          this.freshLoaded();
          this.duration = this.avPlayer!.duration
          // 起播进度调整
          if (this.videoData.getPlayTime() > 0) {
            hilog.info(0x0000, TAG, `AVPlayer state prepared called. need seekto: ${this.videoData.getPlayTime()}.`);
            avPlayer.seek(this.videoData.getPlayTime())
          }
          hilog.info(0x0000, TAG,
            `prepared firstFlag:${this.firstFlag}, index:${this.index}, isPageShow:${this.isPageShow}`);
          // 首播起播
          if (this.firstFlag && this.index === this.curIndex && this.isPageShow) {
            hilog.info(0x0000, TAG, 'first video prepared go play!');
            if (!this.playController.isLocked) {
              avPlayer.play();
              this.firstLoaded();
            }
          }
          break;
        case 'playing':
          hilog.info(0x0000, TAG,
            `AVPlayer state playing called. curIndex: ${this.curIndex}, index: ${this.index},
            source: ${this.videoData.getUrl()}.`);
          this.updateIsPlay(true)
          this.isPlaying = true;
          this.isLoading = false;
          if (this.inPage === 'Detail' && this.playController.curentIndex > 10 && !PlayController.lockedDrama.get(
            this.playController.id)?.includes(this.playController.curentIndex) && !this.playController.isVip) {
            this.playController.isLocked = true
            pauseVideo(this.avPlayer, this.curIndex, this.index)
            this.updateIsPlay(false)
          } else {
            this.playController.isLocked = false
          }
          break;
        case 'paused':
          this.isPlaying = false;
          hilog.info(0x0000, TAG, `AVPlayer state paused called. curIndex: ${this.curIndex}, index: ${this.index}.`);
          this.updateIsPlay(false)
          break;
        case 'stopped':
          this.isPlaying = false;
          hilog.info(0x0000, TAG, `AVPlayer state stopped called. curIndex: ${this.curIndex}, index: ${this.index}.`);
          this.updateIsPlay(false)
          break;
        case 'completed':
          hilog.info(0x0000, TAG, `AVPlayer state completed called. curIndex: ${this.curIndex}, index: ${this.index}.`);
          this.updateIsPlay(false)
          this.isPlaying = false;
          if (this.playController.autoPlay) {
            this.playController.changeIndex(this.curIndex + 1)
          }
          avPlayer.seek(0, media.SeekMode.SEEK_CLOSEST);
          break;
        case 'released':
          hilog.info(0x0000, TAG, `AVPlayer state released called. curIndex: ${this.curIndex}, index: ${this.index}.`);
          break;
        case 'error':
          hilog.info(0x0000, TAG, `AVPlayer state error called. curIndex: ${this.curIndex}, index: ${this.index}.`);
          avPlayer.reset();
          break;
        default:
          hilog.info(0x0000, TAG, `AVPlayer state unknown called. curIndex: ${this.curIndex}, index: ${this.index}.`);
          break;
      }
      let callArr = this.playerSession.stateChangeCallbacks.get('stateChange');
      callArr?.forEach((item) => {
        item(state);
      });
    })
  }

  onIndexChange() {
    hilog.info(0x0000, TAG,
      `enter onIndexChange. curIndex: ${this.curIndex}, index: ${this.index}, isPageShow: ${this.isPageShow}.`);
    // 滑动过程中，不播放视频
    if (this.curIndex !== this.index) {
      pauseVideo(this.avPlayer, this.curIndex, this.index);
      this.updateIsPlay(false)
      this.isPlaying = false;
      this.trackThicknessSize = Const.TRACK_SIZE_MIN;
    } else {
      if(CastService.getInstance().isCasting){
        hilog.info(0x0000, TAG,
          `enter onIndexChange but casting. curIndex: ${this.curIndex}, index: ${this.index}.`);
        return
      }
      hilog.info(0x0000, TAG,
        `enter indexChange play. curIndex: ${this.curIndex}, index: ${this.index}, isPageShow: ${this.isPageShow}.`);
      // 准备好了，直接播放视频，否则等待准备
      if (this.preparedFlag) {
        playVideo(this.avPlayer, this.curIndex, this.index);
        this.updateIsPlay(true)
        this.isPlaying = true;
        this.trackThicknessSize = Const.TRACK_SIZE_MIN;
      } else {
        let countNum = 0;
        let intervalFlag = setInterval(() => {
          countNum++;
          if (this.curIndex !== this.index) {
            hilog.info(0x0000, TAG, `enter indexChange play error, clearIntreval. flag: ${this.preparedFlag},
            curIndex: ${this.curIndex}, index: ${this.index}.`);
            clearInterval(intervalFlag);
          }
          if (this.preparedFlag && this.isPageShow) {
            countNum = 0;
            playVideo(this.avPlayer, this.curIndex, this.index);
            this.updateIsPlay(true)
            this.isPlaying = true;
            this.trackThicknessSize = Const.TRACK_SIZE_MIN;
            clearInterval(intervalFlag);
          } else {
            hilog.info(0x0000, TAG, `enter indexChange play error, clearIntreval. countNum: ${countNum},
             flag: ${this.preparedFlag}, curIndex: ${this.curIndex}, index: ${this.index}.`);
            if (countNum > 15) {
              hilog.info(0x0000, TAG,
                `enter indexChange play error, reinit initAVPlayer. countNum: ${countNum}, flag: ${this.preparedFlag},
                curIndex: ${this.curIndex}, index: ${this.index}.`);
              countNum = 0;
              this.initAVPlayer();
            }
          }
        }, 100);
      }
    }
  }

  updateIsPlay(isPlay: boolean) {
    if (this.index !== this.playController.curentIndex) {
      return
    }
    hilog.debug(0x000, TAG, `updateIsPlay:${isPlay}`)
    if (isPlay) {
      CastService.getInstance().play({
        elapsedTime: this.avPlayer!.currentTime,
        updateTime: new Date().getTime()
      }, this.avPlayer?.duration)
    } else {
      CastService.getInstance().pause({
        elapsedTime: this.avPlayer!.currentTime,
        updateTime: new Date().getTime()
      }, this.avPlayer?.duration)
    }
    ;
  }

  onFoldStatusChange() {
    this.autoVideoSize();
  }

  autoVideoSize() {
    let size = componentUtils.getRectangleById(this.componentId).size;
    let playerComponentWidth = size.width;
    let playerComponentHeight = size.height;
    let videoRatio = this.videoWidth / this.videoHeight;
    let componentRatio = playerComponentWidth / playerComponentHeight;

    // 保持宽高比进行缩小或者放大，使得视频两边都大于或等于显示边界。
    if (this.videoFit === VideoFit.Cover) {
      if (videoRatio > componentRatio) {
        this.xComponentWidth = px2vp(this.videoWidth * playerComponentHeight / this.videoHeight);
        this.xComponentHeight = px2vp(playerComponentHeight);
      } else {
        this.xComponentWidth = px2vp(playerComponentWidth);
        this.xComponentHeight = px2vp(this.videoHeight * playerComponentWidth / this.videoWidth);
      }
    }
    // 保持宽高比进行缩小或者放大，使得视频高度填满。
    if (this.videoFit === VideoFit.CoverH) {
      this.xComponentWidth = px2vp(this.videoWidth * playerComponentHeight / this.videoHeight);
      this.xComponentHeight = px2vp(playerComponentHeight);
    }
    // 保持宽高比进行缩小或者放大，使得图片完全显示在显示边界内。
    if (this.videoFit === VideoFit.Contain) {
      if (videoRatio > componentRatio) {
        this.xComponentWidth = px2vp(playerComponentWidth);
        this.xComponentHeight = px2vp(this.videoHeight * playerComponentWidth / this.videoWidth);
      } else {
        this.xComponentWidth = px2vp(this.videoWidth * playerComponentHeight / this.videoHeight);
        this.xComponentHeight = px2vp(playerComponentHeight);
      }
    }
  }

  backEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 1
    };
    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      this.playController.pause()
      hilog.info(0x0000, TAG, `eventData: ${JSON.stringify(eventData)}`);
    }
    emitter.on(event, callback);
  }

  foreEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 2
    };
    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      this.playController.play()
      hilog.info(0x0000, TAG, `eventData: ${JSON.stringify(eventData)}`);
    }
    emitter.on(event, callback);
  }
}