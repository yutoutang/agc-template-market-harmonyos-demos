import { media } from '@kit.MediaKit';
import { display } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import { Constants } from '../constants/Constants';
import { BreakpointNameEnum, VideoPlayerData } from '../type/Index';
import { VideoPlayerModel } from './VideoPlayerModel';
import { VideoNetworkModel } from '../models/VideoNetworkModel';
import { isDisplayModeFull } from '../utils/Util';

@ObservedV2
export class VideoCardModel extends VideoPlayerModel {
  // 封面图的高度
  @Trace coverImgHeight: Length = Constants.VIDEO_CARD_HEIGHT;
  @Trace isPause: boolean = true;
  @Trace currentBreakpoint: BreakpointNameEnum = BreakpointNameEnum.SM;
  videoNetwork?: VideoNetworkModel
  xComponentId: string = ''

  initPlayerManager(data: VideoPlayerData) {
    // 设置视频数据
    this.setVideoData(data);
    this.playerId = 'player_' + data.getVideoId() + util.generateRandomUUID();
    this.avPlayerManager.setPlayerId(this.index, this.playerId);
    this.avPlayerManager.setSession(this.playerId, this.playerSession!);
  }

  async initAVPlayer() {
    // 创建播放器
    const avPlayer = await media.createAVPlayer();
    if (avPlayer) {
      this.playerSession.setAVPlayer(avPlayer);
      // 设置视频url
      if (this.videoNetwork?.isWiFi || (this.videoNetwork?.isCellular && this.videoNetwork?.canUseMobileData)) {
        this.setDataSource()
      }
      // 初始化监听事件
      this.initPlayerListener(avPlayer)
    }
  }

  // 计算尺寸
  adaptiveVideoSize() {
    let videoRatio = Number(this.videoWidth) / Number(this.videoHeight);
    let displayWidth = display.getDefaultDisplaySync().width;
    let vpWidth = this.uiContext!.px2vp(displayWidth);
    let screenWidth = vpWidth;
    // 大折叠、平板适配
    let isFullMode = isDisplayModeFull();
    if (isFullMode || (!isFullMode && this.currentBreakpoint !== BreakpointNameEnum.SM)) {
      screenWidth = vpWidth / 2 - 48
    }
    this.xComponentHeight = screenWidth / videoRatio;
  }

  initXComponentId() {
    this.xComponentId = 'XComponentId' + this.playerId;
  }

  // 使用移动流量播放
  playVideoWithMobileData() {
    let player = this.playerSession.getAVPlayer()
    if (player) {
      if (player.state === 'idle') {
        this.setDataSource()
      } else {
        this.playerSession.getAVPlayer()?.play()
      }
    } else {
      this.initAVPlayer();
    }
  }
}