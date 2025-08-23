export interface ArticleInterface  {
  title?: string
  id?: string
  coverImageRealPath?: string
  order: number
  isSelect?: boolean
  showImagesRealPath: string[]
  selectIcon: string
}

@Observed
export class ArticleModel {
  title?: string
  id?: string
  coverImageRealPath?: string
  order: number
  showImagesRealPath: string[]
  selectIcon: string

  constructor(data?: ArticleModel) {
    this.order = 0
    this.showImagesRealPath = []
    this.selectIcon = ''
    if (data) {
      this.title = data.title || ''
      this.id = data.id
      this.order = data.order
      this.coverImageRealPath = data.coverImageRealPath ? data.coverImageRealPath : ''
      this.showImagesRealPath = data.showImagesRealPath
      this.selectIcon = data.showImagesRealPath?.length > 0 ? data.showImagesRealPath[0] : ''
    }
  }
}