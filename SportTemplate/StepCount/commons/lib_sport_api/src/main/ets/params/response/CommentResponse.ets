import { AuthorResponse } from './AuthorResponse';

/**
 * 评论-云侧接口响应模型
 */
export interface CommentResponse {
  // 评论id
  commentId: string
  // 父评论ID
  parentCommentId?: string
  // 父评论详情
  parentComment?: CommentResponse
  // 从属新闻id
  newsId: string
  // 评论的作者
  author: AuthorResponse
  // 评论的内容
  commentBody: string
  // 评论被点赞数量
  commentLikeNum: number
  // 评论时间
  createTime: number
  // 是否被我点赞
  isLiked: boolean
  // 被回复的评论列表
  replyComments: CommentResponse[]
}