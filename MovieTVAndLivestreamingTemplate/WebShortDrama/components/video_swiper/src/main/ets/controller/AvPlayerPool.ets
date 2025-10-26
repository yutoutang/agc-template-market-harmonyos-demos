import { AvPlayer } from './AvPlayer'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { MediaSource } from '../constant/MediaSource'

const TAG = 'Player_Pool'
const DOMAIN = 0x0002

export class AvPlayerPool {
  static instance: AvPlayerPool = new AvPlayerPool()
  pool: Map<string, AvPlayer> = new Map<string, AvPlayer>()

  public static getInstance(): AvPlayerPool {
    return AvPlayerPool.instance;
  }

  async acquire(mediaSource: MediaSource): Promise<AvPlayer> {
    hilog.debug(DOMAIN, TAG, `acquire id:${mediaSource.id}`)
    let avPlayer = this.pool.get(mediaSource.id)
    if (avPlayer !== undefined) {
      if (avPlayer.isReleased() || avPlayer.isError()) {
        hilog.debug(DOMAIN, TAG, `acquire release or error id:${mediaSource.id}`)
        avPlayer = undefined
      }
    }
    if (avPlayer === undefined) {
      avPlayer = await this.create(mediaSource)
      hilog.debug(DOMAIN, TAG, `acquire create! id:${mediaSource.id}`)
    }
    return avPlayer;
  }

  async create(mediaSource: MediaSource): Promise<AvPlayer> {
    let avPlayer = new AvPlayer()
    await avPlayer.init(mediaSource)
    this.pool.set(mediaSource.id, avPlayer)
    return avPlayer
  }

  recycle(avPlayer: AvPlayer) {
    hilog.debug(DOMAIN, TAG, `recycle id:${avPlayer.id}`)
    this.pool.delete(avPlayer.id)
  }
}