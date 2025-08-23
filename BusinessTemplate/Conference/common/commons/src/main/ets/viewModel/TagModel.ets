export interface TagObject {
  items: TagItem[]
  total: number
}

@Observed
export class TagItem {
  title?: string
  id?: string
  coverImageRealPath?: string
  order: number
  isSelect?: boolean
  showImagesRealPath: string[]
  selectIcon: string

  constructor(data?: TagItem) {
    this.order = 0
    this.showImagesRealPath = []
    this.selectIcon = ''
    if (data) {
      this.title = data.title || ''
      this.id = data.id
      this.order = data.order
      this.coverImageRealPath = data.coverImageRealPath ? `https:${data.coverImageRealPath}` : ''
      this.showImagesRealPath = data.showImagesRealPath
      this.selectIcon = data.showImagesRealPath?.length > 0 ? `https:${data.showImagesRealPath[0]}` : ''
      this.isSelect = data.isSelect || false
    }
  }
}





