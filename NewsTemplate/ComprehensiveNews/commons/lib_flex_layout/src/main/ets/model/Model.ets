import { CommonDataSource } from 'lib_common'
import { RequestListData } from 'lib_news_api'

@ObservedV2
export class RendNewsInfo {
  id: string = ''
  text: ResourceStr = ''
  @Trace newsList: CommonDataSource<RequestListData> = new CommonDataSource()

  constructor(id: string, text: ResourceStr, newsList: CommonDataSource<RequestListData>) {
    this.id = id
    this.text = text
    this.newsList = newsList
  }
}