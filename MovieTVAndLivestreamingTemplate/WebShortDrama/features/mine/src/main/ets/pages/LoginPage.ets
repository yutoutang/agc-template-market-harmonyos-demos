import { Channel, LoginService, LoginType } from '@agctemplate/module_login';
import { getMedia, NAV_PAGE_NAME } from '@agctemplate/resources';
import { appRouter, NavParams, WindowManager } from '@agctemplate/utils';
import { AssociateUtil, MinePageVM } from '@agctemplate/widgets';

@ComponentV2
export struct LoginPage {

  @Param isChange: boolean = false
  @Local vm: MinePageVM = MinePageVM.instance;

  loginSuccess() {
    AssociateUtil._requestAssociateAccount('', true);
    appRouter.back()
    if(this.isChange) {
      WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6ffffff' })
    }
  }


  build() {
    NavDestination() {
      Column() {
        LoginService({
          icon: getMedia('app.media.icon'),
          privacyPolicyEvent: () => {
            appRouter.push({ builderName: NAV_PAGE_NAME.PrivacyStatementPage.name })
          },
          loginBtnBgColor: $r('sys.color.alert'),
          termOfServiceEvent: () => {},
          loginTypes: [new Channel(LoginType.WECHAT, '微信登录', {
            appId: 'wxd5a474c635b8fd17',
            scope: 'snsapi_userinfo,snsapi_friend,snsapi_message,snsapi_contact',
            transaction: 'test123',
            state: 'none',
          }, $r('app.media.wechat'))],
          loginFinishedCb: (flag: boolean, unionID?: string) => {
            // 模板忽略登录失败场景
            this.loginSuccess()
          },
        });
      }
      .backgroundColor($r('sys.color.background_secondary')).height('100%')
    }
    .padding({ top: 40 })
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .onBackPressed(() => {
      appRouter.back()
      if(this.isChange) {
        WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6ffffff' })
      }
      return true
    })
  }
}

@Builder
export function LoginPageBuilder() {
  LoginPage({
    isChange: NavParams.getParams()?.isChange
  })
}