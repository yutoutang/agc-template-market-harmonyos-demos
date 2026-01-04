export class StopEventDispatcher {
  static interceptLogin?: (isLoginCb: (isLogin: boolean) => void) => void;

  static dispatchToInterceptLogin(isLoginCb: (isLogin: boolean) => void) {
    if (StopEventDispatcher.interceptLogin) {
      StopEventDispatcher.interceptLogin(isLoginCb);
    }
  }
}

