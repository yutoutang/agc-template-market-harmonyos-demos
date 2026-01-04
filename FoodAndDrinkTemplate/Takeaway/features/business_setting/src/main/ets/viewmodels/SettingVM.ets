import { promptAction } from '@kit.ArkUI';
import { BaseViewModel, CommonConfirmDialog, FileUtils, RouterMap, RouterUtils } from 'lib_common';
import { AccountApi } from 'lib_account';
import { SettingItem } from '../types/Types';
import { MockCouponItem } from 'lib_takeaway_api/src/main/ets/services/mockdata/MockCouponItem';

@ObservedV2
export class SettingViewModel extends BaseViewModel {
  private accountInstance: AccountApi = new AccountApi();
  @Trace isLoading: boolean = false;
  @Trace isCancelLoading: boolean = false;
  @Trace cacheSize: string = '0';
  @Trace cacheSettingItem = new SettingItem({
    label: '清理缓存',
    extraLabel: this.getLocalCacheLabel(),
    onClick: () => {
      CommonConfirmDialog.show({
        primaryTitle: '清除缓存',
        content: '您确定要清除缓存吗？',
        confirm: () => {
          this.clearCache();
        },
      })

    },
  })
  @Trace list1: SettingItem[] = [
    new SettingItem({
      label: '个人信息',
      routerName: RouterMap.SETTING_PERSONAL,
      onClick: () => {
        if (this.userInfoModel.isLogin) {
          RouterUtils.pushPathByName(RouterMap.SETTING_PERSONAL);
        } else {
          promptAction.showToast({ message: '请先登录' });
        }
      },
    }),
    new SettingItem({
      label: '关于我们',
      routerName: RouterMap.SETTING_ABOUT,
    }),
    this.cacheSettingItem,
  ];

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
    this.initToBeCoupon()
    this.accountInstance.signOut()
      .then(() => {
        promptAction.showToast({ message: '已退出登录' });
        RouterUtils.pushPathByName(RouterMap.HUAWEI_LOGIN_PAGE);
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  cancelOutBtnClick() {
    this.isCancelLoading = true;
    this.initToBeCoupon()
    this.accountInstance.signOut()
      .then(() => {
        promptAction.showToast({ message: '已注销账号' });
        RouterUtils.pushPathByName(RouterMap.HUAWEI_LOGIN_PAGE);
      })
      .finally(() => {
        this.isCancelLoading = false;
      });
  }

  @Computed
  get signOutBtnLabel() {
    if (this.isLoading) {
      return '正在退出登录...'
    }
    return '退出登录'
  }

  clearCache() {
    this.cacheSize = '0';
    this.cacheSettingItem.extraLabel = this.getLocalCacheLabel();
    FileUtils.clearCache();
    promptAction.showToast({ message: '清除缓存成功' });
  }

  initToBeCoupon() {
    MockCouponItem.toBeClaimedList.forEach(item => {
      item.receiveStatus = '0';
    })

  }
}