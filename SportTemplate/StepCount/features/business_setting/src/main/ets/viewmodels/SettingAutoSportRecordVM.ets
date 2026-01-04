import { BaseViewModel } from 'lib_common';

@ObservedV2
export class SettingAutoSportRecordVM extends BaseViewModel {
  @Trace showSportRecordSheet: boolean = false;
  @Trace item: string[] = ['100m', '200m', '500m', '800m', '1000m', '1500m', '2000m'];
}