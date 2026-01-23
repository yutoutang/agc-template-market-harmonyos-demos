@ObservedV2
export class UserInfoRouter {
  @Trace isVip: boolean = false;
  static singleton: UserInfoRouter;

  static get instance() {
    if (!UserInfoRouter.singleton) {
      UserInfoRouter.singleton = new UserInfoRouter();
    }
    ;
    return UserInfoRouter.singleton;
  }

}