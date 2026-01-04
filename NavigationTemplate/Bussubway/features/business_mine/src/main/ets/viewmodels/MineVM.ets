import { BaseViewModel, RouterMap, RouterUtils } from 'lib_common';
import { SettingItem } from 'business_setting';
import { MineGridItem } from '../types/Types';
import { LoginSheetUtils } from 'lib_account';

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
      icon: $r('app.media.ic_public_setting'),
      label: '设置',
      routerName: RouterMap.SETTING_PAGE,
      onClick: () => {
        // 登录校验
        if (!this.userInfoModel.isLogin) {
          LoginSheetUtils.open();
          return;
        }
        RouterUtils.pushPathByName(RouterMap.SETTING_PAGE);
      },
    }),
  ];

  @Computed
  get userIcon() {
    return this.userInfoModel.userIcon || $r('app.media.ic_user_default');
  }

  jumpLogin() {
    RouterUtils.pushPathByName(RouterMap.HUAWEI_LOGIN_PAGE);
  }

  gridClick(v: MineGridItem) {
    // 登录校验
    if (v.routerName === RouterMap.COLLECT_PAGE && !this.userInfoModel.isLogin) {
      LoginSheetUtils.open();
      return;
    }
    RouterUtils.pushPathByName(v.routerName);
  }
}