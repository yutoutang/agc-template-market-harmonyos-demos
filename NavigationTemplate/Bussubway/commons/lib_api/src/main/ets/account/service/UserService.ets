import { BaseUser } from '../database/UserType';
import { UserResponse } from '../params/response/UserResponse';
import { MockUser } from './mockdata/MockUser';

/**
 * 用户管理类
 */
export class UserService {
  /**
   * 查询用户信息数据库字段
   * @param userId
   * @returns queryUser
   */
  public queryUserRaw(userId?: string): BaseUser | undefined {
    let queryUser: BaseUser = MockUser.myself
    if (userId) {
      queryUser = [...MockUser.userList, MockUser.myself].find(v => v.userId === userId)!;
    }
    return queryUser;
  }

  /**
   * 查询用户信息
   * @param userId
   * @returns
   */
  public queryUserInfo(userId?: string, loginChannel?: string): UserResponse | undefined {
    if (loginChannel) {
      return this.signIn(loginChannel);
    }
    const raw = this.queryUserRaw(userId);
    if (raw) {
      return this.handleRawInfo(raw);
    }
    return undefined;
  }

  /**
   * 登录
   * @param loginChannel 渠道
   */
  public signIn(loginChannel?: string, nickPhone?: string) {
    const raw = this.queryUserRaw();
    if (raw) {
      if (loginChannel === 'wechat') {
        raw.userNickName = '微信用户';
      } else {
        raw.userNickName = '华为用户';
      }
      if (nickPhone) {
        raw.userPhone = nickPhone;
      }
      return this.handleRawInfo(raw);
    }
    return undefined;
  }

  /**
   * 数据库字段转换成云侧模型
   * @param user
   * @returns userResponse
   */
  private handleRawInfo(user: BaseUser): UserResponse {
    const userResponse = JSON.parse(JSON.stringify(user)) as UserResponse;
    return userResponse;
  }
}

const instance = new UserService();

export { instance as userServiceApi }