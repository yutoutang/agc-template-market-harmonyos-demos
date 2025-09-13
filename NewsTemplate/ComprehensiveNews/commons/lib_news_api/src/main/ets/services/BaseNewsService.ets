import { BaseNews, SimpleNews } from '../database/NewsType';
import { MockArticle } from './mockdata/MockArticle';
import { MockVideo } from './mockdata/MockVideo';
import { MockPost } from './mockdata/MockPost';
import { CommentServiceApi } from './CommentService';
import { AuthorServiceApi } from './AuthorService';
import { NewsResponse } from '../params/response/NewsResponse';
import { RequestListData } from '../params/response/LayoutResponse';
import { Utils } from '../utils/Utils';

/**
 * 新闻base类
 */
export class BaseNewsService {
  /**
   * 查询数据库字段
   * @param newsType
   * @param newsId
   * @returns
   */
  public queryRawNews(newsId: string,isQueryAll:boolean = true): BaseNews | undefined {
    let list: BaseNews[] = [...MockArticle.list, ...MockVideo.list, ...MockPost.list];
    if(isQueryAll) {
      return list.find(v => v.id === newsId);
    }
    return list.find(v => v.id === newsId && !v.isLocalPublish);
  }

  /**
   * 数据库字段转换成接口字段
   * @param item
   * @returns
   */
  public handleRawNews(item: BaseNews, ignoreRec: boolean = false): NewsResponse {
    const copyItem = JSON.parse(JSON.stringify(item)) as NewsResponse;
    const authorInfo = AuthorServiceApi.queryAuthorInfo(item.authorId);
    if (authorInfo) {
      copyItem.author = authorInfo;
    }

    copyItem.commentCount = CommentServiceApi.queryTotalCommentCount(item.id);
    copyItem.comments = [];
    copyItem.relativeTime = Utils.getDateDiff(copyItem.createTime)
    if (copyItem.recommends?.length && !ignoreRec) {
      copyItem.recommends = (item?.recommends || [])
        .map((news: SimpleNews) => {
          const raw = this.queryRawNews(news.newsId);
          if (raw) {
            return this.handleRawNews(raw, true);
          }
          return undefined;
        })
        .filter(v => Boolean(v)) as NewsResponse[];
    }

    return copyItem;
  }

  /**
   * 查询新闻
   * @param newsType
   * @param newsId
   * @returns
   */
  public queryNews(newsId: string): NewsResponse | undefined {
    const item = this.queryRawNews(newsId);
    if (item) {
      return this.handleRawNews(item, false);
    }
    return undefined;
  }

  /**
   * 查询作者的所有创作内容
   * @param userId
   * @returns
   */
  public queryAllNews(userId: string): NewsResponse[] {
    return [...MockArticle.list, ...MockVideo.list, ...MockPost.list]
      .filter(v => v.authorId === userId)
      .map(v => this.handleRawNews(v, true))
  }

  /**
   * 查询所有文章、动态、详情
   * @returns
   */
  public queryAllNewsList(): NewsResponse[] {
    return [...MockArticle.list, ...MockVideo.list, ...MockPost.list]
      .map(v => this.handleRawNews(v, true))
  }

  /**
   * 查询搜索结果列表
   * @returns
   */
  public querySearchResultList(search: string): RequestListData[] {
    const list = [...MockArticle.list, ...MockVideo.list, ...MockPost.list]
      .filter(v => v.title.includes(search))
      .map(v => this.handleRawNews(v))
      .map(v => this.layoutTrans(v));
    return list;
  }

  /**
   * 转换成动态布局的结构
   * @param news
   * @returns
   */
  public layoutTrans(news: NewsResponse): RequestListData {
    const resp: RequestListData = {
      navInfo: news.navInfo!,
      articles: [news as NewsResponse],
      extraInfo: news.extraInfo || {},
    };
    return resp;
  }

  /**
   * 查询用户发布的文章
   * @param userId
   * @returns
   */
  public queryAuthorArticles(userId: string): RequestListData[] {
    const list = MockArticle.list
      .filter(v => v.authorId === userId)
      .map(v => this.handleRawNews(v))
      .map(v => this.layoutTrans(v));
    list.sort((a, b) => b.articles[0]?.createTime - a.articles[0]?.createTime);
    return list;
  }

  /**
   * 查询用户发布的视频
   * @param userId
   */
  public queryAuthorVideos(userId: string): RequestListData[] {
    const list = MockVideo.list.filter(v => v.authorId === userId)
      .map(v => this.handleRawNews(v))
      .map(v => this.layoutTrans(v))
    list.sort((a, b) => b.articles[0]?.createTime - a.articles[0]?.createTime);
    return list;
  }

  /**
   * 查询用户发布的动态
   * @param userId
   */
  public queryAuthorPosts(userId: string): RequestListData[] {
    const list = MockPost.list
      .filter(v => v.authorId === userId)
      .map(v => this.handleRawNews(v))
      .map(v => this.layoutTrans(v))
    list.sort((a, b) => b.articles[0]?.createTime - a.articles[0]?.createTime);
    return list;
  }

  /**
   * 收藏
   * @param newsId
   */
  public addMark(newsId: string) {
    const news = this.queryRawNews(newsId);
    if (news) {
      news.isMarked = true
      news.markCount += 1
    }
  }

  /**
   * 取消收藏
   * @param newsId
   */
  public cancelMark(newsId: string) {
    const news = this.queryRawNews(newsId);
    if (news) {
      news.isMarked = false
      news.markCount -= 1
    }
  }
}

const instance = new BaseNewsService();

export { instance as BaseNewsServiceApi };