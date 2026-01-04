import { PersistenceV2 } from '@kit.ArkUI';
import { BaseViewModel, SearchHistory, SettingModel } from 'lib_common';

@ObservedV2
export class HomeViewModel extends BaseViewModel {
  searchHistory: SearchHistory = PersistenceV2.connect(SearchHistory, () => new SearchHistory())!;
  @Trace settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;

  /**
   * 运行中剩余数据
   *
   * @param current
   * @param total
   * @returns
   */
  runningRemainderData(current: ESObject, total: ESObject) {
    let remainder = Number(total) - Number(current)
    return remainder < 0 ? 0 : Math.round(remainder * 100) / 100
  }
}