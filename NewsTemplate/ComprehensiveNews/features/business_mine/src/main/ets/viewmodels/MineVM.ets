import { BaseViewModel, RouterMap, RouterUtils } from 'lib_common';
import { LoginSheetUtils } from 'lib_account';
import { FeedbackModel } from 'module_feedback';
import { IRouterParams, SettingGroup, SettingItem, SettingType } from 'module_app_setting';
import { MineGridItem } from '../types/Types';

@ObservedV2
export class MineViewModel extends BaseViewModel {
  @Trace feedbackItem: SettingItem = new SettingItem()
    .setType(SettingType.ROUTER)
    .setLabel('意见反馈')
    .setIcon($r('app.media.ic_public_edit'))
    .setRouterParam(this.feedbackRouterParam);
  @Trace list: SettingItem[] = [
    new SettingItem()
      .setType(SettingType.ROUTER)
      .setLabel('我的订阅')
      .setIcon($r('app.media.plus_bookmark'))
      .setRouterParam({ routerName: RouterMap.SETTING_SUBSCRIBE }),
    new SettingItem()
      .setType(SettingType.ROUTER)
      .setLabel('浏览历史')
      .setIcon($r('app.media.ic_public_history'))
      .setRouterParam({ routerName: RouterMap.MINE_HISTORY_PAGE }),
    this.feedbackItem,
    new SettingItem()
      .setType(SettingType.ROUTER)
      .setLabel('设置')
      .setIcon($r('app.media.ic_public_setting'))
      .setRouterParam({ routerName: RouterMap.SETTING_PAGE }),
  ];
  @Trace group: SettingGroup = new SettingGroup().setList(this.list)

  @Monitor('settingInfo.fontSizeRatio')
  onFontRatioChange() {
    this.feedbackItem.setRouterParam(this.feedbackRouterParam);
  }

  @Computed
  get feedbackRouterParam() {
    return {
      routerName: RouterMap.FEEDBACK_SUBMIT_PAGE,
      routerParams: {
        windowTopPadding: this.windowModel.windowTopPadding,
        windowBottomPadding: this.windowModel.windowBottomPadding,
        fontSizeRatio: this.settingInfo.fontSizeRatio,
      } as FeedbackModel,
    } as IRouterParams
  }

  jumpLogin() {
    LoginSheetUtils.jumpLoginPage();
  }

  jumpProfile() {
    RouterUtils.pushPathByName(RouterMap.PROFILE_HOME);
  }

  gridClick(v: MineGridItem) {
    RouterUtils.pushPathByName(v.routerName);
  }

  @Computed
  get userIcon() {
    return this.userInfoModel.authorIcon || $r('app.media.ic_user_default');
  }

  @Computed
  get pagePaddingBottom() {
    if (this.tabModel.isTabVertical) {
      return this.windowModel.windowBottomPadding;
    }
    return 48;
  }
}