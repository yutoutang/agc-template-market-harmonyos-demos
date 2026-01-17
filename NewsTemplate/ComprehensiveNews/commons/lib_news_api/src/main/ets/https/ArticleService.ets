import request from '../common/BaseRequest';
import { BaseNews } from '../database/NewsType';
import { PostImgList } from '../params/base/BaseModel';
import { AddArticleRequest, AddFlexLayoutRequest } from '../params/request/CommonRequest';
import { BaseNewsService } from './BaseNewsService';

/**
 * 新闻-文章类
 */
export class ArticleService extends BaseNewsService {
  /**
   * 添加文章
   * @param title
   * @param content
   * @param setting
   * @param postImgList
   * @returns
   */
  public addArticle(title: string, content: string, setting: string, postImgList: PostImgList[]): Promise<BaseNews> {
    const data: AddArticleRequest = {
      title,
      content,
      setting,
      postImgList,
    };
    return request.post('/add/article', data);
  }

  /**
   * 动态布局新增数据
   * @param articleId
   * @param setting
   * @returns
   */
  public addFlexLayout(articleId: string, setting: string): Promise<void> {
    const data: AddFlexLayoutRequest = {
      articleId,
      setting,
    };
    return request.post('/add/flex/layout', data);
  }
}

const instance = new ArticleService();

export { instance as ArticleServiceApi };