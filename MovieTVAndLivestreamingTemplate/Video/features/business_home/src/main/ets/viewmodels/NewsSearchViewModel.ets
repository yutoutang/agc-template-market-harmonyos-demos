import { BaseViewModel, CommonConfirmDialog } from 'lib_common';
import { TabType, VideoModel, VideoServiceApi } from 'lib_video_api';
import { PersistenceV2 } from '@kit.ArkUI';
import { SearchHistory } from '../model/SearchHistoryModel';

@ObservedV2
export class NewsSearchViewModel extends BaseViewModel {
  @Trace searchValue: string = ''
  @Trace placeValue: string = '搜索片名'
  @Trace allSwiperList: VideoModel[] = []
  @Trace hitList: VideoModel[] = []
  @Trace recommendSearchList: VideoModel[] = []
  @Trace recommendPageIndex: number = 0
  searchHistory: SearchHistory = PersistenceV2.connect(SearchHistory, () => new SearchHistory())!;
  @Trace searchResultList: VideoModel[] = [];
  @Trace isEditing: boolean = false

  init() {
    this.initRecommendSearchData()
    // 初始化时加载默认标题数据（关键：确保页面首次有数据）
    this.hitList = VideoServiceApi.queryVideoListByTabType(TabType.Recommend, '热播', 1, 10);
  }

  search(keyword: string) {
    this.addSearchHistory(keyword);
    this.searchResultList = VideoServiceApi.searchVideoList(keyword);
  }

  searchChange(keyword: string) {
    if (keyword) {
      this.searchResultList = VideoServiceApi.searchVideoList(keyword);
    } else {
      this.searchResultList = []
    }
  }

  clearHistory() {
    CommonConfirmDialog.show({
      primaryTitle: '温馨提示',
      content: '确定要清空所有搜索历史吗？',
      secBtnV: '删除',
      secBtnFg: $r('sys.color.warning'),
      confirm: () => {
        this.searchHistory.historyList = []
        this.isEditing = !this.isEditing
      },
    })

  }

  addSearchHistory(keyword: string) {
    if (!keyword.trim()) {
      return;
    }
    this.searchHistory.historyList = this.searchHistory.historyList.filter(item => item !== keyword);
    this.searchHistory.historyList.unshift(keyword);
    if (this.searchHistory.historyList.length > 10) {
      this.searchHistory.historyList = this.searchHistory.historyList.slice(0, 10);
    }
  }

  initRecommendSearchData(): void {
    try {
      this.allSwiperList = VideoServiceApi.videoList();
      this.updateRecommendSearchList();
    } catch (error) {
      this.recommendSearchList = [];
    }
  }

  updateRecommendSearchList(): void {
    if (this.allSwiperList.length === 0) {
      this.recommendSearchList = [];
      return;
    }

    const pageSize = 5;
    const totalItems = this.allSwiperList.length;
    const maxPage = Math.ceil(totalItems / pageSize);
    this.recommendPageIndex = (this.recommendPageIndex + 1) % maxPage;
    const startIndex = this.recommendPageIndex * pageSize;
    const endIndex = Math.min(startIndex + pageSize, totalItems);
    this.recommendSearchList = this.allSwiperList.slice(startIndex, endIndex);
    if (this.recommendSearchList.length < pageSize && this.allSwiperList.length >= pageSize) {
      const remainingCount = pageSize - this.recommendSearchList.length;
      const supplementData = this.allSwiperList.slice(0, remainingCount);
      this.recommendSearchList = [...this.recommendSearchList, ...supplementData]
    }
  }

  refreshRecommendSearch(): void {
    this.updateRecommendSearchList();
  }
}