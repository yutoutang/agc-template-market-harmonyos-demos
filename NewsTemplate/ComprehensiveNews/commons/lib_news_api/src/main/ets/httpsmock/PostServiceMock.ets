import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { NewsEnum } from '../constants/Constants';
import { BaseNews } from '../database/NewsType';
import { PostRequest, QueryListRequest } from '../params/request/CommonRequest';
import { NewsResponse } from '../params/response/NewsResponse';
import { MockPost } from './mockdata/MockPost';
import { Utils } from '../utils/Utils';
import { AuthorServiceMock } from './AuthorServiceMock';
import { BaseNewsServiceMock } from './BaseNewsServiceMock';

/**
 * 新闻动态Mock
 */
export class PostServiceMock {
  private authorMock: AuthorServiceMock = new AuthorServiceMock();
  private baseNewsMock: BaseNewsServiceMock = new BaseNewsServiceMock();

  public start(adapter: AxiosMockAdapter) {
    // 查询推荐
    adapter.onGet('/post/recommend/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as QueryListRequest;
      const posts = MockPost.list
        .map((post: BaseNews) => this.baseNewsMock.queryNews(post.id))
        .filter(v => Boolean(v)) as NewsResponse[];
      const list = [...posts].slice(params.currentPage, params.currentIndex);
      return [HttpStatusCode.Ok, list];
    });

    // 查询关注
    adapter.onGet('/post/follow/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as QueryListRequest;
      const myUserInfo = this.authorMock.queryAuthorRaw();
      const posts = MockPost.list
        .filter(v => myUserInfo?.watchers.includes(v.authorId))
        .map((post: BaseNews) => this.baseNewsMock.queryNews(post.id))
        .filter(v => Boolean(v)) as NewsResponse[];
      const list = [...posts].slice(params.currentPage, params.currentIndex);
      return [HttpStatusCode.Ok, list];
    });

    // 发布动态
    adapter.onPost('/publish/post').reply((config: AxiosRequestConfig) => {
      const post = JSON.parse(config.data) as PostRequest;
      const postDefault = MockPost.default;
      let postInfo: BaseNews = {
        id: `post_${Utils.randomArticleId()}`,
        type: NewsEnum.Post,
        title: post.postBody,
        authorId: this.authorMock.queryAuthorInfo()?.authorId as string,
        createTime: new Date().getTime(),
        commentCount: 0,
        markCount: 0,
        likeCount: 0,
        shareCount: 0,
        isLiked: false,
        isMarked: false,
        recommends: [{
          newsId: 'article_9',
          newsType: 0,
        }, {
          newsId: 'article_11',
          newsType: 0,
        }],
        postImgList: post.postImgList,
        navInfo: postDefault.navInfo,
      }
      MockPost.list.unshift(postInfo)
      return [HttpStatusCode.Ok];
    });
  }
}