export interface CommentItem {
  avatar?: ResourceStr;
  userName: string;
  date: string;
  location: string;
  star: number;
  desc: string;
}

export interface KeywordItem {
  desc: string;
  count: number;
}

export interface CommentInfoResp {
  commentList: CommentItem[];
  totalNum:number
  curPage:number
}

export interface StoreItem {
  name: string;
  type: string;
  id: number;
}

// 发表评论
export interface SubmitCommentRequest {
  comment: string;
  overallScore: number;
  serviceScore: number;
  environmentScore: number;
  deviceScore: number;
  experienceScore: number;
  hotelId: number;
  isAnonymous: number;
  userId: string;
  commentTime: string;
}