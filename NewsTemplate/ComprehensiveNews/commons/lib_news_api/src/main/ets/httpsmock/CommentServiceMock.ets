import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { BaseComment } from '../database/CommentType';
import {
  CommentInfoRequest,
  CommentListRequest,
  CommentRequest,
  NewsRequest,
} from '../params/request/CommonRequest';
import { CommentResponse } from '../params/response/CommentResponse';
import { MockArticle } from './mockdata/MockArticle';
import { MockComment } from './mockdata/MockComment';
import { MockPost } from './mockdata/MockPost';
import { MockVideo } from './mockdata/MockVideo';
import { AuthorServiceMock } from './AuthorServiceMock';

/**
 * 评论管理Mock
 */
export class CommentServiceMock {
  private authorMock: AuthorServiceMock = new AuthorServiceMock();

  public start(adapter: AxiosMockAdapter) {
    // 查询单个评论
    adapter.onGet('/comment').reply((config: AxiosRequestConfig) => {
      const params = config.params as CommentInfoRequest;
      const resp = this.queryComment(params.commentId, params.ignoreReplyInner);
      return [HttpStatusCode.Ok, resp];
    });

    // 查询评论列表
    adapter.onGet('/news/comment/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as CommentListRequest;
      let resp: CommentResponse[] | undefined = undefined;
      const item = this.queryRawCommentList(params.newsId);
      if (item?.length) {
        resp = item.map(comment => {
          return this.handleCommentRaw(comment, false, false, params.ignoreReplyInner);
        })
      }
      return [HttpStatusCode.Ok, resp];
    });

    // 查询评论的总数
    adapter.onGet('/comment/count').reply((config: AxiosRequestConfig) => {
      const params = config.params as NewsRequest;
      const count = this.queryRawCommentList(params.newsId).length;
      return [HttpStatusCode.Ok, count];
    });

    // 添加评论
    adapter.onPost('/comment/add').reply((config: AxiosRequestConfig) => {
      const newItem = JSON.parse(config.data) as BaseComment;
      this.addComment(newItem);
      return [HttpStatusCode.Ok];
    });

