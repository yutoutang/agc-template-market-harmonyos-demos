import { Constants } from '../commons/Constants';
import { CommentInfoResp, CommentItem, KeywordItem, StoreItem, SubmitCommentRequest } from '../commons/Types';
import { MockData } from './MockData';

export class CommentApis {
  private static _commentList: CommentItem[] = JSON.parse(JSON.stringify(MockData.COMMENT_LIST_MOCK))

  // 获取综合评分
  public static getRatingSummary(): Promise<KeywordItem[]> {
    return CommentApis._simulateDelay(MockData.KEYWORD_LIST_MOCK)
  }

  // 获取评论列表
  public static getCommentInfo(curPage: number): Promise<CommentInfoResp> {
    const startIdx: number = (curPage - 1) * Constants.COMMENT_PAGE_SIZE
    const list = CommentApis._commentList.slice(startIdx, startIdx + Constants.COMMENT_PAGE_SIZE)
    const resp: CommentInfoResp = {
      totalNum: CommentApis._commentList.length,
      curPage,
      commentList: list,
    };
    return CommentApis._simulateDelay(resp);
  }

  // 获取可评论的店铺列表
  public static getStoreList(): Promise<StoreItem[]> {
    const resp = MockData.HOTEL_LIST_MOCK;
    return CommentApis._simulateDelay(resp);
  }

  // 提交评论
  public static submitComment(data: SubmitCommentRequest): Promise<number> {
    const store = MockData.HOTEL_LIST_MOCK.find((item) => item.id === data.hotelId)
    const item: CommentItem = {
      avatar: '',
      userName: '',
      desc: data.comment,
      star: data.overallScore,
      date: data.commentTime,
      location: store?.name ?? '',
    };
    CommentApis._commentList.unshift(item)
    return CommentApis._simulateDelay(0);
  }

  private static _simulateDelay<T>(data: T, delay: number = 500): Promise<T> {
    return new Promise<T>((resolve) => {
      setTimeout(() => {
        resolve(data);
      }, delay);
    });
  }
}