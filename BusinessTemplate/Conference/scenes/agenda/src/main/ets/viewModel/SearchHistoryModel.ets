@Observed
export class SearchHistoryListModel {
  items: SearchHistoryItemModel[]
  isShowMore: boolean

  constructor(data: string[]) {
    this.items = []
    this.isShowMore = false
    data.forEach((item, index) => {
      this.items.push(new SearchHistoryItemModel(item, index))
    })
  }
}

@Observed
export class SearchHistoryItemModel {
  text: string
  order: number

  constructor(text: string, order?: number) {
    this.text = text
    this.order = order || 0
  }
}
export interface SearchHistoryModel {
  text: string
}

export interface SearchHotModel {
  text: string
  order?: number
  isHot: boolean
}

export class SearchParams {
  title: string

  constructor(title: string) {
    this.title = title
  }
}