    // 删除评论
    adapter.onPost('/comment/delete').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as CommentRequest;
      this.deleteComment(data.commentId);
      return [HttpStatusCode.Ok];
    });

    // 点赞评论
    adapter.onPost('/comment/like').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as CommentRequest;
      const item = MockComment.list.find(v => v.commentId === data.commentId);
      if (item) {
        item.isLiked = true;
        item.commentLikeNum += 1;
      }
      return [HttpStatusCode.Ok];
    });

    // 取消点赞评论
    adapter.onPost('/comment/like/cancel').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as CommentRequest;
      const item = MockComment.list.find(v => v.commentId === data.commentId);
      if (item) {
        item.isLiked = false;
        item.commentLikeNum -= 1;
      }
      return [HttpStatusCode.Ok];
    });

    // 文章动态点赞接口
    adapter.onPost('/news/like').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as NewsRequest;
      const item = [...MockPost.list, ...MockArticle.list, ...MockVideo.list].find(v => v.id === data.newsId);
      if (item) {
        item.isLiked = true;
        item.likeCount += 1;
      }
      return [HttpStatusCode.Ok];
    });

    // 文章动态取消点赞接口
    adapter.onPost('/news/like/cancel').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as NewsRequest;
      const item = [...MockPost.list, ...MockArticle.list, ...MockVideo.list].find(v => v.id === data.newsId);
      if (item) {
        item.isLiked = false;
        item.likeCount -= 1;
      }
      return [HttpStatusCode.Ok];
    });
  }

  /**
   * 查询单个评论
   * @param commentId
   * @param ignoreReplyInner
   * @returns
   */
  public queryComment(commentId: string, ignoreReplyInner: boolean = false): CommentResponse | undefined {
    const item = this.queryRawComment(commentId);
    if (item) {
      return this.handleCommentRaw(item, false, false, ignoreReplyInner);
    }
    return undefined;
  }

  /**
   * 查数据库
   * @param commentId
   * @returns
   */
  private queryRawComment(commentId: string): BaseComment | undefined {
    return MockComment.list.find(v => v.commentId === commentId);
  }

  /**
   * 查数据库
   * @param commentId
   * @returns
   */
  public queryRawCommentList(newsId: string): BaseComment[] {
    return MockComment.list.filter(v => v.newsId === newsId && !v.parentCommentId);
  }

  /**
   * 数据库字段转换成接口字段
   * @param item
   * @returns
   */
  private handleCommentRaw(item: BaseComment, ignoreParent: boolean = false,
    ignoreReplyOuter: boolean = false, ignoreReplyInner: boolean = true): CommentResponse {
    const copyItem = JSON.parse(JSON.stringify(item)) as CommentResponse;
    const authorInfo = this.authorMock.queryAuthorInfo(item.authorId);
    if (authorInfo) {
      copyItem.author = authorInfo;
    }

    if (item.parentCommentId && !ignoreParent) {
      const parentComment = this.queryRawComment(item.parentCommentId);
      if (parentComment) {
        copyItem.parentComment = this.handleCommentRaw(parentComment, true, ignoreReplyInner);
      }
    }

    if (copyItem.replyComments.length && !ignoreReplyOuter) {
      copyItem.replyComments = item.replyComments
        .map((id: string) => {
          const comment = this.queryRawComment(id);
          if (comment) {
            return this.handleCommentRaw(comment, false, ignoreReplyInner);
          }
          return undefined;
        })
        .filter(v => Boolean(v)) as CommentResponse[]
    } else {
      copyItem.replyComments = [];
    }
    return copyItem;
  }

  /**
   * 扁平化评论数组
   * @param arr
   * @returns
   */
  private flattenWithReduce(arr: CommentResponse[]): CommentResponse[] {
    return arr.reduce((acc, current) => {
      // 若当前元素是数组，递归扁平化后合并到累加器
      if (Array.isArray(current.replyComments)) {
        return acc.concat(this.flattenWithReduce(current.replyComments));
      }
      // 否则直接添加到累加器
      acc.push(current);
      return acc;
    }, arr);
  }


  /**
   * 查询根评论
   * @param commentId
   */
  public queryRootComment(commentId: string = ''): string {
    const item = MockComment.list.find(v => v.commentId === commentId);
    if (item?.parentCommentId) {
      return this.queryRootComment(item.parentCommentId);
    }
    return item?.commentId || '';
  }

  /**
   * 查询根评论下所有相关评论
   * @param commentId
   * @returns
   */
  public queryAllReplyComment(commentId: string): CommentResponse[] {
    const item = this.queryRawComment(commentId);
    let list: CommentResponse[] = [];
    if (item) {
      const resp = this.handleCommentRaw(item, false, false, false);
      list = this.flattenWithReduce(resp.replyComments)
    }
    return list;
  }

  /**
   * 添加评论
   * @param item
   */
  public addComment(newItem: BaseComment) {
    if (newItem.parentCommentId) {
      let parent = MockComment.list.find(item => item.commentId === newItem.parentCommentId)
      if (parent) {
        parent.replyComments.unshift(newItem.commentId)
      }
    }
    MockComment.list.splice(0, 0, newItem);
  }

  /**
   * 删除评论
   * @param commentId
   */
  public deleteComment(commentId: string) {
    const index = MockComment.list.findIndex(v => v.commentId === commentId);
    if (index !== -1) {
      MockComment.list.splice(index, 1);
    }
  }

  /**
   * 通过作者id过滤
   * @param authorId
   * @returns
   */
  public queryCommentByAuthorId(authorId: string): CommentResponse[] {
    const list = MockComment.list
      .filter(v => v.authorId === authorId)
      .map(v => this.handleCommentRaw(v));

    return list;
  }
}