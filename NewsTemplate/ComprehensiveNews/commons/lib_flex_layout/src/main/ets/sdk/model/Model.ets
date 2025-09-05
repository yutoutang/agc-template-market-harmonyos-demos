import { CommonDataSource } from 'lib_common'
import { LayoutSetting, NewsResponse, RequestListData } from 'lib_news_api'
import { NodeControllerFactory } from '../factory/NativeNodeFactory'

export interface NodeParams {
  type: string
  nativeCardData?: NewsResponse
  scrollIndex?: number
  extraInfo?: Record<string, number | string | boolean | Record<string, string | boolean>[]>
  layout: LayoutSetting
}

export class FrameNodeParams {
  viewLayout: LayoutSetting
  articles: NewsResponse[]
  extraInfo?: Record<string, number | string | boolean | Record<string, string | boolean>[]>
  style: Record<string, string | number>
  nodeControllerFactory?: NodeControllerFactory

  constructor(viewLayout: LayoutSetting, articles: NewsResponse[], style: Record<string, string | number>,
    extraInfo?: Record<string, number | string | boolean | Record<string, string | boolean>[]>,
    nodeControllerFactory?: NodeControllerFactory) {
    this.viewLayout = viewLayout
    this.articles = articles
    this.style = style
    this.extraInfo = extraInfo
    this.nodeControllerFactory = nodeControllerFactory
  }
}

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