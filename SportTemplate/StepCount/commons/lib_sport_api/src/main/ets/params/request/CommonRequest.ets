import { ChatEnum } from '../../constants/Constants'
import { PostImgList } from '../base/BaseModel'

/**
 * 发布动态请求字段
 */
export interface PostRequest {
  // 正文
  postBody: string
  // 图片、视频链接
  postImgList?: PostImgList[]
}

/**
 * 修改个人信息
 */
export interface ModifyPersonalInfoRequest {
  authorIcon?: string
  authorNickName?: string
  authorPhone?: string
  authorDesc?: string
  authorRegion?: string
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
  newsId: string
  content: string
  parentCommentId?: string
}