import { BaseViewModel, CommonConfirmDialog, PermissionUtils } from 'lib_common';
import { SettingItem } from '../types/Types';
import { common, Permissions, Want } from '@kit.AbilityKit';

@ObservedV2
export class SettingAuthorizationVM extends BaseViewModel {
  locationPermissions: Permissions[] = ['ohos.permission.ACTIVITY_MOTION',
    'ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION']
  @Trace item1: SettingItem = new SettingItem({
    typeSwitch: true,
    label: '运动健康权限',
    switchV: this.settingInfo.exerciseAndHealthAuthorization,
    onClick: (isOn) => {
      this.settingInfo.exerciseAndHealthAuthorization = isOn as boolean;
    },
  });
  @Trace item2: SettingItem = new SettingItem({
    label: '位置权限管理',
    switchV: this.settingInfo.positionAuthorization,
    onClick: async (isOn) => {
      this.goSetting()
    },
  });
  @Trace list1: SettingItem[] = [
    this.item1,
    this.item2,
  ];

  //初始化或刷新2个toggle状态
  initCheckAuthorization() {
    PermissionUtils.checkPermissionsList(this.locationPermissions).then((checkPermission) => {
      this.item2.switchV = checkPermission;
      this.list1 = [
        this.item1,
        this.item2,
      ];
    })
  }

  cancelPermissions() {
    CommonConfirmDialog.show({
      priBtnFg: $r('app.color.color_99000000'),
      primaryTitle: '确认要取消授权吗？',
      content: '取消授权后，将无法获取运动相关功能，如需要请到设置中进行操作',
      priBtnV: '取消',
      secBtnV: '去设置',
      confirm: () => {
        this.goSetting()
      }
    })
  }

  goSettingToOpen() {
    CommonConfirmDialog.show({
      primaryTitle: '是否确认开启授权？',
      content: '本次开启授权需要到设置页去开启,并打开精确位置权限。', //由于之前未成功授权位置权限，
      priBtnV: '取消',
      priBtnFg: $r('app.color.color_99000000'),
      secBtnV: '去开启',
      confirm: () => {
        this.goSetting()
      }
    })
  }

  goSetting() {
    let want: Want = {
      bundleName: 'com.huawei.hmos.settings',
      abilityName: 'com.huawei.hmos.settings.MainAbility',
      uri: 'application_info_entry',
      parameters: {
        pushParams: 'com.isoftstone.rtstepcounttemplate'
      }
    };
    (getContext() as common.UIAbilityContext).startAbility(want)
  }
}