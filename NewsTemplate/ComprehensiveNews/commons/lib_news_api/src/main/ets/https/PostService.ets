import request from '../common/BaseRequest';
import { PostRequest } from '../params/request/CommonRequest';
import { NewsResponse } from '../params/response/NewsResponse';
import { BaseNewsService } from './BaseNewsService';

/**
 * 新闻-动态类
 */
export class PostService extends BaseNewsService {
  /**
   * 查询推荐
   * @param currentIndex
   * @param currentPage
   * @returns
   */
  public queryPostRecommendList(currentIndex: number = 10, currentPage = 0): Promise<NewsResponse[]> {
    return request.get('/post/recommend/list', { params: { currentIndex, currentPage } });
  }

  /**
   * 查询关注
   * @param currentIndex
   * @param currentPage
   * @returns
   */
  public queryPostFollowList(currentIndex: number = 10, currentPage = 0): Promise<NewsResponse[]> {
    return request.get('/post/follow/list', { params: { currentIndex, currentPage } });
  }

  /**
   * 发布动态
   * @param post
   */
  public publishPost(post: PostRequest): Promise<void> {
    return request.post('/publish/post', post);
  }
}

const instance = new PostService();

export { instance as PostServiceApi }