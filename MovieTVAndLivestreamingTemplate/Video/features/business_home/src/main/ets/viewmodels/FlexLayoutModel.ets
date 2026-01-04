import { BaseViewModel, CommonConfirmDialog } from 'lib_common';
import { TabType, VideoModel, VideoServiceApi } from 'lib_video_api';
import { channelList, TabInfo } from '../model/TabInfoModel';
import { PersistenceV2 } from '@kit.ArkUI';
import { SearchHistory } from '../model/SearchHistoryModel';

@ObservedV2
export class FlexLayoutModel extends BaseViewModel {
  @Trace searchValue: string = ''
  @Trace placeValue: string = '搜索片名'
  @Trace tabList: TabInfo[] = []
  @Trace swiperIndex: number = 0
  @Trace videoModelList: VideoModel[] = [] // 页面渲染核心数据源
  @Trace swiperList: VideoModel[] = []
  @Trace allSwiperList: VideoModel[] = []
  @Trace currentIndex: number = 0
  @Trace title: string = '人气热播' // 默认标题，避免初始化空值
  @Trace hitList: VideoModel[] = []
  @Trace isGrid: boolean = true
  @Trace childList: VideoModel[] = []
  @Trace parentList: VideoModel[] = []
  @Trace hotSearchList: VideoModel[] = []
  @Trace mustList: VideoModel[] = []
  @Trace isRefreshing: boolean = false;
  @Trace refreshText: string = '';
  @Trace recommendSearchList: VideoModel[] = []
  @Trace recommendPageIndex: number = 0
  searchHistory: SearchHistory = PersistenceV2.connect(SearchHistory, () => new SearchHistory())!;
  @Trace searchResultList: VideoModel[] = [];
  @Trace searchHistoryList: string[] = [];
  @Trace isEditing: boolean = true
  @Trace currentPage: number = 1; // 初始第一页
  @Trace pageSize: number = 10; // 固定每页10条
  @Trace hasMore: boolean = true; // 默认有更多数据
  @Trace isLoadingMore: boolean = false; // 加载中标记
  controller: SearchController = new SearchController();

  init(currentIndex: number) {
    this.currentIndex = currentIndex
    this.tabList = channelList
    this.initRecommendSearchData()
    this.loadHomePageData(currentIndex);
    // 初始化时加载默认标题数据（关键：确保页面首次有数据）
    this.loadDataByTitle(this.title, currentIndex);
  }

  loadHomePageData(currentIndex: number) {
    const currentChannelId = this.getChannelIdByIndex(currentIndex);
    if (!currentChannelId) {
      return;
    }
    const tabType = this.convertIdToTabType(currentChannelId);
    // 按当前页码和10条/页加载各分类数据（仅存储，不直接渲染）
    this.hitList = VideoServiceApi.queryVideoListByTabType(tabType, '热播', this.currentPage, this.pageSize);
    this.hotSearchList = VideoServiceApi.queryVideoListByTabType(tabType, '热搜', this.currentPage, this.pageSize);
    this.mustList = VideoServiceApi.queryVideoListByTabType(tabType, '必看榜', this.currentPage, this.pageSize);
    this.childList = VideoServiceApi.queryVideoListByTabType(tabType, '小朋友爱看', this.currentPage, this.pageSize);
    this.parentList = VideoServiceApi.queryVideoListByTabType(tabType, '亲子互动', this.currentPage, this.pageSize);
    this.swiperList = VideoServiceApi.queryVideoSwiper(tabType);
  }

  getTitle(title: string, index: number) {
    this.title = title
    this.currentIndex = index
    this.currentPage = 1; // 切换标题重置页码为第一页
    this.hasMore = true; // 重置有更多数据状态
    this.loadDataByTitle(title, index);
  }

