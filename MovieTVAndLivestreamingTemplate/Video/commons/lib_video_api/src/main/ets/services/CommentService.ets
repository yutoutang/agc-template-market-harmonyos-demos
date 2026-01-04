import { BaseComment } from '../database/CommentType';
import { CommentResponse } from '../params/response/CommentResponse';
import { AuthorServiceApi } from './AuthorService';
import { MockComment } from './mockdata/MockComment';

/**
 * 评论类
 */
export class CommentService {
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
  private queryRawCommentList(videoId: string): BaseComment[] {
    return MockComment.list.filter(v => v.videoId === videoId && !v.parentCommentId);
  }

  /**
   * 数据库字段转换成接口字段
   * @param item
   * @returns
   */
  private handleCommentRaw(item: BaseComment, ignoreParent: boolean = false,
    ignoreReply: boolean = false): CommentResponse {
    const copyItem = JSON.parse(JSON.stringify(item)) as CommentResponse;
    const authorInfo = AuthorServiceApi.queryAuthorInfo(item.authorId);
    if (authorInfo) {
      copyItem.author = authorInfo;
    }

    if (item.parentCommentId && !ignoreParent) {
      const parentComment = this.queryRawComment(item.parentCommentId);
      if (parentComment) {
        copyItem.parentComment = this.handleCommentRaw(parentComment, true, true);
      }
    }

    if (copyItem.replyComments.length && !ignoreReply) {
      copyItem.replyComments = item.replyComments
        .map((id: string) => {
          const comment = this.queryRawComment(id);
          if (comment) {
            return this.handleCommentRaw(comment, false, true);
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
   * 查询单个评论
   * @param commentId
   * @returns
   */
  public queryComment(commentId: string): CommentResponse | undefined {
    const item = this.queryRawComment(commentId);
    if (item) {
      return this.handleCommentRaw(item);
    }
    return undefined;
  }

  /**
   * 查询评论列表
   * @param commentId
   * @returns
   */
  public queryCommentList(newsId: string): CommentResponse[] | undefined {
    const item = this.queryRawCommentList(newsId);
    if (item?.length) {
      let res = item.map(comment => {
        return this.handleCommentRaw(comment);
      })
      return res
    }
    return undefined;
  }

  /**
   * 查询评论的总数
   * @param newsId
   * @returns
   */
  public queryTotalCommentCount(newsId: string): number {
    return this.queryRawCommentList(newsId).length;
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
   * 添加评论
   * @param item
   */
  public addComment(newItem: BaseComment) {
    if (newItem.parentCommentId) {
      let parent = MockComment.list.find(item => item.commentId === newItem.parentCommentId)
      if (parent) {
        parent.replyComments.unshift(newItem.commentId)
      }
      const rootId = this.queryRootComment(newItem.parentCommentId);
      if (rootId !== parent?.commentId) {
        const root = MockComment.list.find(item => item.commentId === rootId);
        root?.replyComments.unshift(newItem.commentId);
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
   * 评论
   * @param commentId
   */
  public likeComment(commentId: string) {
    const item = MockComment.list.find(v => v.commentId === commentId);
    if (item) {
      item.isLiked = true;
      item.commentLikeNum += 1;
    }
  }

  /**
   * 评论点赞接口
   * @param commentId
   */
  public addCommentLike(commentId: string) {
    const item = MockComment.list.find(v => v.commentId === commentId);
    if (item) {
      item.isLiked = true;
      item.commentLikeNum += 1;
    }
  }

  /**
   * 评论取消点赞
   * @param commentId
   */
  public cancelCommentLike(commentId: string) {
    const item = MockComment.list.find(v => v.commentId === commentId);
    if (item) {
      item.isLiked = false;
      item.commentLikeNum -= 1;
    }
  }

  /**
   * 取消点赞评论
   * @param commentId
   */
  public cancelLikeComment(commentId: string) {
    const item = MockComment.list.find(v => v.commentId === commentId);
    if (item) {
      item.isLiked = false;
      item.commentLikeNum -= 1;
    }
  }

  /**
   * 判断当前评论是否是对应用户的
   * @param commentId
   * @param authorId
   * @returns
   */
  public isAuthorWidthComment(commentId: string, authorId: string): boolean {
    const item = MockComment.list.find(v => v.commentId === commentId);
    if (item) {
      return item?.authorId === authorId
    }
    return false
  }
}

const instance = new CommentService();

export { instance as CommentServiceApi }