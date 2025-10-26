import { AvPlayer, AvPlayerPool, MediaSource } from 'video_swiper'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { AVPlayerListener } from 'video_swiper/src/main/ets/controller/AvPlayerListener'
import { TextNodeController } from './CustomNodeController'

const TAG = 'Pip_VideoController'
const DOMAIN = 0x0001

export class PipVideoController {
  playList: MediaSource[] = []
  index: number = 0
  player?: AvPlayer
  pipSurfaceId?: string
  private nodeController?: TextNodeController

  setCustomUIController(nodeController: TextNodeController) {
    this.nodeController = nodeController
  }

  listener: AVPlayerListener = {
    onEnded: () => {
      hilog.info(DOMAIN, TAG, 'onEnd, will play next')
      this.player?.unsetListener(this.listener)
      this.playIndex(this.index + 1)
    }
  }

  setPlayList(playList: MediaSource[]) {
    this.playList = playList
  }

  async playIndex(index: number) {
    if (index > this.playList.length) {
      hilog.info(DOMAIN, TAG, `play list end`)
      this.nodeController?.update('播放结束，请返回应用继续播放')
      return
    }
    this.index = index
    let mediaSource = this.playList[index]
    if (mediaSource.isLocked) {
      this.nodeController?.update('请返回应用解锁后继续播放')
      return
    }
    if (!this.pipSurfaceId) {
      return
    }

    // 复用播放器
    let player: AvPlayer = await AvPlayerPool.getInstance().acquire(mediaSource);
    this.player = player
    // 设置surface，重定向画面输出
    hilog.info(DOMAIN, TAG, `pip setSurfaceID:${this.pipSurfaceId}  id:${this.player.id}`)
    this.player.setSurfaceID(this.pipSurfaceId)
    this.player.setListener(this.listener)
    this.player.play()
  }

  pause() {
    this.player?.pause()
  }

  play() {
    if (this.playList[this.index].isLocked) {
      return
    }
    this.player?.play()
  }
}