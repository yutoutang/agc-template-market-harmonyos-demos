import { AccountUtil, RouterMap, RouterModule, UserInfoModel } from 'commonlib';
import { MineOperationType } from '../commons/Types';

@ObservedV2
export class MinePageVM {
  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo()
  private static _instance: MinePageVM;

  @Computed
  get displayName() {
    if (AccountUtil.isLogin) {
      return this.userInfo.nickname ? this.userInfo.nickname : '华为用户';
    }
    return '点击登录';
  }

  @Computed
  get displayAvatar() {
    if (AccountUtil.isLogin) {
      return this.userInfo.avatar;
    }
    return $r('app.media.ic_default_avatar')
  }

  public static get instance() {
    if (!MinePageVM._instance) {
      MinePageVM._instance = new MinePageVM();
    }
    return MinePageVM._instance;
  }

  public jumpToNext(type: MineOperationType) {
    switch (type) {
      case MineOperationType.MY_ORDERS:
        RouterModule.push({
          url: RouterMap.ORDER_LIST,
        });
        break;
      case MineOperationType.USER_INFO:
        RouterModule.push({
          url: RouterMap.MINE_PROFILE_EDIT,
        });
        break;
      case MineOperationType.SETTINGS:
        RouterModule.push({
          url: RouterMap.MINE_SETTING,
        });
        break;
      default:
        break;
    }
  }
}
