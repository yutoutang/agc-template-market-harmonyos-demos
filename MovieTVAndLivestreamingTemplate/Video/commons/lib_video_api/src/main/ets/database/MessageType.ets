import { ChatEnum } from '../constants/Constants'

export interface BriefIMInfo {
  chatAuthorId: string
  allUnreadCount: number
  receiveTime: number
  latestNews: string
  chatList: ChatInfoDetail[]
}

export interface ChatInfoDetail {
  type: ChatEnum
  content: string
  isMyself?: boolean
  createTime?: number
}