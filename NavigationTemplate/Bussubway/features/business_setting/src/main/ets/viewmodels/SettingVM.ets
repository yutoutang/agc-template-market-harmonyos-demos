import { promptAction } from '@kit.ArkUI';
import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import { AppGalleryUtils, BaseViewModel, FileUtils, RouterMap, RouterUtils, SystemBarOperation } from 'lib_common';
import { SettingItem } from '../types/Types';
import { AccountApi } from 'lib_account';

@ObservedV2
export class SettingViewModel extends BaseViewModel {
  @Trace isLoading: boolean = false;
  @Trace cacheSize: string = '0';
  @Trace location: string = '/storage/emulated/0/Download/Music/'
  @Trace isFocusOnPage: boolean = true;

  @Trace pushSettingItem = new SettingItem({
    label: '通知开关',
    typeSwitch: true,
    switchV: this.settingInfo.pushSwitch,
    onClick: (isOn) => {
      this.requestPushPermission(isOn as boolean);
    },
  });
  private accountInstance: AccountApi = new AccountApi();

  @Computed
  get signOutBtnLabel() {
    if (this.isLoading) {
      return '正在退出登录...'
    }
    return '退出登录'
  }

  setColorMode(isDark: boolean) {
    const mode =
      isDark ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK : ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
    getContext().getApplicationContext().setColorMode(mode);
    SystemBarOperation.setWindowSystemBarProp({
      statusBarContentColor: isDark ? '#ffffff' : '#ff090909'
    })
  }

  requestPushPermission(isOn: boolean) {
    notificationManager.openNotificationSettings(getContext(this) as common.UIAbilityContext)
      .then(() => {
        this.isFocusOnPage = false;
      })
  }

  getLocalCacheLabel() {
    return `${this.cacheSize}M`;
  }

  onSignOutBtnClick() {
    this.isLoading = true;
    this.accountInstance.signOut()
      .then(() => {
        promptAction.showToast({ message: '已退出登录' });
        RouterUtils.pop()
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  getLocationLabel() {
    return `${this.location}M`;
  }
}