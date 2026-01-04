import { PersistenceV2 } from '@kit.ArkUI';
import { UserInfoModel } from 'lib_common';
import { UserResponse, userServiceApi } from 'lib_api';
import { ProtocolData } from './mockdata/ProtocolData';

/**
 * 账号类
 */
export class AccountApi {
  private userInfoModel: UserInfoModel = new UserInfoModel();

  constructor() {
    this.userInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  }

  /**
   * 判断是否登录
   * @returns
   */
  public checkLogin(): boolean {
    return this.userInfoModel.isLogin;
  }

  /**
   * 重新赋值userInfoModel
   */
  public queryUserInfo() {
    if (this.checkLogin()) {
      const user = userServiceApi.queryUserInfo('', this.userInfoModel.loginChannel)
      if (user) {
        this.handleUserInfo(user);
      }
    }
  }

  /**
   * 华为账号登录
   */
  public huaweiLogin(nickPhone?: string) {
    const user = userServiceApi.signIn('hw', nickPhone);
    if (user) {
      this.userInfoModel.loginChannel = 'hw';
      this.handleUserInfo(user);
    }
  }

  /**
   * 账密登录
   */
  public accountPasswordLogin() {
    const user = userServiceApi.signIn()
    if (user) {
      this.userInfoModel.loginChannel = 'pw';
      this.handleUserInfo(user);
    }
  }

  /**
   * 微信登录
   */
  public wechatLogin() {
    const channel = 'wechat';
    const user = userServiceApi.signIn(channel)
    if (user) {
      this.userInfoModel.loginChannel = channel;
      this.handleUserInfo(user);
    }
  }

  /**
   * 查询已登录的用户信息
   * @returns
   */
  public getUserInfo() {
    return this.userInfoModel;
  }

  /**
   * 退出登录
   */
  public async signOut(): Promise<void> {
    return new Promise((resolve) => {
      setTimeout(() => {
        this.userInfoModel.isLogin = false;
        this.userInfoModel.loginChannel = '';
        this.userInfoModel.userId = '';
        this.userInfoModel.userNickName = '';
        this.userInfoModel.userIcon = '';
        this.userInfoModel.userPhone = '';
        this.userInfoModel.userDesc = '';
        this.userInfoModel.userIp = '';
        resolve();
      }, 500);
    });
  }

  /**
   * 查询用户协议内容
   * @returns
   */
  public getUserAgreeInfo() {
    return ProtocolData.userProtocol;
  }

  /**
   * 查询隐私协议内容
   * @returns
   */
  public getPrivacyInfo() {
    return ProtocolData.privacyProtocol;
  }

  /**
   * 查询华为用户协议内容
   * @returns
   */
  public getHuaweiUserAgreeInfo() {
    return ProtocolData.huaweiUserProtocol;
  }

  /**
   * 查询第三方信息共享清单
   * @returns
   */
  public getThirdPartyInfo() {
    return ProtocolData.thirdPartyInfo;
  }

  /**
   * 查询个人信息收集清单
   * @returns
   */
  public getPersonalInfoCollection() {
    return ProtocolData.personalInfoCollection;
  }

  /**
   * userinfo赋值
   * @param user
   */
  private handleUserInfo(user: UserResponse) {
    this.userInfoModel.isLogin = true;
    this.userInfoModel.userId = user.userId;
    this.userInfoModel.userNickName = user.userNickName;
    this.userInfoModel.userIcon = user.userIcon;
    this.userInfoModel.userDesc = user.userDesc;
    this.userInfoModel.userIp = user.userIp;
    this.userInfoModel.userPhone = user.userPhone || '';
  }
}
