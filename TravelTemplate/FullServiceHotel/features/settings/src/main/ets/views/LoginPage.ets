import { LoginUserInfo, QuickLogin } from 'module_login';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { AccountUtil, AgreementType, RouterMap, RouterModule, UserInfo } from 'commonlib';

@Builder
export function LoginPageBuilder() {
  LoginPage()
}

@ComponentV2
export struct LoginPage {
  loginInfo: LoginUserInfo = AppStorageV2.connect(LoginUserInfo, () => new LoginUserInfo())!

  build() {
    NavDestination() {
      QuickLogin({
        icon: $r('app.media.app_foreground'),
        loginBtnBgColor: $r('app.color.theme_color'),
        appName: '综合酒店模板',
        shouldDismiss: () => {
          RouterModule.pop()
        },
        // 登录回调方法
        onLoginWithHuaweiID: () => {
          if (this.loginInfo.id) {
            const userInfo: UserInfo = {
              id: this.loginInfo.id,
              avatar: '',
              name: '',
              nickname: this.loginInfo.name,
              cellphone: this.loginInfo.cellphone,
              memberInfo: {
                memberCardNo: 'mockCard',
                memberClassTName: '大众会员',
                memberClassTLevel: 'Normal',
                pointBalance: '1088',
              },
            }
            AccountUtil.loginAccount(userInfo)
            promptAction.showToast({ message: '登录成功~' })
            RouterModule.pop()
          }
        },
        // 隐私协议方法
        onPrivacyPolicy: () => {
          RouterModule.push({ url: RouterMap.MINE_AGREEMENT_PREVIEW, param: AgreementType.PRIVACY })
        },
        // 服务协议方法
        onServicePolicy: () => {
          RouterModule.push({ url: RouterMap.MINE_AGREEMENT_PREVIEW, param: AgreementType.USER_AGREEMENT })
        },
        // 华为账号用户认证协议
        onHYAccountRouter: () => {
          RouterModule.push({ url: RouterMap.MINE_AGREEMENT_PREVIEW, param: AgreementType.HUAWEI_USER })
        },
      })
    }
  }
}