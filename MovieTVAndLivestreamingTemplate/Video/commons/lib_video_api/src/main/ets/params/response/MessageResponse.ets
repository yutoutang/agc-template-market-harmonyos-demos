import { AuthorResponse } from './AuthorResponse'

export interface BriefMsgInfo {
  allUnreadCount: number
  receiveTime: number
  latestNews: string
}

export interface BriefIMResponse {
  chatAuthor: AuthorResponse
  allUnreadCount: number
  receiveTime: number
  latestNews: string
  chatList: ChatInfoDetailResponse[]
}

export interface ChatInfoDetailResponse {
  type: string
  content: string
  isMyself?: boolean
  createTime?: number
}

export interface SystemDetailInfo {
  content: string
  createTime: number
}