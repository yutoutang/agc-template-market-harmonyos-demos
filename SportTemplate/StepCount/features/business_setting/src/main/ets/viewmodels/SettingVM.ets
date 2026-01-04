import { AlertDialog, promptAction } from '@kit.ArkUI';
import { BaseViewModel, CommonConfirmDialog, FileUtils, Logger, RouterMap } from 'lib_common';
import { AccountApi } from 'lib_account';
import { SettingItem } from '../types/Types';

const TAG = '[SettingPersonal]';

@ObservedV2
export class SettingViewModel extends BaseViewModel {
  private accountInstance: AccountApi = new AccountApi();
  @Trace isLoading: boolean = false;
  @Trace isDestroyAccountLoading: boolean = false;
  @Trace cacheSize: string = '0';
  @Trace location: string = '/storage/emulated/0/Download/Music/'
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: '清理缓存',
      // secondaryTitle: '弹框二级标题',
      content: '您确定要清除缓存吗?',
      primaryButton: {
        value: '取消',
        fontColor: $r('app.color.cancel_font_color'),
        action: () => {
        },
      },
      secondaryButton: {
        value: '确认',
        role: ButtonRole.ERROR,
        action: () => {
          this.cacheSize = '0';
          this.cacheSettingItem.extraLabel = this.getLocalCacheLabel();
          FileUtils.clearCache();
          promptAction.showToast({ message: '清除缓存成功' });
          Logger.info(TAG, 'Callback when the second button is clicked')
        }
      },
    })
  })
  @Trace cacheSettingItem = new SettingItem({
    label: '清理缓存',
    extraLabel: this.getLocalCacheLabel(),
    onClick: () => {
    }
  })
  @Trace list1: SettingItem[] = [
    new SettingItem({
      label: '通知设置',
      routerName: RouterMap.SETTING_NOTICE,
    })
  ];
  @Trace list2: SettingItem[] = [
    new SettingItem({
      label: '自动生成运动记录',
      routerName: RouterMap.SETTING_AUTO_SPORT_RECORD,
      extraLabel: this.settingInfo.autoSportsRecordSwitch ? this.settingInfo.autoSportsRecordMinValue : '未开启'
    }),
    new SettingItem({
      label: '用户协议',
      routerName: RouterMap.SETTING_H5,
      routerParams: 1,
    }),
    new SettingItem({
      label: '隐私政策',
      routerName: RouterMap.SETTING_PRIVACY,
    })
  ];
  @Trace list3: SettingItem[] = [
    this.cacheSettingItem,
    new SettingItem({
      label: '授权权限',
      routerName: RouterMap.SETTING_AUTHORIZATION,
    }),
  ]
  @Trace list4: SettingItem[] = [
    new SettingItem({
      label: '注销账号',
      labelColor: $r('app.color.color_E84026'),
      onClick: () => {
        CommonConfirmDialog.show({
          priBtnFg: $r('app.color.color_99000000'),
          primaryTitle: '请确认是否注销?',
          content: '您的个人信息及使用数据将被清空，且无法恢复。',
          confirm: () => {
            this.onDestroyAccountBtnClick();
          },
        })
      }
    }),
  ]

  @Monitor('settingInfo.autoSportsRecordSwitch','settingInfo.autoSportsRecordMinValue')
  autoRecordChanged() {
    const autoRecord = this.list2.find(value => value.routerName === RouterMap.SETTING_AUTO_SPORT_RECORD)
    if (autoRecord) {
      autoRecord.extraLabel =
        this.settingInfo.autoSportsRecordSwitch ? this.settingInfo.autoSportsRecordMinValue : '未开启'
    }
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
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  @Computed
  get signOutBtnLabel() {
    if (this.isLoading) {
      return '正在退出登录...'
    }
    return '退出登录'
  }

  @Computed
  get destroyAccountBtnLabel() {
    if (this.isDestroyAccountLoading) {
      return '正在注销账号...'
    }
    return '注销账号'
  }

  onDestroyAccountBtnClick() {
    this.isDestroyAccountLoading = true;
    this.accountInstance.destroyAccount()
      .then(() => {
        promptAction.showToast({ message: '已注销账号' });
        this.accountInstance.doLogOut()
      })
      .finally(() => {
        this.isDestroyAccountLoading = false;
      });
  }

  getLocationLabel() {
    return `${this.location}M`;
  }
}