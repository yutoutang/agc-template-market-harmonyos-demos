export class VideoItem {
  id?: string
  title?: string
  summary?: string
  coverImageRealPath?: string
  controller?: VideoController
  order: number
  showImagesRealPath: string[]
  showImagesRealPath1: string

  constructor(data?: VideoItem) {
    this.order = 0
    this.showImagesRealPath = []
    this.showImagesRealPath1 = ''
    if (data) {
      this.id = data.id
      this.title = data.title
      this.summary = data.summary
      this.coverImageRealPath = data.coverImageRealPath
      this.controller = data.controller
      this.order = data.order
      this.showImagesRealPath = data.showImagesRealPath
      this.showImagesRealPath1 = data.showImagesRealPath.length > 0 ? `https:${data.showImagesRealPath[0]}` : ''
    }
  }
}





