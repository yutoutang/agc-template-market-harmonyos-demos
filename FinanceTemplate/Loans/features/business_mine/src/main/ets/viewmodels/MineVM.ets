import { BaseViewModel, RouterMap, RouterUtils } from 'lib_common';
import { SettingItem } from 'business_setting';
import { MineGridItem } from '../types/Types';

@ObservedV2
export class MineViewModel extends BaseViewModel {
  @Trace feedbackItem: SettingItem =
    new SettingItem({
      icon: $r('app.media.ic_public_edit'),
      label: '意见反馈',
      routerName: RouterMap.FEEDBACK_PAGE,
      routerParams: {
        windowTopPadding: this.windowModel.windowTopPadding,
        windowBottomPadding: this.windowModel.windowBottomPadding,
        fontSizeRatio: this.settingInfo.fontSizeRatio,
      } as ESObject,
    });
  serviceList: SettingItem[] = [
    new SettingItem({
      icon: $r('app.media.ic_grid_pencil'),
      label: '联系我们',
      routerName: RouterMap.CONTACT_PAGE,
    }),
  ];

  @Computed
  get userIcon() {
    return this.userInfoModel.authorIcon || $r('app.media.ic_user_unlogin');
  }

  @Monitor('settingInfo.fontSizeRatio')
  onFontRatioChange() {
    this.feedbackItem.routerParams = {
      windowTopPadding: this.windowModel.windowTopPadding,
      windowBottomPadding: this.windowModel.windowBottomPadding,
      fontSizeRatio: this.settingInfo.fontSizeRatio,
    } as ESObject
  }

  jumpLogin() {
    RouterUtils.pushPathByName(RouterMap.HUAWEI_LOGIN_PAGE);
  }

  jumpProfile() {
    RouterUtils.pushPathByName(RouterMap.SETTING_PERSONAL);
  }

  gridClick(v: MineGridItem) {

    if (this.userInfoModel.isLogin) {
      RouterUtils.pushPathByName(v.routerName);
    } else {
      RouterUtils.pushPathByName(RouterMap.HUAWEI_LOGIN_PAGE);
    }

  }
}