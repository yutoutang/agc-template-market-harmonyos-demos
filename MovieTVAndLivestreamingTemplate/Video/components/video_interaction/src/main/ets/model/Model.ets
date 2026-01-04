@ObservedV2
export class UserInfoModel {
  @Trace isLogin: boolean = false;
  @Trace authorId: string = '';
  @Trace authorNickName: string = '';
  @Trace authorIcon: string = '';
  @Trace authorUid: string = '';
  @Trace authorDesc: string = '';
  @Trace authorPhone: string = '';
  @Trace authorIp: string = '';
  @Trace watchersCount: number = 0;
  @Trace followersCount: number = 0;
  @Trace watchers: string[] = [];
  @Trace followers: string[] = [];
  @Trace likeNum: number = 0;
  @Trace loginChannel: string = '';
}


@ObservedV2
export class Tmp {
  @Trace paramA1?: ESObject[] = [];
  total?: number = 0;
}

export class AuthorInfo {
  authorId: string = ''
  authorNickName: string = ''
  authorIcon: string = ''
  authorDesc: string = ''
  authorIp: string = ''
  watchersCount: number = 0
  followersCount: number = 0
  likeNum: number = 0

  constructor(userInfo?: UserInfoModel) {
    this.authorId = userInfo?.authorId ?? ''
    this.authorNickName = userInfo?.authorNickName ?? ''
    this.authorIcon = userInfo?.authorIcon ?? ''
    this.authorDesc = userInfo?.authorDesc ?? ''
    this.authorIp = userInfo?.authorIp ?? ''
    this.watchersCount = userInfo?.watchersCount ?? 0
    this.followersCount = userInfo?.followersCount ?? 0
    this.likeNum = userInfo?.likeNum ?? 0
  }
}

@ObservedV2
export class CommentInfo {
  commentId: string = ''
  videoId: string = ''
  author: AuthorInfo = new AuthorInfo()
  parentComment?: CommentInfo
  commentLikeNum: number = 0
  commentBody: string = ''
  createTime: number = 0
  isReply?: boolean
  @Trace likeCount: number = 0
  @Trace isLiked: boolean = false
  @Trace replyComments: CommentInfo[] = []
}


@ObservedV2
export class MakeObCommentServed extends CommentInfo {
  commentId: string = ''
  newsId: string = ''
  author: AuthorInfo = new AuthorInfo()
  commentBody: string = ''
  replyAuthor: AuthorInfo = new AuthorInfo()
  createTime: number = 0
  shareCount: number = 0
  isExpand: boolean = false
  isReply?: boolean
  @Trace replyComments: CommentInfo[] = []
  @Trace likeCount: number = 0
  @Trace commentLikeNum: number = 0
  @Trace isLiked: boolean = false

  constructor(value: CommentInfo) {
    super()
    this.commentLikeNum = value.commentLikeNum
    this.author = value.author
    this.commentBody = value.commentBody
    this.isLiked = value.isLiked
    this.createTime = value.createTime
    this.likeCount = value.likeCount
    this.replyAuthor = value?.parentComment?.author ?? new AuthorInfo()
    this.replyComments = value.replyComments.map((item) => new MakeObCommentServed(item))
    this.commentId = value.commentId
    this.newsId = value.videoId
    this.isReply = value.isReply
  }
}

export interface BuilderParams {
  delete: () => void
  cancel: () => void
  reply: () => void
  isCommentOwner: boolean
  fontSizeRatio: number
  isReply: boolean
}