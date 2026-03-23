import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { CommonConfirmDialog, EventEnum, GlobalContextUtils, Logger, RouterUtils, WX_APPID } from 'lib_common';
import { MineServiceApi } from 'lib_news_api';
import {
  Channel,
  LoginController,
  LoginChannelType,
  ApiController,
  LoginInfoOptions,
  LoginParams,
  LoginSheetViewUtils,
  LoginType,
  LoginFailError,
} from 'module_login';
import { AccountApi } from '../services/AccountApi';
import { ErrorCode, ERROR_MSG_MAP } from '../constants/ErrorCode';

const TAG = '[LoginParamsUtils]';

export class LoginParam {
  private accountInstance: AccountApi = new AccountApi();
  private controller: LoginController = new LoginController();
  private isSheet: boolean = true;

  private handleClose(otherPage: boolean = false) {
    if (this.isSheet) {
      LoginSheetViewUtils.close();
    } else {
      RouterUtils.pop();
      if (otherPage) {
        RouterUtils.pop();
      }
    }
    this.controller.clearLoginInfo();
    emitter.emit(EventEnum.LOGIN_SUCCESS);
  }

  private huaweiLogin = async (loginParams: LoginParams): Promise<void> => {
    await this.accountInstance.huaweiLogin(loginParams.anonymousPhone ?? '');
    this.handleClose();
  }
  private wxLogin = async (): Promise<void> => {
    await this.accountInstance.wechatLogin();
    this.handleClose(true);
  }
  private verifyCodeLogin = async (loginParams: LoginParams): Promise<void> => {
    await this.accountInstance.verifyCode(loginParams.phoneNumbers ?? '', loginParams.verifyCode ?? '');
    this.handleClose(true);
  }
  private obtainVerifyCode = async () => {
    return MineServiceApi.sendCode('');
  }
  private handleLoginFail = (loginChannelType: LoginChannelType, error: LoginFailError) => {
    switch (loginChannelType) {
      case LoginChannelType.HUAWEI:
        const err = error as BusinessError;
        Logger.error(TAG, 'onClickLoginWithHuaweiIDButton fail, error: ' + JSON.stringify(err));

        if (err.code === ErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
          GlobalContextUtils.showToast({ message: '请先勾选同意协议' });
          return;
        }
        let errorMsg: string = ERROR_MSG_MAP[err.code] ?? '未知错误';
        CommonConfirmDialog.show({
          primaryTitle: '温馨提示',
          content: errorMsg + '是否先模拟登录成功？',
          confirm: () => {
            this.huaweiLogin({ anonymousPhone: '183******12' });
          },
        });
        break;
      case LoginChannelType.WECHAT:
        CommonConfirmDialog.show({
          primaryTitle: '温馨提示',
          content: '拉起微信登录失败，是否先模拟登录成功？',
          confirm: () => {
            this.wxLogin();
          },
        })
        break;
    }
  }
  private params: LoginInfoOptions = {
    uiContext: undefined,
    icon: $r('app.media.startIcon'),
    themeColor: $r('app.color.app_theme'),
    isSheet: true,
    autoSheet: false,
    isPersistence: false,
    pagePadding: {},
    loginTypes: [new Channel(LoginType.WECHAT, '微信', {
      appId: WX_APPID,
      scope: 'snsapi_userinfo,snsapi_friend,snsapi_message,snsapi_contact',
      transaction: 'test123',
      state: 'none',
    }, $r('app.media.wx_count'))],
    privacyContent: [{
      privacyLabel: '《用户协议》',
      privacyUrl: this.accountInstance.getUserAgreeInfo(),
      privacyTag: '用户协议',
    }, {
      privacyLabel: '《xxxx隐私政策》',
      privacyUrl: this.accountInstance.getPrivacyInfo(),
      privacyTag: '隐私政策',
    }, {
      privacyLabel: '《华为账号用户认证协议》',
      privacyUrl: this.accountInstance.getHuaweiUserAgreeInfo(),
      privacyTag: '华为账号用户认证协议',
    }],
    apiController: new ApiController(this.huaweiLogin, this.wxLogin, this.verifyCodeLogin),
    handleLoginFail: this.handleLoginFail,
    obtainVerifyCode: this.obtainVerifyCode,
    loginController: this.controller,
  }

  public getLoginParams(isSheet: boolean = true) {
    this.params.uiContext = GlobalContextUtils.globalUIContext;
    this.isSheet = isSheet;
    this.params.isSheet = isSheet;
    this.params.pagePadding = {
      top: 40,
      bottom: 28,
    };
    return this.params;
  }
}