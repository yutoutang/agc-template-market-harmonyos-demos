import { AuthorService } from './AuthorService';
import { MyAuthor } from '../database/AuthorType';
import { BaseComment } from '../database/CommentType';
import { CommentServiceApi } from './CommentService';
import { ModifyPersonalInfoRequest, PublishCommentRequest } from '../params/request/CommonRequest';
import { CommentResponse } from '../params/response/CommentResponse';
import { AuthorResponse } from '../params/response/AuthorResponse';
import { AggregateNewsComment } from '../params/response/AggregateResponse';
import { AsyncFunc } from '../utils/AsyncUtils';
import { VideoResponse } from '../params/response/VideoResponse';
import { VideoServiceApi } from './VideoService';
import { util } from '@kit.ArkTS';

/**
 * 我的管理类
 */
export class MineService extends AuthorService {
  /**
   * 点赞
   * @param newsId
   */
  public addLike(newsId: string) {
    const mineUserInfo = this.queryAuthorRaw() as MyAuthor;
    mineUserInfo.myLikes.splice(0, 0, newsId);
  }

  /**
   * 取消点赞
   * @param newsId
   */
  public cancelLike(newsId: string) {
    const mineUserInfo = this.queryAuthorRaw() as MyAuthor;
    const index = mineUserInfo.myLikes.findIndex(id => id === newsId);
    if (index !== -1) {
      mineUserInfo.myLikes.splice(index, 1);
    }
  }

  /**
   * 查询新增的粉丝
   * @returns
   */
  public queryNewFans(): AuthorResponse[] {
    return this.queryFollowers('').filter((v, index) => index < 5);
  }

  /**
   * 添加关注
   * @param authorId
   */
  public addWatch(authorId: string) {
    const mineUserInfo = this.queryAuthorRaw() as MyAuthor;
    mineUserInfo.watchers.splice(0, 0, authorId);
  }

  /**
   * 取消关注
   * @param authorId
   */
  public cancelWatch(authorId: string) {
    const mineUserInfo = this.queryAuthorRaw() as MyAuthor;
    const index = mineUserInfo.watchers.findIndex(id => id === authorId);
    if (index !== -1) {
      mineUserInfo?.watchers.splice(index, 1);
    }
  }

  /**
   * 收藏
   * @param newsId
   */
  public addMark(newsId: string) {
    const mineUserInfo = this.queryAuthorRaw() as MyAuthor;
    mineUserInfo?.myMarks.splice(0, 0, newsId);
  }

  /**
   * 取消收藏
   * @param newsId
   */
  public cancelMark(newsId: string) {
    const mineUserInfo = this.queryAuthorRaw() as MyAuthor;
    const index = mineUserInfo?.myMarks.findIndex(id => id === newsId);
    if (index !== -1) {
      mineUserInfo?.myMarks.splice(index, 1);
    }
  }


  /**
   * 发表评论
   * @param params
   */
  @AsyncFunc
  public async publishComment(params: PublishCommentRequest) {
    const mineUserInfo = this.queryAuthorRaw() as MyAuthor;
    const newItem: BaseComment = {
      commentId: `comment_${util.generateRandomUUID().replace(/-/g, '').substring(2, 15)}`,
      parentCommentId: params.parentCommentId,
      videoId: params.videoId,
      authorId: mineUserInfo.authorId,
      commentBody: params.content,
      commentLikeNum: 0,
      createTime: new Date().getTime(),
      isLiked: false,
      replyComments: [],
    };
    mineUserInfo.myComments.splice(0, 0, newItem.commentId);
    CommentServiceApi.addComment(newItem);
    return CommentServiceApi.queryComment(newItem.commentId) as CommentResponse;
  }

  /**
   * 查询我的评论
   * @returns
   */
  public queryMineCommentList(): AggregateNewsComment[] {
    const mineUserInfo = this.queryAuthorRaw() as MyAuthor;
    const comments = CommentServiceApi.queryCommentByAuthorId(mineUserInfo.authorId)
      .filter(v => !v.parentCommentId)
      .map(v => {
        const item = v as AggregateNewsComment;
        const resp = VideoServiceApi.queryVideoDetail(v.videoId);
        if (resp) {
          item.videoDetailInfo = resp;
        }
        return item;
      })
      .sort((a, b) => b.createTime - a.createTime);
    return comments;
  }

  /**
   * 删除评论
   */
  public deleteComment(newsId: string, commentId: string) {
    const mineUserInfo = this.queryAuthorRaw() as MyAuthor;
    const index = mineUserInfo.myComments.findIndex(v => v === commentId);
    if (index !== -1) {
      mineUserInfo.myComments.splice(index, 1);
    }
    CommentServiceApi.deleteComment(commentId);
  }

  /**
   * 添加到阅读历史
   * @param newsId
   */
  public addToHistory(newsId: string) {
    this.deleteFromHistory(newsId);
    const mineUserInfo = this.queryAuthorRaw() as MyAuthor;
    mineUserInfo?.myHistory.splice(0, 0, newsId);
  }

  /**
   * 从视频历史中全部删除
   * @param newsId
   */
  public deleteFromHistory(videoId: string | string[]) {
    const mineUserInfo = this.queryAuthorRaw() as MyAuthor;
    if (!mineUserInfo?.myHistory) {
      return;
    }

    if (Array.isArray(videoId)) {
      // 处理字符串数组情况
      mineUserInfo.myHistory = mineUserInfo.myHistory.filter(id => !videoId.includes(id));
    } else {
      // 处理单个字符串情况
      const index = mineUserInfo.myHistory.findIndex(id => id === videoId);
      if (index !== -1) {
        mineUserInfo.myHistory.splice(index, 1);
      }
    }
  }


  /**
   * 查询浏览历史
   * @param
   */
  public queryMyHistory(): VideoResponse[] {
    const mineUserInfo = this.queryAuthorRaw() as MyAuthor;
    const videoResponse = mineUserInfo.myHistory
      .map((videoId: string) => {
        return VideoServiceApi.queryVideoDetail(videoId);
      })
      .filter(v => Boolean(v)) as VideoResponse[];
    return videoResponse;
  }

  public queryMyComment(): VideoResponse[] {
    const mineUserInfo = this.queryAuthorRaw() as MyAuthor;
    const videoResponse = mineUserInfo.myHistory
      .map((commentId: string) => {
        return VideoServiceApi.queryVideoDetail(commentId);
      })
      .filter(v => Boolean(v)) as VideoResponse[];
    return videoResponse;
  }

  /**
   * 修改个人信息
   * @param nickName
   */
  public modifyPersonalInfo(params: ModifyPersonalInfoRequest) {
    const mineUserInfo = this.queryAuthorRaw() as MyAuthor;
    if (params.authorIcon) {
      mineUserInfo.authorIcon = params.authorIcon;
    }
    if (params.authorNickName) {
      mineUserInfo.authorNickName = params.authorNickName;
    }
    if (params.authorPhone) {
      mineUserInfo.authorPhone = params.authorPhone;
    }
    if (params.authorDesc) {
      mineUserInfo.authorDesc = params.authorDesc;
    }
  }
}

const instance = new MineService();

export { instance as MineServiceApi };