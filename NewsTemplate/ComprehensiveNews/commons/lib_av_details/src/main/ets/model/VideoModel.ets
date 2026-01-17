import { AvSection } from 'lib_news_api'
import { VideoPlayerData } from 'module_swipeplayer'

@ObservedV2
export class VideoData implements VideoPlayerData {
  id: string = ''
  title: string = ''
  duration: number = 0
  updateTime: string = ''
  sectionUrl: string = ''
  coverUrl: string = ''

  getVideoId(): string {
    return this.id;
  }

  getVideoUrl(): string {
    return this.sectionUrl;
  }

  getCoverUrl(): string {
    return this.coverUrl;
  }

  getVideoTitle(): string {
    return this.title;
  }

  getVideoDuration(): number {
    return this.duration;
  }

  constructor(data: AvSection) {
    this.id = data.id
    this.title = data.title
    this.sectionUrl = data.sectionUrl!
    this.duration = data.duration!
    this.updateTime = data.updateTime!
  }
}