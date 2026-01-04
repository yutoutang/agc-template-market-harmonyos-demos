/**
 * 评论数据库字段
 */
export interface BaseComment {
  // 评论id
  commentId: string
  // 父评论ID
  parentCommentId?: string
  // 从属id
  videoId: string
  // 评论的作者
  authorId: string
  // 评论的内容
  commentBody: string
  // 评论被点赞数量
  commentLikeNum: number
  // 评论时间
  createTime: number
  // 是否被我点赞
  isLiked: boolean
  // 被回复的评论列表
  replyComments: string[]
}
