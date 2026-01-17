import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { BaseAuthor, MyAuthor } from '../database/AuthorType';
import { BaseComment } from '../database/CommentType';
import { SafeRandomGenerate } from '../utils/SafeRandomNumer';
import {
  AuthorRequest,
  DeleteCommentRequest,
  ModifyPersonalInfoRequest,
  NewsRequest,
  PublishCommentRequest,
  SubscribeRequest,
  UserRequest,
} from '../params/request/CommonRequest';
import { NewsResponse } from '../params/response/NewsResponse';
import { AggregateNewsComment } from '../params/response/AggregateResponse';
import { CommentResponse } from '../params/response/CommentResponse';
import { BaseNewsServiceMock } from './BaseNewsServiceMock';
import { CommentServiceMock } from './CommentServiceMock';
import { AuthorServiceMock } from './AuthorServiceMock';
import { AvResponse } from '../params/response/AvResponse';

/**
 * 我的Mock
 */
export class MineServiceMock {
  private authorMock: AuthorServiceMock = new AuthorServiceMock();
  private baseNewsMock: BaseNewsServiceMock = new BaseNewsServiceMock();
  private commentMock: CommentServiceMock = new CommentServiceMock();

  public start(adapter: AxiosMockAdapter) {
    // 点赞
    adapter.onPost('/my/like/add').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as NewsRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      mineUserInfo.myLikes.splice(0, 0, data.newsId);

      const news = this.baseNewsMock.queryRawNews(data.newsId);
      const author = this.authorMock.queryAuthorRaw(news?.authorId);
      if (author?.likeNum) {
        author.likeNum++;
      }

      return [HttpStatusCode.Ok];
    });

    // 取消点赞
    adapter.onPost('/my/like/cancel').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as NewsRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const index = mineUserInfo.myLikes.findIndex(id => id === data.newsId);
      if (index !== -1) {
        mineUserInfo.myLikes.splice(index, 1);
      }
      const news = this.baseNewsMock.queryRawNews(data.newsId);
      if (news) {
        news.isLiked = false;
      }

      const author = this.authorMock.queryAuthorRaw(news?.authorId);
      if (author?.likeNum) {
        author.likeNum--;
      }

      return [HttpStatusCode.Ok];
    });

    // 查询我的点赞
    adapter.onGet('/my/like/list').reply(() => {
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const list = mineUserInfo.myLikes
        .map((id: string) => {
          return this.baseNewsMock.queryNews(id);
        })
        .filter(v => Boolean(v)) as NewsResponse[];
      return [HttpStatusCode.Ok, list];
    });

    // 查询新增的粉丝
    adapter.onGet('/new/fans/list').reply(() => {
      const list = this.authorMock.queryFollowers('').filter((v, index) => index < 5);
      return [HttpStatusCode.Ok, list];
    });

    // 添加关注
    adapter.onPost('/watch/add').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as AuthorRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      mineUserInfo.watchers.splice(0, 0, data.authorId);

      const otherUserInfo = this.authorMock.queryAuthorRaw(data.authorId) as BaseAuthor;
      otherUserInfo.followers.splice(0, 0, mineUserInfo.authorId);

      return [HttpStatusCode.Ok];
    });

    // 取消关注
    adapter.onPost('/watch/cancel').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as AuthorRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const index = mineUserInfo.watchers.findIndex(id => id === data.authorId);
      if (index !== -1) {
        mineUserInfo?.watchers.splice(index, 1);
      }

      const otherUserInfo = this.authorMock.queryAuthorRaw(data.authorId) as BaseAuthor;
      const index1 = otherUserInfo?.followers?.findIndex(id => id === mineUserInfo.authorId);
      if (index !== -1) {
        otherUserInfo?.followers?.splice(index1, 1);
      }

      return [HttpStatusCode.Ok];
    });

    // 订阅公众号
    adapter.onPost('/subscribe/add').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as SubscribeRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      mineUserInfo.subscribe.splice(0, 0, data.subscribeId);
      return [HttpStatusCode.Ok];
    });

    // 取消订阅
    adapter.onPost('/subscribe/cancel').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as SubscribeRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const index = mineUserInfo.subscribe.findIndex(id => id === data.subscribeId);
      if (index !== -1) {
        mineUserInfo?.subscribe.splice(index, 1);
      }
      return [HttpStatusCode.Ok];
    });

    // 取消全部订阅
    adapter.onPost('/subscribe/cancel/all').reply((config: AxiosRequestConfig) => {
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      if (mineUserInfo) {
        mineUserInfo.subscribe = []
      }
      return [HttpStatusCode.Ok];
    });

    // 查询我的订阅
    adapter.onGet('/my/subscribe/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as UserRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw(params.userId) as MyAuthor;
      const list = mineUserInfo.subscribe
        .map((id: string) => {
          return this.baseNewsMock.queryRawAv(id);
        })
        .filter(v => Boolean(v)) as AvResponse[];
      return [HttpStatusCode.Ok, list];
    });

    // 收藏
    adapter.onPost('/my/mark/add').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as NewsRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      mineUserInfo?.myMarks.splice(0, 0, data.newsId);
      return [HttpStatusCode.Ok];
    });

    // 取消收藏
    adapter.onPost('/mark/cancel').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as NewsRequest;

      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const index = mineUserInfo?.myMarks.findIndex(id => id === data.newsId);
      if (index !== -1) {
        mineUserInfo?.myMarks.splice(index, 1);
      }

      const news = this.baseNewsMock.queryRawNews(data.newsId);
      if (news) {
        news.isMarked = false;
      }
      return [HttpStatusCode.Ok];
    });

    // 查询我的收藏
    adapter.onGet('/my/mark/list').reply(() => {
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const list = mineUserInfo.myMarks
        .map((id: string) => {
          return this.baseNewsMock.queryNews(id);
        })
        .filter(v => Boolean(v)) as NewsResponse[];
      return [HttpStatusCode.Ok, list];
    });

    // 发表评论
    adapter.onPost('/publish/comment').reply((config: AxiosRequestConfig) => {
      const params = JSON.parse(config.data) as PublishCommentRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const newItem: BaseComment = {
        commentId: `comment_${SafeRandomGenerate.generate()}`,
        parentCommentId: params.parentCommentId,
        newsId: params.newsId,
        authorId: mineUserInfo.authorId,
        commentBody: params.content,
        commentLikeNum: 0,
        createTime: new Date().getTime(),
        isLiked: false,
        replyComments: [],
      };
      mineUserInfo.myComments.splice(0, 0, newItem.commentId);
      this.commentMock.addComment(newItem);
      const resp = this.commentMock.queryComment(newItem.commentId) as CommentResponse;
      return [HttpStatusCode.Ok, resp];
    });

    // 查询我的评论
    adapter.onGet('/my/comment/list').reply(() => {
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const comments = this.commentMock.queryCommentByAuthorId(mineUserInfo.authorId)
        .filter(v => !v.parentCommentId)
        .map(v => {
          const item = v as AggregateNewsComment;
          const resp = this.baseNewsMock.queryNews(v.newsId);
          if (resp) {
            item.newsDetailInfo = resp;
          }
          return item;
        })
        .sort((a, b) => b.createTime - a.createTime);
      return [HttpStatusCode.Ok, comments];
    });

    // 删除评论
    adapter.onPost('/comment/delete').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as DeleteCommentRequest;

      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const index = mineUserInfo.myComments.findIndex(v => v === data.commentId);
      if (index !== -1) {
        mineUserInfo.myComments.splice(index, 1);
      }
      this.commentMock.deleteComment(data.commentId);
      return [HttpStatusCode.Ok];
    });

    // 添加到阅读历史
    adapter.onPost('/history/add').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as NewsRequest;
      this.deleteFromHistory(data.newsId);
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      mineUserInfo?.myHistory.splice(0, 0, data.newsId);
      return [HttpStatusCode.Ok];
    });

    // 从阅读历史中删除
    adapter.onPost('/history/delete').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as NewsRequest;
      this.deleteFromHistory(data.newsId);
      return [HttpStatusCode.Ok];
    });

    // 查询我的阅读记录
    adapter.onGet('/my/history/list').reply(() => {
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
      const list = mineUserInfo.myHistory
        .map((id: string) => {
          return this.baseNewsMock.queryNews(id);
        })
        .filter(v => Boolean(v)) as NewsResponse[];
      return [HttpStatusCode.Ok, list];
    });

    // 修改个人信息
    adapter.onPost('/modify/personal/info').reply((config: AxiosRequestConfig) => {
      const params = JSON.parse(config.data) as ModifyPersonalInfoRequest;
      const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
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
      return [HttpStatusCode.Ok];
    });
  }

  public deleteFromHistory(newsId: string) {
    const mineUserInfo = this.authorMock.queryAuthorRaw() as MyAuthor;
    const index = mineUserInfo?.myHistory.findIndex(id => id === newsId);
    if (index !== -1) {
      mineUserInfo?.myHistory.splice(index, 1);
    }
  }
}