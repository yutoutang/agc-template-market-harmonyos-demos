import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { Logger } from 'module_ui_base';

const TAG: string = '[LoginUtil]'

export class LoginUtil {
  // 获取匿名手机号
  public static async getQuickLoginAnonymousPhone() {
    const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    // 获取匿名手机号需传quickLoginAnonymousPhone这个scope，传参之前需要先申请“华为账号一键登录”权限，否则会返回1001502014错误码
    authRequest.scopes = ['quickLoginAnonymousPhone'];
    // 用于防跨站点请求伪造
    authRequest.state = util.generateRandomUUID();
    // 一键登录场景该参数必须设置为false
    authRequest.forceAuthorization = false;
    const controller = new authentication.AuthenticationController();
    try {
      const response: authentication.AuthorizationWithHuaweiIDResponse = await controller.executeRequest(authRequest)
      const anonymousPhone = response.data?.extraInfo?.quickLoginAnonymousPhone as string
      return anonymousPhone;
    } catch (error) {
      Logger.error(TAG, 'get quick login anonymous phone failed. error:' + JSON.stringify(error))
    }
    return ''
  }
}

