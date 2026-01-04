import { AuthorInfo, CommentInfo } from '../model/Model'

@ObservedV2
export class MakeObCommentServed extends CommentInfo {
  commentId: string = ''
  videoId: string = ''
  author: AuthorInfo = new AuthorInfo()
  commentBody: string = ''
  replyAuthor: AuthorInfo = new AuthorInfo()
  @Trace commentLikeNum: number = 0
  createTime: number = 0
  @Trace isLiked: boolean = false
  shareCount: number = 0
  @Trace likeCount: number = 0
  @Trace replyComments: CommentInfo[] = []
  isExpand: boolean = false

  constructor(value: CommentInfo) {
    super()
    this.commentId = value.commentId
    this.videoId = value.videoId
    this.author = value.author
    this.commentBody = value.commentBody
    this.replyAuthor = value?.parentComment?.author ?? new AuthorInfo()
    this.commentLikeNum = value.commentLikeNum
    this.createTime = value.createTime
    this.isLiked = value.isLiked
    this.likeCount = value.likeCount
    this.replyComments = value.replyComments.map((item) => new MakeObCommentServed(item))
  }
}

export function extractText(html: string | undefined): string {
  let htmlContent = html ?? ''
  let text = htmlContent.replace(/<[^>]*>/g, '');
  // 再移除所有空格和换行符
  return text.replace(/[\s\n\r]/g, '');
}

export function transformPixelmap(context: Context, resource: Resource) {
  let imagePixelMap: PixelMap | undefined = undefined;
  return imagePixelMap
}
