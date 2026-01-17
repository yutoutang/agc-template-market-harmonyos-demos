import { RouterMap, RouterUtils } from 'lib_common';
import { LoginSheetViewUtils } from 'module_login';
import { LoginParam } from './LoginParam';

/**
 * 统一登录
 */
export class LoginUtils {
  private params: LoginParam = new LoginParam();

  /**
   * 打开半模态弹窗
   */
  public open() {
    LoginSheetViewUtils.open(this.params.getLoginParams(true));
  }

  /**
   * 跳转登录页面
   */
  public jumpLoginPage() {
    RouterUtils.pushPathByName(RouterMap.HUAWEI_LOGIN_PAGE, this.params.getLoginParams(false))
  }
}

export const loginUtils = new LoginUtils();