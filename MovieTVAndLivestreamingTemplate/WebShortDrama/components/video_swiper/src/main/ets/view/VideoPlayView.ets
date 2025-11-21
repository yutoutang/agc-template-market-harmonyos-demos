import { componentUtils, window } from '@kit.ArkUI';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { Constants as Const } from '../constant/Contants'
import { PlayController, PlayerLayoutSize } from '../controller/PlayController';
import { VideoPlayData } from '../datasource/VideoPlayDataSource';
import { util } from '@kit.ArkTS';
import { PlaySession } from '../controller/PlaySession';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CoverLayer } from '../components/CoverLayer';
import { CastService } from 'module_cast';
import { AvPlayer } from '../controller/AvPlayer';
import { AvPlayerPool } from '../controller/AvPlayerPool';
import { MediaSource } from '../constant/MediaSource'
import { media } from '@kit.MediaKit';

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
  @Local avPlayer: AvPlayer | undefined = undefined;
  playerPool: AvPlayerPool = AvPlayerPool.getInstance()
  private videoHeight: number = Const.SURFACE_HEIGHT;
  private videoWidth: number = Const.SURFACE_WIDTH;
  componentId: string = 'player_' + util.generateRandomUUID(true)
  private xComponentId: string = 'XComponentId' + this.componentId;
  playerSession: PlaySession = new PlaySession()

  aboutToDisappear(): void {
    hilog.info(0x0000, TAG,
      `aboutToDisappear curIndex: ${this.curIndex}, index: ${this.index}, isPageShow: ${this.isPageShow}.`);
    if (this.avPlayer) {
      this.avPlayer.release()
      this.playerPool.recycle(this.avPlayer)
    }
  }

  aboutToAppear(): void {
    this.layoutSize = this.playController.playLayout
    hilog.info(0x0000, TAG,
      `aboutToAppear playerWidth: ${this.layoutSize.playerWidth}, playerHeight: ${this.layoutSize.playerHeight}.`);
  }

  onPageShowWatch() {
    if (!this.isPageShow && this.curIndex === this.index) {
      this.avPlayer?.pause()
      this.isPlaying = false;
      this.trackThicknessSize = Const.TRACK_SIZE_MIN;
    }
  }

  build() {
    Stack() {
      Stack({ alignContent: Alignment.Center }) {
        Stack({ alignContent: Alignment.Center }) {
          if (this.avPlayer) {
            CoverLayer({
              avPlayer: this.avPlayer,
              curIndex: this.curIndex,
              index: this.index,
              previewUri: this.previewUri,
              xComponentWidth: this.xComponentWidth,
              xComponentHeight: this.xComponentHeight
            })
          }


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
                this.playController.setSurfaceId(this.index, this.surfaceID)
                hilog.info(0x0000, TAG,
                  `surfaceID: ${this.surfaceID}, curIndex: ${this.curIndex}, index: ${this.index}.`);
                let mediaSource: MediaSource =
                  new MediaSource(this.videoData.getId(), this.videoData.getUrl() as media.AVFileDescriptor | string,
                    this.videoData.isLocked())
                this.avPlayer = await this.playerPool.acquire(mediaSource)
                this.playerSession.setAVPlayer(this.avPlayer)
                hilog.info(0x000, TAG, `normal setSurfaceID:${this.surfaceID} id:${this.avPlayer.id}`)
                this.avPlayer.setSurfaceID(this.surfaceID)
                if (!this.videoData.isLocked()) {
                  if (this.videoData.getPlayTime() > 0) {
                    this.avPlayer.seek(this.videoData.getPlayTime() * 1000)
                  }
                  this.avPlayer.play()
                }

                this.setListener()
                this.playController.setAVPlayer(this.index, this.avPlayer)
              })
              .onDestroy(() => {
                hilog.info(0x0000, TAG,
                  `surfaceID: ${this.surfaceID}, destroy`);
                this.playController.clearSurfaceId(this.index)
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
    let avPlayer = this.avPlayer
    if (!avPlayer) {
      return
    }
    if (avPlayer.isPlaying) {
      avPlayer.pause()
      this.updateIsPlay(false)
      this.isPlaying = false;
      this.trackThicknessSize = Const.TRACK_SIZE_MIN;
      let context = getContext(this);
      let windowClass = await window.getLastWindow(context);
      await windowClass.setWindowKeepScreenOn(false);
      return;
    } else {
      if (this.videoData.isLocked()) {
        return
      }
      avPlayer.play()
      this.updateIsPlay(true)
      this.isPlaying = true;
      this.trackThicknessSize = Const.TRACK_SIZE_MIN;
      let context = getContext(this);
      let windowClass = await window.getLastWindow(context);
      await windowClass.setWindowKeepScreenOn(true);
    }
  }

  setListener() {
    this.avPlayer?.setListener({
      onPlaying: () => {
        this.updateIsPlay(true)
      },
      onPaused: () => {
        this.updateIsPlay(false)
      },
      onEnded: () => {
        this.avPlayer?.seek(0);

        if (this.playController.autoPlay) {
          this.playController.changeIndex(this.curIndex + 1)
        } else {
          this.playerSession.listener?.onEnded?.()
        }
      }
    })
  }

  onIndexChange() {
    hilog.info(0x0000, TAG,
      `enter onIndexChange. curIndex: ${this.curIndex}, index: ${this.index}, isPageShow: ${this.isPageShow}.`);
    // 滑动过程中，不播放视频
    if (this.curIndex !== this.index) {
      this.avPlayer?.pause()
      this.updateIsPlay(false)
      this.isPlaying = false;
      this.trackThicknessSize = Const.TRACK_SIZE_MIN;
    } else {
      if (this.videoData.isLocked()) {
        return
      }
      if (CastService.getInstance().castStatusModel.isCasting) {
        hilog.info(0x0000, TAG,
          `enter onIndexChange but casting. curIndex: ${this.curIndex}, index: ${this.index}.`);
        return
      }
      hilog.info(0x0000, TAG,
        `enter indexChange play. curIndex: ${this.curIndex}, index: ${this.index}, isPageShow: ${this.isPageShow}.`);
      // 准备好了，直接播放视频，否则等待准备
      this.avPlayer?.play()
      this.updateIsPlay(true)
      this.isPlaying = true;
      this.trackThicknessSize = Const.TRACK_SIZE_MIN;
    }
  }

  updateIsPlay(isPlay: boolean) {
    if (this.index !== this.playController.curentIndex) {
      return
    }
    hilog.debug(0x000, TAG, `updateIsPlay:${isPlay}`)
    if (isPlay) {
      CastService.getInstance().play({
        elapsedTime: (this.avPlayer?.currentTime || 0)*1000,
        updateTime: new Date().getTime()
      }, this.avPlayer?.duration)
    } else {
      CastService.getInstance().pause({
        elapsedTime: (this.avPlayer?.currentTime || 0)*1000,
        updateTime: new Date().getTime()
      }, this.avPlayer?.duration)
    }
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
}