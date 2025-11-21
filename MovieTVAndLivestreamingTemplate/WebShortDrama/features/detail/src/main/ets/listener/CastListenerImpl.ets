import { Logger } from '@agctemplate/utils';
import { CastService, CastSessionListener } from 'module_cast';
import { PlayController, VideoPlayDataSource } from 'video_swiper';

const TAG = 'CastListenerImpl'

export class CastListenerImpl implements CastSessionListener {
  playController: PlayController
  videoData?: VideoPlayDataSource

  constructor(playController: PlayController) {
    this.playController = playController
  }

  async onStartCasting() {
    this.playController.disableSwiper = true
    await this.playController.pause()
    await CastService.getInstance().play()
    let seekTime = this.playController.getAVPlayer()?.currentTime
    if (seekTime) {
      CastService.getInstance().seek(seekTime)
    }
  }

  onEndCasting(): void {
    this.playController.disableSwiper = false
    this.playController.seek(CastService.getInstance().castStatusModel.castCurrentTime)
    this.playController.getAVPlayer()?.play()
  }

  onPlay(): void {
    this.playController.play()
  }

  onPause(): void {
    this.playController.pause()
  }

  onPlayNext(): void {
    this.playController.changeIndex(this.playController.curentIndex + 1)
  }

  onPlayPre(): void {
    this.playController.changeIndex(this.playController.curentIndex - 1)
  }

  onSeek(time: number): void {
    Logger.debug(TAG, `onSeek:${time} currentTime:${this.playController.getAVPlayer()?.currentTime}`)
    this.playController.seek(time)
  }

  onFastForward(time: number): void {
    Logger.debug(TAG, `onFastForward:${time} currentTime:${this.playController.getAVPlayer()?.currentTime}`)
    let avPlayer = this.playController.getAVPlayer()
    if (avPlayer) {
      this.playController.seek(avPlayer.currentTime + time * 1000)
    }
  }

  onRewind(time: number): void {
    Logger.debug(TAG, `onRewind:${time} currentTime:${this.playController.getAVPlayer()?.currentTime}`)
    let avPlayer = this.playController.getAVPlayer()
    if (avPlayer) {
      this.playController.seek(avPlayer.currentTime - time * 1000)
    }
  }
}