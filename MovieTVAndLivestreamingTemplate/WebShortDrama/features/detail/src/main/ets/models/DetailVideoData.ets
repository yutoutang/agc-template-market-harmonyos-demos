import { VideoPlayData } from 'video_swiper';
import { ShortDramaDetailItemVM } from '../viewmodels/ShortDramaDetailItemVM';

// 详情数据结构
export class DetailVideoData implements VideoPlayData {
  videoMask: ShortDramaDetailItemVM;

  constructor(videoMask: ShortDramaDetailItemVM) {
    this.videoMask = videoMask
  }

  isLocked(): boolean {
    return this.videoMask.isLocked
  }

  getId(): string {
    return `${this.videoMask.currentSerial}`
  }

  getUrl(): ResourceStr {
    return this.videoMask.url
  }

  getPlayTime(): number {
    return this.videoMask.playTime
  }

  getPic(): string {
    return this.videoMask.dramaInfo.coverUrl
  }

  getName(): string {
    return this.videoMask.dramaInfo.name
  }

  getDuration(): number {
    return this.videoMask.duration
  }
}