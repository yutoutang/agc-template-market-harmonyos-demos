import { PersistenceV2 } from '@kit.ArkUI';
import { BaseViewModel, SearchHistory, SettingModel } from 'lib_common';
import { RequestListData } from 'lib_video_api';

@ObservedV2
export class HomeViewModel extends BaseViewModel {
  searchHistory: SearchHistory = PersistenceV2.connect(SearchHistory, () => new SearchHistory())!;
  @Trace searchResultList: RequestListData[] = []
  @Trace settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;

  clearHistory() {
    this.searchHistory.historyList = []
  }
}