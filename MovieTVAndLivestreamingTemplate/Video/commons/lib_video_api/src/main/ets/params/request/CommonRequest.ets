import { ChatEnum } from '../../constants/Constants'

/**
 * 修改个人信息
 */
export interface ModifyPersonalInfoRequest {
  authorIcon?: string
  authorNickName?: string
  authorPhone?: string
  authorDesc?: string
}

/**
 * 发送消息
 */
export interface SendMessageRequest {
  type: ChatEnum
  content: string
  createTime: number
}

/**
 * 发表评论
 */
export interface PublishCommentRequest {
  videoId: string
  content: string
  parentCommentId?: string
}