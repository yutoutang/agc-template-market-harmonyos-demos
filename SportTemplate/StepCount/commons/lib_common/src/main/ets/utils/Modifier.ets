import { SettingModel } from '../models/SettingModel'
import { PersistenceV2 } from '@kit.ArkUI'
import { abilityAccessCtrl, common, Permissions, Want } from '@kit.AbilityKit'

@ObservedV2
export class LinearColumnModifier implements AttributeModifier<ColumnAttribute> {
  //运动相关权限
  static permissions: Permissions[] = ['ohos.permission.ACTIVITY_MOTION',
    'ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION']
  @Trace settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!
  color: ResourceStr = '#FFFFFF'

  constructor(color: ResourceStr) {
    this.color = color
  }

  requestPermissions(permissions: Permissions[]): void {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(getContext() as common.UIAbilityContext, permissions)
  }

  /**
   * 检查权限
   * @param permissions
   * @returns false 已开启权限 true 未开启权限
   */
  static async checkPermissions(permissions: Permissions[]): Promise<boolean> {
    try {
      let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
      const requestResult =
        await atManager.requestPermissionsFromUser(getContext() as common.UIAbilityContext, permissions);
      const hasPermissions = requestResult.authResults.some(item => item !== 0)
      if (hasPermissions) {
        return true
      }
    } catch (e) {
    }
    return false
  }

  //跳转系统设置界面
  static toSystemSetting() {
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

  applyNormalAttribute(instance: ColumnAttribute): void {
    if (!this.settingInfo.darkSwitch) {
      instance.linearGradient({
        angle: 180,
        colors: [
          [$r('app.color.gradient_start'), 0.05],
          [this.color, 0.12],
        ],
      })
    }
  }
}