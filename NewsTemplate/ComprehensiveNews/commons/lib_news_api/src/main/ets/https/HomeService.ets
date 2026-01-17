import request from '../common/BaseRequest';
import { NewsEnum } from '../constants/Constants';
import { RequestListData } from '../params/response/LayoutResponse';
import { NewsResponse } from '../params/response/NewsResponse';
import { AvResponse, VideoProgramResponse } from '../params/response/AvResponse';
import { DigitalNewsResponse, DigitalNewsSource } from '../params/response/DigitalNewsResponse';

/**
 * 首页
 */
export class HomeService {
  /**
   * 查询首页推荐流
   * @param postType
   * @param currentIndex
   * @param currentPage
   * @returns
   */
  public queryHomeRecommendList(postType: string, currentIndex: number = 10,
    currentPage = 0): Promise<RequestListData[]> {
    return request.get('/home/recommend/list', { params: { postType, currentIndex, currentPage } });
  }

  /**
   * 查询广播流
   * @param currentIndex
   * @param currentPage
   * @returns
   */
  public queryBroadcastList( currentIndex: number = 10,
    currentPage = 0): Promise<AvResponse[]> {
    return request.get('/home/broadcast/list', { params: { currentIndex, currentPage } });
  }

  /**
   * 查询电视视频流
   * @param currentIndex
   * @param currentPage
   * @returns
   */
  public queryTelevisionList( currentIndex: number = 10,
    currentPage = 0): Promise<AvResponse[]> {
    return request.get('/home/television/list', { params: { currentIndex, currentPage } });
  }

  /**
   * 查询首页电视节目单
   * @param id
   * @returns
   */
  public queryHomeTelevisionProgram(id:string): Promise<VideoProgramResponse[]> {
    return request.get('/home/television/program/list', { params: { id } });
  }

  /**
   * 查询电视节目详情
   * @param id
   * @returns
   */
  public queryHomeTelevisionDetails(id:string): Promise<AvResponse> {
    return request.get('/home/television/program/details', { params: { id } });
  }

  /**
   * 查询电视猜你喜欢
   * @returns
   */
  public queryTelevisionLikes(): Promise<AvResponse[]> {
    return request.get('/home/television/like');
  }

  /**
   * 查询首页广播流-猜你喜欢
   * @returns
   */
  public queryBroadcastLike(): Promise<AvResponse[]> {
    return request.get('/home/broadcast/like');
  }

  /**
   * 查询首页广播流-今日推荐
   * @returns
   */
  public queryBroadcastRecommend(): Promise<AvResponse[]> {
    return request.get('/home/broadcast/recommend');
  }

  /**
   * 查询首页广播流-热门点播
   * @returns
   */
  public queryBroadcastHot(): Promise<AvResponse[]> {
    return request.get('/home/broadcast/hot');
  }

  /**
   * 查询广播详情
   * @param id
   * @returns
   */
  public queryHomeBroadcastById(id: string): Promise<AvResponse> {
    return request.get('/home/broadcast/details', { params: { id } });
  }

  /**
   * 查询下一页数据
   * @param postType
   * @param currentIndex
   * @param currentPage
   * @returns
   */
  public queryNextPageData(postType: string, currentIndex: number = 10, currentPage = 0): Promise<RequestListData[]> {
    if (postType === 'follow') {
      return this.queryHomeFollowList([NewsEnum.Article], currentIndex, currentPage, true);
    }
    return this.queryHomeRecommendList(postType, currentIndex, currentPage);
  }

  /**
   * 查询互动关注流
   * @param pageIndex
   * @returns
   */
  public queryActionFollowList(pageIndex: number): Promise<NewsResponse[]> {
    return request.get('/action/follow/list', { params: { pageIndex } });
  }

  /**
   * 查询互动推荐
   * @returns
   */
  public queryActionRecommendList(): Promise<NewsResponse[]> {
    return request.get('/action/recommend/list');
  }

  /**
   * 查询首页关注流
   * @param newsType
   * @param currentIndex
   * @param currentPage
   * @returns
   */
  public queryHomeFollowList(newsType: NewsEnum[], currentIndex: number = 10,
    currentPage = 0, handleExtraInfo: boolean = false): Promise<RequestListData[]> {
    return request.get('/home/follow/list', {
      params: {
        newsType,
        currentIndex,
        currentPage,
        handleExtraInfo,
      },
    });
  }

  /**
   * 查询服务卡片-新闻列表
   */
  public queryFormNewsList(): Promise<NewsResponse[]> {
    return request.get('/form/news/list');
  }

  /**
   * 根据IP获取当前所在城市，IP 地理位置解析接口，这里mock返回南京
   * @param ip
   * @returns
   */
  public queryCityByIP(ip: string): Promise<string> {
    return request.get('/city/ip', { params: { ip } });
  }

  /**
   * 查询数字报纸
   * @param sourceId
   * @param publishDate
   * @returns
   */
  public queryDigitalNewsList(sourceId: string, publishDate: number): Promise<DigitalNewsResponse[]> {
    return request.get('/digital/news/list', { params: { sourceId, publishDate } });
  }

  /**
   * 查询报纸来源列表
   */
  public queryNewsSourceList(): Promise<DigitalNewsSource[]> {
    return request.get('/source/list');
  }
}

const instance = new HomeService();

export { instance as HomeServiceApi };