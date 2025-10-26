export class MediaSource {
  id: string
  url: string
  isLocked:boolean

  constructor(id: string, url: string, isLocked:boolean) {
    this.id = id
    this.url = url
    this.isLocked = isLocked
  }
}