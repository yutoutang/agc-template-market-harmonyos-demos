import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { BaseAuthor } from '../database/AuthorType';
import { SignInRequest, UserRequest } from '../params/request/CommonRequest';
import { AuthorResponse } from '../params/response/AuthorResponse';
import { MockUser } from './mockdata/MockUser';

/**
 * 用户管理Mock
 */
export class AuthorServiceMock {
  public start(adapter: AxiosMockAdapter) {
    // 查询作者信息
    adapter.onGet('/author/info').reply((config: AxiosRequestConfig) => {
      const params = config.params as UserRequest;
      const result = this.queryAuthorInfo(params.userId);
      return [HttpStatusCode.Ok, result];
    });

    // 登录
    adapter.onPost('/sign/in').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as SignInRequest;
      let resp: AuthorResponse | undefined = undefined;
      const raw = this.queryAuthorRaw();
      if (raw) {
        if (data.loginChannel === 'wechat') {
          raw.authorNickName = '微信用户';
        } else {
          raw.authorNickName = '华为用户';
        }
        if (data.nickPhone) {
          raw.authorPhone = data.nickPhone;
        }
        resp = this.handleRawInfo(raw);
      }
      return [HttpStatusCode.Ok, resp];
    });

    // 获取短信验证码
    adapter.onPost('/send/code').reply(() => {
      return [HttpStatusCode.Ok];
    });

    // 验证短信验证码
    adapter.onPost('/verify/code').reply(() => {
      return [HttpStatusCode.Ok];
    });

    // 查询关注的人
    adapter.onGet('/watch/user/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as UserRequest;
      const authorInfo = this.queryAuthorRaw(params.userId);
      const list = (authorInfo?.watchers || [])
        .map((authorId: string) => {
          return this.queryAuthorInfo(authorId);
        })
        .filter(v => Boolean(v)) as AuthorResponse[];
      return [HttpStatusCode.Ok, list];
    });

    // 查询粉丝
    adapter.onGet('/follow/user/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as UserRequest;
      const list = this.queryFollowers(params.userId);
      return [HttpStatusCode.Ok, list];
    });
  }

  /**
   * 查询粉丝
   * @param userId
   * @returns
   */
  public queryFollowers(userId: string): AuthorResponse[] {
    const authorInfo = this.queryAuthorRaw(userId);
    const list = (authorInfo?.followers || [])
      .map((authorId: string) => {
        return this.queryAuthorInfo(authorId);
      })
      .filter(v => Boolean(v)) as AuthorResponse[];

    return list;
  }

  /**
   * 查询作者信息
   * @param userId
   * @returns
   */
  public queryAuthorInfo(userId?: string): AuthorResponse | undefined {
    const raw = this.queryAuthorRaw(userId);
    if (raw) {
      return this.handleRawInfo(raw);
    }
    return undefined;
  }

  /**
   * 查询用户信息数据库字段
   * @param userId
   * @returns
   */
  public queryAuthorRaw(userId?: string): BaseAuthor | undefined {
    if (userId) {
      return [...MockUser.list, MockUser.myself].find(v => v.authorId === userId)!;
    }
    // 获取本人信息
    return MockUser.myself;
  }

  /**
   * 数据库字段转换成云侧模型
   * @param author
   * @returns
   */
  private handleRawInfo(author: BaseAuthor): AuthorResponse {
    const copyItem = JSON.parse(JSON.stringify(author)) as AuthorResponse;
    copyItem.watchersCount = author.watchers.length;
    copyItem.followersCount = author.followers.length;
    return copyItem;
  }
}