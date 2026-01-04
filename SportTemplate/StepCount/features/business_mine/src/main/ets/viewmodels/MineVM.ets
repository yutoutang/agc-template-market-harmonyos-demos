import { BaseViewModel, RouterMap, RouterUtils } from 'lib_common';
import { SettingItem } from 'business_setting';
import { MineGridItem } from '../types/Types';

@ObservedV2
export class MineViewModel extends BaseViewModel {
  @Trace feedbackItem: SettingItem = new SettingItem({
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
    this.feedbackItem,
    new SettingItem({
      icon: $r('app.media.ic_check_update'),
      label: '版本更新',
      routerName: RouterMap.VERSION_UPDATE
    }),
    new SettingItem({
      icon: $r('app.media.ic_about_info'),
      label: '关于我们',
      routerName: RouterMap.SETTING_ABOUT,
    }),
  ];

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
    RouterUtils.pushPathByName(RouterMap.PROFILE_HOME);
  }

  jumpPersonal() {
    RouterUtils.pushPathByName(RouterMap.SETTING_PERSONAL);
  }

  gridClick(v: MineGridItem) {
    RouterUtils.pushPathByName(v.routerName);
  }

  @Computed
  get userIcon() {
    return this.userInfoModel.authorIcon || $r('app.media.ic_user_default');
  }
}