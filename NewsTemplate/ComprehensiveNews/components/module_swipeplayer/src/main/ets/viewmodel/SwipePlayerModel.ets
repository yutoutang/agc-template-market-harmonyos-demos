import { media } from '@kit.MediaKit';
import { util } from '@kit.ArkTS';
import { display } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { PlayerLayoutSize } from '../controller/PlayerLayoutSize';
import { VideoPlayerModel } from './VideoPlayerModel';
import { AVPlayerManager, AVPlayerSession } from '../controller/AVPlayerManager';
import { VideoPlayerData } from '../type/Index';
import { Logger } from '../utils/Logger';

const TAG = '[SwipePlayerModel]';

@ObservedV2
export class SwipePlayerModel extends VideoPlayerModel {
  // AVPlayer管理器
  avPlayerManager: AVPlayerManager = new AVPlayerManager()
  // 视频播放会话
  playerSession: AVPlayerSession = new AVPlayerSession();
  componentId: string = ''
  xComponentId: string = ''
  // 视频渲染尺寸
  @Trace playerLayoutSize: PlayerLayoutSize = new PlayerLayoutSize();
  // 是否从列表页点击卡片跳转过来
  isFromList: boolean = false;
  // 点击列表卡片的播放器实例
  itemAVPlayer: media.AVPlayer | undefined
  // 封面图
  @Trace imageUrl: ResourceStr = ''
  // 倍速
  @Trace isAccelerate: boolean = false;
  @Trace leftRateOpacity: number = 0;
  @Trace rightRateOpacity: number = 1;

  // 是否显示全屏按钮
  @Computed
  get showFullScreenBtn() {
    return this.checkVideoSize() && !this.isAccelerate && !this.playerLayoutSize.getSlideMovingFlag()
  }

  initPlayerManager(data: VideoPlayerData, videoItemPlayerSession?: AVPlayerSession) {
    // 设置视频数据
    this.setVideoData(data);
    this.playerId = 'player_' + data.getVideoId() + util.generateRandomUUID();

    if (this.index === 0 && videoItemPlayerSession) {
      this.isFromList = true;
      this.itemAVPlayer = videoItemPlayerSession!.avPlayer
      this.itemAVPlayer?.pause().catch((e: BusinessError) => {
        Logger.error(TAG, 'initPlayerManager fail, error: ' + JSON.stringify(e));
      }).finally(() => {
        this.isPause = false;
      })
    }
    this.avPlayerManager.setPlayerId(this.index, this.playerId);
    this.avPlayerManager.setSession(this.playerId, this.playerSession!);
  }

  async initAVPlayer() {
    try {
      // 从视频推荐页或新闻详情页进入的短视频滑动页
      if (this.isFromList && this.index === 0 && this.itemAVPlayer) {
        this.showCover = false
        this.isPause = false
        this.itemAVPlayer!.surfaceId = this.surfaceId
        this.playerSession.setAVPlayer(this.itemAVPlayer);
        this.initPlayerListener(this.itemAVPlayer)
        await this.itemAVPlayer.play();
        return
      }
      // 创建播放器
      const avPlayer = await media.createAVPlayer();
      if (avPlayer) {
        this.playerSession.setAVPlayer(avPlayer);
        // 设置视频url
        this.setDataSource();
        // 初始化监听事件
        this.initPlayerListener(avPlayer)
      }
    } catch (e) {
      Logger.error(TAG, 'createAVPlayer fail, error: ' + JSON.stringify(e));
    }
  }

  initPlayerListener(avPlayer: media.AVPlayer) {
    // 设置状态监听
    this.onStateChangeListener(avPlayer);
    // 设置播放器事件回调
    this.setAVPlayerCallback(avPlayer);
    // 设置音频事件回调
    this.setAVPlayerInterruptCallback(avPlayer)
  }

  initXComponentId() {
    this.componentId = 'VideoPlayer_' + this.playerId;
    this.xComponentId = 'XComponentId' + this.playerId;
  }

  async playOrPause() {
    try {
      if (this.isPause) {
        await this.playerSession?.avPlayer?.play();
      } else {
        await this.playerSession?.avPlayer?.pause();
      }
    } catch (e) {
      Logger.error(TAG, 'playOrPause fail, error: ' + JSON.stringify(e));
    }
  }

  // 判断视频播放时的尺寸大小
  checkVideoSize(): boolean {
    try {
      let height = Number(this.playerLayoutSize.getXComponentHeight());
      let width = Number(this.playerLayoutSize.getXComponentWidth());

      let displayClass = display.getDefaultDisplaySync();
      let orientation = displayClass.orientation;
      let landscapes = [display.Orientation.LANDSCAPE, display.Orientation.LANDSCAPE_INVERTED];
      // 设备横向时不展示全屏播放按钮
      if (landscapes.includes(orientation)) {
        return false;
      }
      return height / width < 1
    } catch (e) {
      Logger.error(TAG, 'showFullScreenBtn fail, error: ' + JSON.stringify(e));
      return false;
    }
  }

  // 自适应视频尺寸
  adaptiveVideoSize() {
    try {
      let size = this.uiContext!.getComponentUtils().getRectangleById(this.componentId).size;
      let playerLayoutWidth = size.width;
      let playerLayoutHeight = size.height;

      let videoRatio = Number(this.videoWidth) / Number(this.videoHeight);
      let screenRatio = playerLayoutWidth / playerLayoutHeight;

      let widthForVp = this.uiContext!.px2vp(Number(this.videoWidth) * playerLayoutHeight / Number(this.videoHeight))
      let heightForVp = this.uiContext!.px2vp(playerLayoutHeight)
      if (videoRatio > screenRatio) {
        widthForVp = this.uiContext!.px2vp(playerLayoutWidth)
        heightForVp = this.uiContext!.px2vp(Number(this.videoHeight) * playerLayoutWidth / Number(this.videoWidth))
      }
      this.playerLayoutSize.updateXComponentWidth(widthForVp);
      this.playerLayoutSize.updateXComponentHeight(heightForVp);
    } catch (e) {
      Logger.error(TAG, 'adaptiveVideoSize fail, error: ' + JSON.stringify(e));
    }
  }

  // 长按加速
  onLongPress(event: GestureEvent) {
    if (this.playerSession?.avPlayer?.state === 'playing' && !this.isBuffering) {
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
    this.isAccelerate = false;
    this.playerSession?.avPlayer?.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_00_X)
  }
}