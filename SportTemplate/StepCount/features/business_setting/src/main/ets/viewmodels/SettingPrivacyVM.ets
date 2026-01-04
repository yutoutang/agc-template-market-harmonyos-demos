import { BaseViewModel, RouterMap } from 'lib_common';
import { SettingItem } from '../types/Types';

@ObservedV2
export class SettingPrivacyVM extends BaseViewModel {
  @Trace list1: SettingItem[] = [
    new SettingItem({
      label: '隐私政策',
      routerName: RouterMap.SETTING_H5,
      routerParams: 2,
    }),
    new SettingItem({
      label: '第三方信息共享清单',
      routerName: RouterMap.SETTING_H5,
      routerParams: 3,
    }),
    new SettingItem({
      label: '个人信息收集清单',
      routerName: RouterMap.SETTING_H5,
      routerParams: 4,
    }),
  ];
}