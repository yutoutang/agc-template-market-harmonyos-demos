import request from '../common/BaseRequest';
import { SendCodeRequest, SignInRequest, VerifyCodeRequest } from '../params/request/CommonRequest';
import { AuthorResponse } from '../params/response/AuthorResponse';

/**
 * 用户管理类
 */
export class AuthorService {
  /**
   * 查询作者信息
   * @param userId
   * @param loginChannel
   * @returns
   */
  public queryAuthorInfo(userId?: string, loginChannel?: string): Promise<AuthorResponse | undefined> {
    if (loginChannel) {
      return this.signIn(loginChannel);
    }
    return request.get('/author/info', { params: { userId } });
  }

  /**
   * 登录
   * @param loginChannel
   * @param nickPhone
   * @returns
   */
  public signIn(loginChannel?: string, nickPhone?: string): Promise<AuthorResponse | undefined> {
    const data: SignInRequest = {
      loginChannel,
      nickPhone,
    };
    return request.post('/sign/in', data);
  }

  /**
   * 获取短信验证码
   * @param phone
   * @returns
   */
  public sendCode(phone: string): Promise<void> {
    const data: SendCodeRequest = {
      phone,
    };
    return request.post('/send/code', data);
  }

  /**
   * 验证短信验证码
   * @param phone
   * @param code
   * @returns
   */
  public verifyCode(phone: string, code: string): Promise<void> {
    const data: VerifyCodeRequest = {
      phone,
      code,
    };
    return request.post('/verify/code', data);
  }

  /**
   * 查询关注的人
   * @param userId
   * @returns
   */
  public queryWatchUsers(userId: string): Promise<AuthorResponse[]> {
    return request.get('/watch/user/list', { params: { userId } });
  }

  /**
   * 查询粉丝
   * @param userId
   */
  public queryFollowers(userId: string): Promise<AuthorResponse[]> {
    return request.get('/follow/user/list', { params: { userId } });
  }
}

const instance = new AuthorService();

export { instance as AuthorServiceApi }