import { BaseViewModel, RouterMap, RouterUtils } from 'lib_common';
import { SettingItem } from 'business_setting';
import { MineGridItem } from '../types/Types';
import { promptAction } from '@kit.ArkUI';

@ObservedV2
export class MineViewModel extends BaseViewModel {
  @Trace feedbackItem: SettingItem = new SettingItem({
    icon: $r('app.media.my_suggest'),
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
      icon: $r('app.media.ic_message'),
      label: '我的评论',
      routerName: RouterMap.MY_COMMENT,
      onClick: () => {
        if (this.userInfoModel.isLogin) {
          RouterUtils.pushPathByName(RouterMap.MY_COMMENT);
        } else {
          promptAction.showToast({ message: '请先登录' });
        }
      },
    }),
    new SettingItem({
      icon: $r('app.media.my'),
      label: '消息中心',
      // routerName: RouterMap. RouterMap.MINE_MSG_SYSTEM,
      onClick: () => {
        if (this.userInfoModel.isLogin) {
          RouterUtils.pushPathByName(RouterMap.MINE_MSG_SYSTEM);
        } else {
          promptAction.showToast({ message: '请先登录' });
        }
      },
    }),
    this.feedbackItem,
    new SettingItem({
      icon: $r('app.media.ic_public_setting'),
      label: '我的设置',
      routerName: RouterMap.SETTING_PAGE,
    }),
  ];

  @Computed
  get userIcon() {
    return this.userInfoModel.authorIcon || $r('app.media.ic_user_default');
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
    RouterUtils.pushPathByName(RouterMap.PROFILE_HOME);
  }

  gridClick(v: MineGridItem) {
    RouterUtils.pushPathByName(v.routerName);
  }
}