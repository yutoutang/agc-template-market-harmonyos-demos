import { BaseViewModel } from 'lib_common';
import { SettingItem } from '../types/Types';

@ObservedV2
export class SettingNoticeVM extends BaseViewModel {
  @Trace item1: SettingItem = new SettingItem({
    typeSwitch: true,
    label: '允许新消息通知',
    switchV: this.settingInfo.pushSwitch,
    onClick: (isOn) => {
      this.settingInfo.pushSwitch = isOn as boolean;
    },
  });
  @Trace item2: SettingItem = new SettingItem({
    typeSwitch: true,
    label: '允许推送通知',
    switchV: this.settingInfo.pushNewSwitch,
    onClick: (isOn) => {
      this.settingInfo.pushNewSwitch = isOn as boolean;
    },
  });
  @Trace list1: SettingItem[] = [
    this.item1,
    this.item2,
  ];
}