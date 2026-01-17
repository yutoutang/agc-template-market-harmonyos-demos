import { authentication } from '@kit.AccountKit'
import { util } from '@kit.ArkTS'
import { BusinessError } from '@ohos.base'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { UserApi } from '../apis/UserApi';
import { UserInfoResult } from '../model/ApiResponse';
import { UserInfo } from '../constants/CommonModel';

export class AuthenticationUtil {
  public static readonly AUTHENTICATION_INFO_KEY: string = 'authenticationInfo'
  public static loginWithHuaweiIDCredential: authentication.LoginWithHuaweiIDCredential | undefined = undefined

  // 关联授权
  public static async authenticationLogin(): Promise<string> {
    return new Promise((resolve, reject) => {
      // 创建登录请求，并设置参数
      const loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
      // false表示当用户未登录华为账号时，不会拉起华为账号登录界面；直接返回1001502001错误码。
      loginRequest.forceLogin = false;
      // 用于防跨站点请求伪造。
      loginRequest.state = util.generateRandomUUID();

      // 执行登录请求
      try {
        const controller = new authentication.AuthenticationController();
        controller.executeRequest(loginRequest).then((response: authentication.LoginWithHuaweiIDResponse) => {
          const loginWithHuaweiIDResponse = response as authentication.LoginWithHuaweiIDResponse;
          const state = loginWithHuaweiIDResponse.state;
          if (state && loginRequest.state !== state) {
            hilog.error(0x0000, 'testTag', `Failed to login. The state is different, response state: ${state}`);
            return;
          }
          hilog.info(0x0000, 'testTag', 'Succeeded in logging in.');
          const loginWithHuaweiIDCredential = loginWithHuaweiIDResponse.data!;
          const code = loginWithHuaweiIDCredential.authorizationCode;
          const idToken = loginWithHuaweiIDCredential.idToken;
          const openID = loginWithHuaweiIDCredential.openID;
          const unionID = loginWithHuaweiIDCredential.unionID;
          // 开发者处理code, idToken, openID, unionID
          if (code) {
            resolve(code)
          } else {
            reject('error authorization')
          }

        }).catch((error: BusinessError) => {
          hilog.error(0x0000, 'testTag', 'Failed to login, errorCode=%{public}d, errorMsg=%{public}s', error.code,
            error.message);
        })
      } catch (error) {
        hilog.error(0x0000, 'testTag', 'Failed to login, errorCode=%{public}d, errorMsg=%{public}s', error.code,
          error.message);
      }
    });
  }
  // 取消授权
  public static async cancelAuthentication(uiContext: UIContext): Promise<string> {
    return new Promise((resolve, reject) => {
      // 创建取消授权请求，并设置参数
      const cancelRequest = new authentication.HuaweiIDProvider().createCancelAuthorizationRequest();
      cancelRequest.state = util.generateRandomUUID();
      const controller = new authentication.AuthenticationController(uiContext.getHostContext());
      controller.executeRequest(cancelRequest, (error: BusinessError<Object>, data) => {
        if (error) {
          reject('Failed error: ' + JSON.stringify(error))
          return;
        }
        const cancelAuthorizationResponse = data as authentication.CancelAuthorizationResponse;
        const state = cancelAuthorizationResponse.state;
        if (state && cancelRequest.state !== state) {
          hilog.error(0x0000, 'testTag', `Failed to cancel. The state is different, response state: ${state}`);
          reject('Failed state: ' + state)
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in canceling.');
        resolve('success')
      });
    })
  }

  // 静默登录
  public static async silentLogin(callback: (isSuccess: boolean, userInfo: UserInfo) => void, uiContext: UIContext) {
    AuthenticationUtil.authenticationLogin().then((code: string) => {
      if (code) {
        UserApi.userLogin(code).then((userInfo) => {
          let result = userInfo.result as UserInfoResult
          if (result.ret.code === 0) {
            let userRes = result.result[0] as UserInfo
            callback(true, new UserInfo(userRes))
          } else {
            try {
              uiContext.getPromptAction().showToast({ message: '账号关联失败，请重试~' })
            } catch (error) {
              hilog.error(0x0000, 'testTag', 'Failed to show toast, errorCode=%{public}d, errorMsg=%{public}s', error.code,
                error.message);
            }
            AuthenticationUtil.cancelAuthentication(uiContext)
            callback(false, new UserInfo())
          }
        }).catch(() => {
          try {
            uiContext.getPromptAction().showToast({ message: '账号关联失败' })
          } catch (error) {
            hilog.error(0x0000, 'testTag', 'Failed to show toast, errorCode=%{public}d, errorMsg=%{public}s', error.code,
              error.message);
          }
          AuthenticationUtil.cancelAuthentication(uiContext)
          callback(false, new UserInfo())
        })
      }
    }).catch(() => {
      try {
        uiContext.getPromptAction().showToast({ message: '取消关联手机号' })
      } catch (error) {
        hilog.error(0x0000, 'testTag', 'Failed to show toast, errorCode=%{public}d, errorMsg=%{public}s', error.code,
          error.message);
      }
      AuthenticationUtil.cancelAuthentication(uiContext)
      callback(false, new UserInfo())
    })
  }
}