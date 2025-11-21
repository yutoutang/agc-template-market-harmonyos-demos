import { media } from '@kit.MediaKit';

export class MediaSource {
  id: string
  url: media.AVFileDescriptor | string
  isLocked:boolean

  constructor(id: string, url: media.AVFileDescriptor | string, isLocked:boolean) {
    this.id = id
    this.url = url
    this.isLocked = isLocked
  }
}