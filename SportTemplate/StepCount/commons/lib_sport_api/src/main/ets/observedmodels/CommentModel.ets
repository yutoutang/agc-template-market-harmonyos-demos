import { AuthorResponse } from '../params/response/AuthorResponse'
import { CommentResponse } from '../params/response/CommentResponse'
import { AuthorModel } from './AuthorModel'

@ObservedV2
export class CommentModel implements CommentResponse {
  @Trace commentId: string
  @Trace parentCommentId?: string
  @Trace parentComment?: CommentModel
  @Trace newsId: string
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
    this.newsId = v.newsId
    this.author = new AuthorModel(v.author);
    this.commentBody = v.commentBody;
    this.commentLikeNum = v.commentLikeNum;
    this.createTime = v.createTime;
    this.isLiked = v.isLiked;
    this.replyComments = v.replyComments.map(v => new CommentModel(v))
  }
}

// 三环数据模型
export class ThreeRingModel {
  stepData: number[] = [0, 0];
  distanceData: number[] = [0, 0];
  caloriesData: number[] = [0, 0];
}

// 近七天总数据（[实际总和,目标总和]）
export class SevenDaysTotalModel {
  stepData: number[] = [0, 0];
  distanceData: number[] = [0, 0];
  caloriesData: number[] = [0, 0];
}