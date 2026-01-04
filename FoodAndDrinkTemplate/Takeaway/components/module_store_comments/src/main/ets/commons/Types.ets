import { RatingLayoutType } from './Enums';

export interface CommentItem {
  avatar?: ResourceStr;
  userName: string;
  date: string;
  location: string;
  star: number;
  desc: string;
}

export interface KeyWordItem {
  desc: string;
  count: number;
  layoutType: RatingLayoutType;

}

export interface CommentInfoResp {
  commentList: CommentItem[];
  totalNum: number
  curPage: number
}

export interface StoreItem {
  name: string;
  type: string;
  id: number;
}

/**
 * 提交评论请求数据结构
 * 包含评论内容、各项评分以及相关信息
 */
export interface SubmitCommentRequest {
  /** 总体评分 */
  overallScore: number;

  /** 味道评分 */
  taste: number;

  /** 包装评分 */
  packing: number;

  /** 配送评分 */
  delivery: number;

  /** 店铺id */
  storeId: number;

  /** 订单号 */
  orderNo: string;

  /** 用户ID */
  userId: string;

  /** 是否匿名 0-实名 1-匿名 */
  isAnonymous: number;

  /** 评论时间 */
  commentTime: string;

  /** 评论内容 */
  comment: string;
}