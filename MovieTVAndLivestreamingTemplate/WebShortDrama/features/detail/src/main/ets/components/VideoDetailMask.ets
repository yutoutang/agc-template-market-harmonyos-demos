import { ShortDramaDetailItemVM } from '../viewmodels/ShortDramaDetailItemVM';
import { DetailVideoData } from '../models/DetailVideoData';
import { AppStorageKeys, StatusBarHeight } from '@agctemplate/widgets';
import { PlayController, VideoPlayData, PlaySession } from 'video_swiper';
import { AppStorageV2 } from '@kit.ArkUI';
import { DetailMaskLayer } from './DetailMaskLayer';

/**
 * 功能描述：
 * 1. 视屏上层独立绘制页面，包含侧边控制栏，视频描述信息，弹幕设置，弹幕等。
 *
 */
const TAG = '[VideoDetailMask]'

@ComponentV2
export struct VideoDetailMask {
  // 短视频数据
  @Param @Require videoDetailMaskVM: ShortDramaDetailItemVM;
  @Param @Require playControl: PlayController;
  @Param @Require playerSession: PlaySession
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  @Local isShowPlaySettingSheet: boolean = false
  @Provider('speed') curIndex: number = 0
  onSpeedSet: Function = (speed: number) => {
    this.playControl.setSpeed(speed)
  }

  aboutToAppear(): void {
    this.playControl.setPlayerHeight(`100%`)
    this.curIndex = this.videoDetailMaskVM.currentSerial
  }


  build() {
    DetailMaskLayer({
      videoDetailMaskVM: this.videoDetailMaskVM,
      playControl: this.playControl,
      playerSession: this.playerSession
    })
  }
}


@Builder
export function VideoDetailComponent(videoData: VideoPlayData, playControl: PlayController,
  playerSession: PlaySession) {

  VideoDetailMask({
    videoDetailMaskVM: (videoData as DetailVideoData).videoMask,
    playControl: playControl,
    playerSession: playerSession
  })
}