import { Logger } from 'lib_common'
import { CastService, CastSessionListener, VideoData } from 'module_cast'
import { emitter } from '@kit.BasicServicesKit'

const TAG = 'CastSessionListenerImpl'

@ObservedV2
export class CastSessionListenerImpl implements CastSessionListener {
  @Trace currentIndex: number = 0
  public videoList: VideoData[] = []

  onStartCasting(): void {
    Logger.info(TAG, 'onStartCasting')
  }

  onEndCasting(): void {
    Logger.info(TAG, 'onStopCasting')
  }

  onPlay(): void {
    Logger.info(TAG, 'onPlay')
    CastService.getInstance().play()
    emitter.emit('playerPause', { data: { isPlaying: true } })
  }

  onPause(): void {
    Logger.info(TAG, 'onPause')
    CastService.getInstance().pause()
    emitter.emit('playerPause2', { data: { isPlaying: false } })
  }

  onPlayNext(): void {
    Logger.info(TAG, 'onPlayNext')
    this.currentIndex = (this.currentIndex + 1) % this.videoList.length
    const duration = this.videoList[this.currentIndex]?.duration || 100000
    CastService.getInstance().setAVMetadata(this.videoList[this.currentIndex], duration)
    CastService.getInstance().play()
    emitter.emit('playerNextOrPre', { data: { playerIndex: this.currentIndex } })
  }

  onPlayPre(): void {
    Logger.info(TAG, 'onPlayPre')
    this.currentIndex = (this.currentIndex - 1) % this.videoList.length
    const duration = this.videoList[this.currentIndex]?.duration || 100000
    CastService.getInstance().setAVMetadata(this.videoList[this.currentIndex], duration)
    CastService.getInstance().play()
    emitter.emit('playerNextOrPre', { data: { playerIndex: this.currentIndex } })
  }

  onSeek(time: number): void {
    Logger.info(TAG, 'onSeek' + time)
  }

  onFastForward(time: number): void {
    Logger.info(TAG, 'onFastForward' + time)
    emitter.emit('playerFastForward', { data: { time: time } })
  }

  onRewind(time: number): void {
    Logger.info(TAG, 'onRewind' + time)
    emitter.emit('playerRewind', { data: { time: time } })
  }
}