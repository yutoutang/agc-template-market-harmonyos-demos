import { AuthorResponse } from './AuthorResponse';
import { CommentResponse } from './CommentResponse';
import { VideoResponse } from './VideoResponse';

/**
 * 编排新闻和评论
 */
export interface AggregateNewsComment extends CommentResponse {
  // 评论id
  commentId: string
  // 所回复的评论id
  parentCommentId?: string
  // 所回复的评论
  parentComment?: CommentResponse
  // 从属新闻id
  videoId: string
  // 新闻详细
  videoDetailInfo: VideoResponse
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

/**
 * 消息-查看当前评论全部列表
 */
export interface CommentDetailResponse {
  root: AggregateNewsComment
  current: CommentResponse | undefined
  list: CommentResponse[]
}