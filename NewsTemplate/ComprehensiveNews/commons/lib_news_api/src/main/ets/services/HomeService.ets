import { MineServiceApi } from './MineService';
import { MockArticle } from './mockdata/MockArticle';
import { MockPost } from './mockdata/MockPost';
import { MockVideo } from './mockdata/MockVideo';
import { Utils } from '../utils/Utils';
import { BaseNewsServiceApi } from './BaseNewsService';
import { BaseNews } from '../database/NewsType';
import { FlexLayoutModel, RequestListData } from '../params/response/LayoutResponse';
import { NewsResponse } from '../params/response/NewsResponse';
import { NewsEnum } from '../constants/Constants';
import { MockFlexLayout } from './mockdata/MockFlexLayout';
import { AsyncFunc } from '../utils/AsyncUtils';
import { MockUser } from './mockdata/MockUser';

/**
 * 首页
 */

export class HomeService {
  /**
   * 查询首页推荐流
   * @returns
   */
  @AsyncFunc
  public queryHomeRecommendList(postType: string, currentIndex: number = 10, currentPage = 0): RequestListData[] {
    let postList: RequestListData[] = []
    switch (postType) {
      case 'recommend':
        postList = this.getRecommendList(MockFlexLayout.recommendList)
        break
      case 'hotService':
        postList = this.getRecommendList(MockFlexLayout.hotList)
        break
      case 'hotTopChart':
        postList = this.getRecommendList(MockFlexLayout.hotTopChart)
        break
      default:
        postList = Utils.shuffleArray(this.getRecommendList(MockFlexLayout.recommendList).slice(1))
        break
    }
    return postList.slice(currentPage, currentIndex);
  }

  @AsyncFunc
  public queryNextPageData(postType: string, currentIndex: number = 10, currentPage = 0): RequestListData[] {
    let postList: RequestListData[]
    if (postType === 'follow') {
      postList = this.queryHomeFollowList([NewsEnum.Article], currentIndex, currentPage)
      /*
       * 处理extraInfo
       * */
      postList.forEach(item => {
        item.extraInfo.isNeedAuthor = true
        item.extraInfo.isFollow = true
      })
    } else {
      postList = this.queryHomeRecommendList(postType, currentIndex, currentPage)
    }
    return postList;
  }

  getRecommendList(recommendList: FlexLayoutModel[]) {
    let handleRes = recommendList.map(item => {
      const copyItem = JSON.parse(JSON.stringify(item)) as RequestListData;
      let flexData1 = item.articles.map(articleId => {
        let raw = BaseNewsServiceApi.queryRawNews(articleId)
        if (raw) {
          return BaseNewsServiceApi.handleRawNews(raw)
        }
        return raw
      }).filter(v => Boolean(v))
      copyItem.articles = flexData1 as NewsResponse[]
      copyItem.navInfo = item.navInfo
      copyItem.extraInfo = item.extraInfo
      return copyItem
    })
    return handleRes
  }

  /**
   * 查询互动关注流
   * @returns
   */
  @AsyncFunc
  public queryActionFollowList(pageIndex: number): NewsResponse[] {
    const myUserInfo = MineServiceApi.queryAuthorRaw();
    const articles = MockArticle.list
      .filter(v => myUserInfo?.watchers.includes(v.authorId) && v.type === NewsEnum.Post)
      .map((news: BaseNews) => BaseNewsServiceApi.queryNews(news.id))
      .filter(v => Boolean(v)) as NewsResponse[];
    const videos = MockVideo.list
      .filter(v => myUserInfo?.watchers.includes(v.authorId) && v.type === NewsEnum.Post)
      .map((news: BaseNews) => BaseNewsServiceApi.queryNews(news.id))
      .filter(v => Boolean(v)) as NewsResponse[];
    const posts = MockPost.list
      .filter(v => myUserInfo?.watchers.includes(v.authorId) && v.type === NewsEnum.Post)
      .map((news: BaseNews) => BaseNewsServiceApi.queryNews(news.id))
      .filter(v => Boolean(v)) as NewsResponse[]
    return Utils.shuffleArray([...videos, ...posts, ...articles].slice(0, pageIndex));
  }

  /**
   * 查询互动推荐
   * @returns
   */
  @AsyncFunc
  public queryActionRecommendList(): NewsResponse[] {
    const videos = MockVideo.list
      .filter(v => v.type === NewsEnum.Post)
      .map((news: BaseNews) => BaseNewsServiceApi.queryNews(news.id))
      .filter(v => Boolean(v)) as NewsResponse[];
    const posts = MockPost.list
      .filter(v => v.type === NewsEnum.Post)
      .map((news: BaseNews) => BaseNewsServiceApi.queryNews(news.id))
      .filter(v => Boolean(v)) as NewsResponse[]
    return Utils.shuffleArray([...videos, ...posts]);
  }

  /**
   * 查询首页关注流
   * @returns
   */
  public queryHomeFollowList(newsType: NewsEnum[], currentIndex: number = 10, currentPage = 0): RequestListData[] {
    const myUserInfo = MineServiceApi.queryAuthorRaw();
    const articles = MockArticle.list
      .filter(v => myUserInfo?.watchers.includes(v.authorId) && newsType.includes(v.type))
      .map(v => BaseNewsServiceApi.handleRawNews(v))
      .map(v => BaseNewsServiceApi.layoutTrans(v));
    const videos = MockVideo.list
      .filter(v => myUserInfo?.watchers.includes(v.authorId) && newsType.includes(v.type))
      .map(v => BaseNewsServiceApi.handleRawNews(v))
      .map(v => BaseNewsServiceApi.layoutTrans(v));
    const posts = MockPost.list
      .filter(v => myUserInfo?.watchers.includes(v.authorId) && newsType.includes(v.type) ||
        v.authorId === myUserInfo?.authorId)
      .map(v => BaseNewsServiceApi.handleRawNews(v))
      .map(v => BaseNewsServiceApi.layoutTrans(v));
    return Utils.shuffleArray([...videos, ...posts, ...articles].slice(currentPage, currentIndex));
  }

  /**
   * 查询服务卡片-新闻列表
   */
  public queryFormNewsList() {
    const articleId = Utils.shuffleArray([...MockArticle.list])[0].id;
    const postId = Utils.shuffleArray([...MockPost.list])[0].id;
    const videoId = Utils.shuffleArray([...MockVideo.list])[0].id;
    const list: string[] = [articleId, postId, videoId];
    return list
      .map(v => BaseNewsServiceApi.queryNews(v))
      .filter(v => Boolean(v))
  }

  /*
   * 根据IP获取当前所在城市
   * IP 地理位置解析接口，这里mock返回南京
   */
  @AsyncFunc
  public async queryCityByIP(ip: string) {
    if (ip) {
      MockUser.myself.authorIp = '南京'
      return '南京'
    }
    return ''
  }
}


const instance = new HomeService();

export { instance as HomeServiceApi };