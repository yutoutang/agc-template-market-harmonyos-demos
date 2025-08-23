import { DramaInfo } from './DramaInfo';

export class CommentInfo {
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
  replyList: ReplyInfo[]; // 评论回复列表

  constructor(commentInfo: any) {
    this.id = commentInfo?.id;
    this.drama = commentInfo?.drama;
    this.coverUrl = commentInfo?.coverUrl;
    this.avatar = commentInfo?.avatar;
    this.name = commentInfo?.name;
    this.commentContent = commentInfo?.commentContent;
    this.timeAgo = commentInfo?.timeAgo;
    this.isLike = commentInfo?.isLike;
    this.likeCount = commentInfo?.likeCount;
    this.likeList = commentInfo?.likeList;
    this.replyList = commentInfo?.replyList;
  }
}

export class ReplyInfo {
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

export class LikeInfo {
  likeAvatar: string;
  likeName: string;
  likeTime: number;
}