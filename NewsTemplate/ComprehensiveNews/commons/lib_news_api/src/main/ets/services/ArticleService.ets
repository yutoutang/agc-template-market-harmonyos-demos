import { NewsEnum } from '../constants/Constants';
import { BaseNews } from '../database/NewsType';
import { PostImgList } from '../params/base/BaseModel';
import { FlexLayoutModel } from '../params/response/LayoutResponse';
import { Utils } from '../utils/Utils';
import { BaseNewsService } from './BaseNewsService';
import { MineServiceApi } from './MineService';
import { MockArticle } from './mockdata/MockArticle';
import { MockFlexLayout } from './mockdata/MockFlexLayout';

/**
 * 新闻-文章类
 */
export class ArticleService extends BaseNewsService {
  /**
   * 添加文章
   */
  public addArticle(title: string, content: string, setting: string, postImgList: PostImgList[]) {
    let articleInfo: BaseNews = {
      id: `article_${Utils.randomArticleId()}`,
      type: NewsEnum.Article,
      title: title,
      authorId: MineServiceApi.queryAuthorInfo()?.authorId as string,
      markCount: 0,
      postImgList: postImgList,
      recommends: [{
        newsId: 'article_6',
        newsType: 1,
      }, {
        newsId: 'article_8',
        newsType: 1,
      }],
      richContent: content,
      createTime: new Date().getTime(),
      commentCount: 0,
      likeCount: 0,
      shareCount: 0,
      isLiked: false,
      isMarked: false,
      isLocalPublish: true,
      articleFrom: MineServiceApi.queryAuthorInfo()?.authorNickName,
      navInfo: {
        setting: setting,
      },
    }
    MockArticle.list.unshift(articleInfo)
    return articleInfo
  }

  public addFlexLayout(articleId: string, setting: string) {
    let flexInfo: FlexLayoutModel = {
      navInfo: {
        setting: setting,
      },
      articles: [
        articleId,
      ],
      extraInfo: {
        'flexId': `flexId_${Utils.randomArticleId()}`,
        'isNeedAuthor': false,
      },
    }
    MockFlexLayout.recommendList.splice(1, 0, flexInfo)
  }
}

const instance = new ArticleService();

export { instance as ArticleServiceApi };