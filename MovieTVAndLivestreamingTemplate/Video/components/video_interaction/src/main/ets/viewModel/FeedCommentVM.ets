import { AuthorInfo, CommentInfo, MakeObCommentServed, UserInfoModel } from '../model/Model'
import { CommentEventDispatcher } from '../utils/EventDispatcher'
import { cryptoFramework } from '@kit.CryptoArchitectureKit'

@ObservedV2
export class FeedCommentVM {
  private static _instance: FeedCommentVM
  @Trace fontSizeRatio: number = 1
  @Trace isDark: boolean = false
  userInfo: UserInfoModel = new UserInfoModel()

  public static get instance() {
    if (!FeedCommentVM._instance) {
      FeedCommentVM._instance = new FeedCommentVM()
    }
    return FeedCommentVM._instance
  }

  public setUserInfo(userInfo: UserInfoModel) {
    this.userInfo = userInfo
  }

  public addComment(commentInfo: CommentInfo, replyContent: string, isReply: boolean = false) {
    /*
     * mock 随机入库操作
     * */
    let currentComment: CommentInfo = {
      commentId: `${commentInfo.commentId}_${this.secureRandom()}`,
      videoId: commentInfo.videoId,
      author: new AuthorInfo(this.userInfo),
      commentBody: replyContent,
      commentLikeNum: 0,
      createTime: new Date().getTime(),
      likeCount: 0,
      isLiked: false,
      replyComments: [],
      isReply: isReply
    }
    commentInfo.replyComments.unshift(new MakeObCommentServed(currentComment))
    CommentEventDispatcher.dispatchToAddComment(currentComment, commentInfo.commentId)
  }

  public deleteComment(commentId: string) {
    CommentEventDispatcher.dispatchToDeleteComment(commentId)
  }

  public setFontSizeRatio(fontSizeRatio: number) {
    this.fontSizeRatio = fontSizeRatio
  }

  public setIsDark(isDark: boolean) {
    this.isDark = isDark
  }

  public giveLike(commentInfo: CommentInfo, isLike: boolean) {
    CommentEventDispatcher.dispatchToGiveLike(commentInfo, isLike)
  }

  // 使用 crypto.getRandomValues 生成安全的随机数
  public secureRandom(): number {
    let rand = cryptoFramework.createRandom();
    // 设置生成随机数的字节长度为1
    let randData = rand.generateRandomSync(1);
    return randData.data[0];
  }
}