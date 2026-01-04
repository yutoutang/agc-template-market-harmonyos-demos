import { AuthorResponse } from '../params/response/AuthorResponse'
import { CommentResponse } from '../params/response/CommentResponse'
import { AuthorModel } from './AuthorModel'

@ObservedV2
export class CommentModel implements CommentResponse {
  @Trace commentId: string
  @Trace parentCommentId?: string
  @Trace parentComment?: CommentModel
  @Trace videoId: string
  @Trace author: AuthorResponse
  @Trace commentBody: string
  @Trace commentLikeNum: number
  @Trace createTime: number
  @Trace isLiked: boolean
  @Trace replyComments: CommentModel[]

  constructor(v: CommentResponse) {
    this.commentId = v.commentId;
    this.parentCommentId = v.parentCommentId;
    if (v.parentComment) {
      this.parentComment = new CommentModel(v.parentComment);
    }
    this.videoId = v.videoId
    this.author = new AuthorModel(v.author);
    this.commentBody = v.commentBody;
    this.commentLikeNum = v.commentLikeNum;
    this.createTime = v.createTime;
    this.isLiked = v.isLiked;
    this.replyComments = v.replyComments.map(v => new CommentModel(v))
  }
}