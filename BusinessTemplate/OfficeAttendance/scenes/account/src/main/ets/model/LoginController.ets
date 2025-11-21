@ObservedV2
export class LoginController {
  private static _instance: LoginController;

  public static get instance() {
    if (!LoginController._instance) {
      LoginController._instance = new LoginController();
    }
    return LoginController._instance;
  }

  @Trace isLogin: boolean = false;
  @Trace userName: ResourceStr = $r('app.string.account_name');
  @Trace userAvatar: ResourceStr = $r('app.media.ic_user_default');
  @Trace phone: string = '';
}