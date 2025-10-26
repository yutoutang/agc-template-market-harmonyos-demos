import { DramaInfo } from '@agctemplate/server'
import { VideoPlayData } from 'video_swiper'
import { getRandomUUID } from 'video_swiper/src/main/ets/utils/CommonUtils'

export class DramaItemVM implements VideoPlayData {
  dramaInfo: DramaInfo
  id:string = ''
  getUrl(): string {
    return this.dramaInfo.promotionalUrl
  }

  getPlayTime(): number {
    return 0
  }

  getPic(): string {
    return this.dramaInfo.coverUrl
  }

  constructor(dramaInfo: DramaInfo) {
    this.dramaInfo = dramaInfo
  }

  isLocked(): boolean {
    return false
  }

  getName(): string {
    return this.dramaInfo.name
  }

  getId(): string {
    if(this.id === ''){
      this.id = getRandomUUID(4)
    }
    return this.dramaInfo.id
  }

  getDuration(): number {
    return 0
  }
}