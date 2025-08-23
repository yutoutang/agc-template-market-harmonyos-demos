import { DramaInfo } from "../../../bean/common/DramaInfo";

export interface Episode {
  id: number;
  url: string;
  desc: string;
  dramaId: string;
  socialInfo: {
    likeCount: string;
    favoriteCount: string;
    shareCount: string;
    commentCount: string;
  }
}

export interface ActorInfo {
  id: string;
  name: string;
  avatar: string;
}

export interface Drama {
  id: string;
  coverUrl: string;
  promotionalUrl: string;
  name: string;
  description: string;
  totalCount: number;
  latestUpdate: number;
  category: string[];
  actorInfo: Array<ActorInfo>
  curIndex: number
  popular: string
  favoriteCount: number
  isFavorite: boolean
  likeCount: number
  isLike: boolean
  isVip?: boolean
}

export interface CommentItem {
  id: number; // 唯一编号
  drama: DramaInfo; // 评论对应剧集
  coverUrl: string; // 剧集封面
  avatar: string; // 头像
  name: string; // 昵称
  commentContent: string; // 评论内容
  timeAgo: number; // 评论时间
  isLike: boolean; // 是否点赞
  likeCount: number; // 点赞数量
  likeList: LikeInfo[]; // 点赞昵称列表
  replyList: ReplyItem[]; // 评论回复列表
}

export interface ReplyItem {
  replyAvatar: string; // 头像
  replyName: string; // 昵称
  replyContent: string; // 内容
  replyTimeAgo: number; // 时间
  replyIsLike: boolean; // 是否点赞
  replyLikeCount: number; // 点赞数量
  replyLikeList: LikeInfo[]; // 点赞列表
  replyPeople: string; // 回复对象昵称
  replyComment: string; // 回复对应的评论内容
}

export interface LikeInfo {
  likeAvatar: string;
  likeName: string;
  likeTime: number;
}

export interface Replying {
  id: number;
  reply: ReplyItem;
}

export interface ReplyLike {
  id: number;
  index: number;
}