import { IButtonItem, NavInfo } from '../base/BaseModel'
import { AuthorResponse } from './AuthorResponse'
import { NewsResponse } from './NewsResponse'

export class AuthorInfo implements AuthorResponse {
  // 作者id
  authorId: string = ''
  //作者昵称
  authorNickName: string = ''
  // 作者icon
  authorIcon: string = ''
  //作者简介
  authorDesc: string = ''
  // 作者ip
  authorIp: string = ''
  // 关注的人数
  watchersCount: number = 0
  // 粉丝数量
  followersCount: number = 0
  // 获赞数量
  likeNum: number = 0
}

export interface FlexLayoutModel {
  navInfo: NavInfo
  articles: string[]
  extraInfo: Record<string, string | boolean | Record<string, string | boolean>[]>
}

@ObservedV2
export class RequestListData {
  navInfo: NavInfo = new NavInfo()
  @Trace articles: NewsResponse[] = []
  extraInfo: Record<string, string | boolean | Record<string, string | boolean>[]> = {}
}

export class LayoutSetting {
  type: string = ''
  style: Record<string, string | number> = {}
  showType: string = ''
  children: LayoutSetting[] = []
}

export class LayoutStyle {
  backgroundColor: string = ''
  borderRadius: number = 0
  space: number = 0
  paddingLeft: number | string = 0
  paddingRight: number | string = 0
  paddingBottom: number | string = 0
  paddingTop: number | string = 0
}

export class LayoutParams {
  nativeCardData: NewsResponse
  currentIndex: number = 0
  extraInfo: Record<string, string | boolean | Record<string, string | boolean>[] | IButtonItem[]> = {}
  layout: LayoutSetting = new LayoutSetting()

  constructor(nativeCardData: NewsResponse, currentIndex: number,
    extraInfo: Record<string, string | boolean | Record<string, string | boolean>[]>, layout: LayoutSetting) {
    this.nativeCardData = nativeCardData
    this.currentIndex = currentIndex
    this.extraInfo = extraInfo
    this.layout = layout
  }
}