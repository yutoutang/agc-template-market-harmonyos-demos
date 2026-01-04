export class CommentEventDispatcher {
  static interceptLogin?: (isLoginCb: (isLogin: boolean) => void) => void;

  static dispatchToInterceptLogin(isLoginCb: (isLogin: boolean) => void) {
    if (CommentEventDispatcher.interceptLogin) {
      CommentEventDispatcher.interceptLogin(isLoginCb);
    }
  }
}