  loadDataByTitle(title: string, currentIndex: number, isLoadMore: boolean = false) {
    const currentChannelId = this.getChannelIdByIndex(currentIndex);
    if (!currentChannelId) {
      this.hasMore = false;
      this.isLoadingMore = false;
      return;
    }

    const tabType = this.convertIdToTabType(currentChannelId);
    let newData: VideoModel[] = [];

    // 根据标题加载对应分类数据（严格按当前页码和10条/页）
    switch (title) {
      case '人气热播':
        newData = VideoServiceApi.queryVideoListByTabType(tabType, '热播', this.currentPage, this.pageSize);
        break;
      case '经典热搜':
        newData = VideoServiceApi.queryVideoListByTabType(tabType, '热搜', this.currentPage, this.pageSize);
        break;
      case '推荐必看':
        newData = VideoServiceApi.queryVideoListByTabType(tabType, '必看榜', this.currentPage, this.pageSize);
        break;
      case '小朋友爱看':
        newData = VideoServiceApi.queryVideoListByTabType(tabType, '小朋友爱看', this.currentPage, this.pageSize);
        break;
      case '亲子互动':
        newData = VideoServiceApi.queryVideoListByTabType(tabType, '亲子互动', this.currentPage, this.pageSize);
        break;
      default:
        newData = [];
        this.hasMore = false;
    }

    // 处理数据：加载更多追加，首次加载重置
    if (isLoadMore) {
      // 去重：避免重复数据（防止接口返回重复）
      const uniqueData = newData.filter(newItem =>
      !this.videoModelList.some(existItem => existItem.videoId === newItem.videoId)
      );
      this.videoModelList = [...this.videoModelList, ...uniqueData];
    } else {
      this.videoModelList = newData;
    }

    // 判断是否有更多数据：返回数据小于10条 → 无更多
    this.hasMore = newData.length === this.pageSize;
    this.isLoadingMore = false; // 结束加载状态
  }

  // 加载更多核心方法（严格控制重复请求）
  loadMore() {
    // 防重逻辑：正在加载/无更多数据 → 不执行
    if (this.isLoadingMore || !this.hasMore || this.videoModelList.length === 0) {
      return;
    }

    this.isLoadingMore = true; // 标记加载中（立即更新UI显示动画）
    this.currentPage++; // 页码+1
    // 延迟执行（模拟接口请求延迟，避免UI闪烁）
    setTimeout(() => {
      this.loadDataByTitle(this.title, this.currentIndex, true);
    }, 500);
  }


  search(keyword: string) {
    this.addSearchHistory(keyword);
    this.searchResultList = VideoServiceApi.searchVideoList(keyword);
  }

  searchChange(keyword: string) {
    this.searchResultList = VideoServiceApi.searchVideoList(keyword);
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

  getList() {
    this.allSwiperList = VideoServiceApi.videoList();
  }

  initRecommendSearchData(): void {
    try {
      this.getList()
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

  public getChannelIdByIndex(index: number) {
    if (index >= 0 && index < this.tabList.length) {
      return this.tabList[index].id;
    }
    return undefined;
  }

  public currentIndexChange(index: number) {
    this.currentIndex = index
    this.currentPage = 1;
    this.hasMore = true;
    this.loadHomePageData(index);
    this.loadDataByTitle(this.title, index);
  }

  async refreshData(): Promise<void> {
    if (this.isRefreshing) {
      return;
    }
    this.isRefreshing = true;
    this.refreshText = '加载中...';

    try {
      setTimeout(() => {
        this.currentPage = 1;
        this.loadDataByTitle(this.title, this.currentIndex);
        this.refreshText = '';
      }, 1000)

    } catch (error) {
      this.refreshText = '刷新失败，重试';
    } finally {
      setTimeout(() => {
        this.isRefreshing = false;
      }, 500)
    }
  }

  private convertIdToTabType(id: string): TabType {
    switch (id) {
      case 'recommend':
        return TabType.Recommend;
      case 'movie':
        return TabType.Movie;
      case 'tv_movie':
        return TabType.TvMovie;
      case 'children':
        return TabType.Children;
      default:
        return TabType.Recommend;
    }
  }
}