import { common, Permissions, Want } from '@kit.AbilityKit';
import { LoginSheetUtils } from 'lib_account';
import { BaseViewModel, CommonConfirmDialog } from 'lib_common';
import { ChildSportType } from 'lib_sport_api';
import { MotionType } from 'module_running';
import { SportItemType, WalkType } from '../types/Types';

export enum MySportType {
  TIMED_EXERCISE = '计时运动',
  WALKING = '健走',
  RUNNING = '跑步',
  CYCLING = '骑行'
}

@ObservedV2
export class SportViewModel extends BaseViewModel {
  static readonly defaultDistance: string = '公里';
  static readonly defaultHeat: string = '千卡';
  static readonly defaultDuration: string = '分钟';
  static readonly defaultPace: string = '/公里';
  locationPermissions: Permissions[] = ['ohos.permission.ACTIVITY_MOTION',
    'ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION']
  sportTypeList: SportItemType[] = [
    { name: '计时运动', itemIndex: 0 },
    { name: '健走', itemIndex: 1 },
    { name: '跑步', itemIndex: 2 },
    { name: '骑行', itemIndex: 3 },
  ]
  walkTypeList: WalkType[][] = [[
    { name: '自由走', itemIndex: 0 },
    { name: '目标走', itemIndex: 1 },
    { name: '遛狗', itemIndex: 2 }
  ], [
    { name: '自由跑', itemIndex: 0 },
    { name: '目标跑', itemIndex: 1 }
  ], [
    { name: '自由骑', itemIndex: 0 },
    { name: '目标骑', itemIndex: 1 }
  ]]
  walkBackColors: string[] = [
    '#FFA950',
    '#FFE7CC',
    '#F1F3F5'
  ]
  recordType: string[] = [
    '健走记录',
    '骑行记录',
    '跑步记录'
  ]

  motionTypeConvert(childType: ChildSportType): MotionType {
    if (childType === ChildSportType.DOG_WALKING) {
      return MotionType.walkDog
    } else if (childType === ChildSportType.FREE_WALKING || childType === ChildSportType.FREE_CYCLING ||
      childType === ChildSportType.FREE_JOGGING) {
      return MotionType.isFreedom
    } else {
      return MotionType.target
    }
  }

  public watchOperation() {
    if (!this.userInfoModel.isLogin) {
      LoginSheetUtils.open()
      return true
    }
    return false
  }

  cancelPermissions() {
    CommonConfirmDialog.show({
      primaryTitle: '确认要取消授权吗？',
      content: '取消授权后，将无法获取运动相关功能，如需要请到设置中进行操作',
      priBtnV: '取消',
      secBtnV: '去设置',
      confirm: () => {
        this.goSetting()
      },
      cancel: () => {
        // do nothing
      }
    })
  }

  goSettingToOpen() {
    CommonConfirmDialog.show({
      primaryTitle: '是否确认开启授权？',
      content: '本次开启授权需要到设置页去开启,并打开精确位置权限。', //由于之前未成功授权位置权限，
      priBtnV: '取消',
      secBtnV: '去开启',
      confirm: () => {
        this.goSetting()
      },
      cancel: () => {
        // do nothing
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