import { promptAction } from '@kit.ArkUI';
import { BaseViewModel, FileUtils, PreferencesHelper, RouterMap, RouterUtils } from 'lib_common';
import { AccountApi } from 'lib_account';
import { SettingItem } from '../types/Types';

@ObservedV2
export class SettingViewModel extends BaseViewModel {
  @Trace isLoading: boolean = false;
  @Trace cacheSize: string = '0';
  @Trace location: string = '/storage/emulated/0/Download/Music/'
  @Trace cacheSettingItem = new SettingItem({
    label: '清理缓存',
    extraLabel: this.getLocalCacheLabel(),
    onClick: () => {
      this.cacheSize = '0';
      this.cacheSettingItem.extraLabel = this.getLocalCacheLabel();
      FileUtils.clearCache();
      promptAction.showToast({ message: '已清除缓存' });
    },
  })
  @Trace qualitySettingItem = new SettingItem({
    label: '动态壁纸背景音',
    typeSwitch: true,
    switchV: PreferencesHelper.getInstance().checkAudioState(getContext()),
    onClick: (isOn) => {
      PreferencesHelper.getInstance().saveAudioState(getContext(), isOn as boolean)
    },
  });
  @Trace list4: SettingItem[] = [
    new SettingItem({
      label: '关于我们',
      routerName: RouterMap.SETTING_ABOUT,
    }),
    this.cacheSettingItem,
  ];
  @Trace list5: SettingItem[] = [
    this.qualitySettingItem,
  ];
  private accountInstance: AccountApi = new AccountApi();

  @Computed
  get signOutBtnLabel() {
    if (this.isLoading) {
      return '正在退出登录...'
    }
    return '退出登录'
  }

  getCache() {
    FileUtils.getCache().then((resp: number) => {
      this.cacheSize = (resp / 1024 / 1024).toFixed(2);
      this.cacheSettingItem.extraLabel = this.getLocalCacheLabel();
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
}