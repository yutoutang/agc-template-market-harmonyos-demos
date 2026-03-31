import { emitter } from '@kit.BasicServicesKit';
import { EventEnum, GlobalContextUtils } from 'lib_common';
import {
  FinishStatus,
  LoginApiController,
  MemberList,
  MemberParams,
  ProductsInfoOptions,
  UserStatus,
} from 'module_membership';
import { MemberData } from '../services/mockdata/MemberData';
import { AccountApi } from '../services/AccountApi';
import { loginUtils } from './LoginUtils';

/**
 * 会员参数
 */
export class MembershipParam {
  // 账号utils实例
  private accountInstance: AccountApi = new AccountApi();
  // 订阅成功失败回调
  private subscribeEvent = async (param: MemberParams): Promise<void> => {
    GlobalContextUtils.showToast({
      message: param.status === FinishStatus.FINISHED ? '会员订阅成功' :
        `会员订阅失败，订阅错误码为${param.errCode}，错误原因为${param.errMsg}`,
    });

    if (param.status === FinishStatus.FINISHED) {
      await this.accountInstance.setMemExpireTime(param.productId);
    }
    this.queryExpireTime().then((resp) => {
      this.productsInfo.lastPurchaseProductExpireTime = resp;
    });
  };
  // 已开通会员列表变化回调
  private ownedMemberEvent = async (list: MemberList): Promise<void> => {
    const isMembership = list.renewList.length > 0 || list.nonRenewList.length > 0;
    this.accountInstance.setMembershipFlag(isMembership);
  };
  // 查询非续期会员到期时间
  private queryExpireTime = (): Promise<string> => {
    // 请求开发者服务器获取非周期订阅商品到期时间（涉及商品id、购买次数）
    return this.accountInstance.queryMemExpireTime();
  };
  // 登录成功的回调
  public loginSuccessCallback: () => void = () => {
  };

  // 查询登录状态
  private queryLoginUserStatus = (): Promise<UserStatus> => {
    return new Promise<UserStatus>(async (resolve) => {
      const userStatus = new UserStatus();
      userStatus.isLogin = this.accountInstance.checkLogin();
      resolve(userStatus);
    });
  }

  // 拉起登录
  private handleLogin(_uiContext: UIContext, callback: (isLoginSuccess: boolean) => void) {
    this.loginSuccessCallback = () => {
      callback(true);
    };
    loginUtils.open();
    emitter.on(EventEnum.LOGIN_SUCCESS, this.loginSuccessCallback);
  }

  // 基本参数
  private productsInfo: ProductsInfoOptions = {
    isSheet: false,
    themeColor: $r('app.color.membership'),
    linearColors: [[$r('app.color.member_linear_left'), 0.0], [$r('app.color.member_linear_right'), 1.0]],
    btnFontColor: Color.Black,
    // todo: 替换为您配置的商品ID及对应的权益
    productsInfo: MemberData.PRODUCTS_INFO,
    // todo: 替换协议内容
    privacyContent: MemberData.PRIVACY_CONTENT,
    lastPurchaseProductExpireTime: '',
    subscribeCallBack: this.subscribeEvent,
    queryExpireTime: this.queryExpireTime,
    ownedMemberCallBack: this.ownedMemberEvent,
    isLinkLoginStatus: true,
    loginApiController: new LoginApiController(this.queryLoginUserStatus, this.handleLogin),
  };

  constructor() {
    this.queryExpireTime().then((resp) => {
      this.productsInfo.lastPurchaseProductExpireTime = resp;
    });
  }

  /**
   * 获取会员页面参数
   * @param isSheet
   * @returns
   */
  public getParams(isSheet: boolean) {
    this.productsInfo.isSheet = isSheet;
    return this.productsInfo;
  }
}