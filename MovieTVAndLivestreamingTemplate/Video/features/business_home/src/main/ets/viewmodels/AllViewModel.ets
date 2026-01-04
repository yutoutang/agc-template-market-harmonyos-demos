import { BaseViewModel } from 'lib_common';
import { TabType, VideoModel, VideoServiceApi } from 'lib_video_api';
import { channelList, TabInfo } from '../model/TabInfoModel';

@ObservedV2
export class AllViewModel extends BaseViewModel {
  @Trace hotIndex: number = 0
  @Trace videoTypeIndex: number = 0
  @Trace contentTypeIndex: number = 0
  @Trace countryIndex: number = 0
  @Trace yearIndex: number = 0
  @Trace hot: TabType = TabType.ALL
  @Trace videoType: string | null = null
  @Trace contentType: string | null = null
  @Trace country: string | null = null
  @Trace year: string | null = null
  @Trace filteredVideoList: VideoModel[] = []
  @Trace hotList: TabInfo[] = channelList
  @Trace videoTypeList: string[] = ['全部', '科幻', '战争', '年代', '爱情', '喜剧'];
  @Trace contentTypeList: string[] = ['全部', '热播', '热搜', '必看榜', '小朋友爱看', '亲子互动'];
  @Trace countryList: string[] = ['全部', '中国大陆', '中国香港', '中国台湾', '日韩', '美国'];
  @Trace yearList: string[] = ['全部', '2025', '2024', '2023', '2022', '2021'];
  @Trace currentPage: number = 1;
  @Trace pageSize: number = 20; // 每页加载数量
  @Trace hasMore: boolean = true;
  @Trace isLoadingMore: boolean = false;
  @Trace isRefreshing: boolean = false; // 刷新状态

  // 存储当前筛选条件下的所有数据
  private currentFullList: VideoModel[] = [];

  init() {
    this.refreshData();
  }

  // 刷新数据（重置到第一页）
  refreshData() {
    this.currentPage = 1;
    this.hasMore = true;
    this.isRefreshing = true;

    // 模拟网络请求延迟
    setTimeout(() => {
      this.filterVideos();
      this.isRefreshing = false;
    }, 300);
  }

  hotChange(category: TabType) {
    this.hot = category;
    this.refreshData();
  }

  videoTypeChange(category: string) {
    this.videoType = category === '全部' ? null : category;
    this.refreshData();
  }

  contentTypeChange(category: string) {
    this.contentType = category === '全部' ? null : category;
    this.refreshData();
  }

  countryChange(category: string) {
    this.country = category === '全部' ? null : category;
    this.refreshData();
  }

  yearChange(category: string) {
    this.year = category === '全部' ? null : category;
    this.refreshData();
  }

  // 筛选视频的核心方法
  filterVideos() {
    let fullList: VideoModel[] = [];

    if (this.hot === TabType.ALL && !this.videoType && !this.contentType && !this.country && !this.year) {
      fullList = VideoServiceApi.videoList();
    } else {
      fullList = VideoServiceApi.queryCategoryListByTabType(
        this.hot,
        this.contentType as '热播' | '热搜' | '必看榜' | null,
        this.videoType as '战争' | '伦理' | '年代' | '爱情' | '喜剧' | null,
        this.country as '中国' | '美国' | '韩国' | '日本' | '英国' | null,
        this.year as '2025' | '2024' | '2023' | '2022' | '2021' | null
      );
    }

    this.currentFullList = fullList;
    this.loadPageData();
  }

  // 加载当前页数据
  private loadPageData() {
    const startIndex = 0; // 每次筛选都从0开始
    const endIndex = this.currentPage * this.pageSize;

    if (startIndex >= this.currentFullList.length) {
      this.filteredVideoList = [];
      this.hasMore = false;
      return;
    }

    this.filteredVideoList = this.currentFullList.slice(startIndex, endIndex);
    this.hasMore = endIndex < this.currentFullList.length;
  }

  // 加载更多数据
  loadMore() {
    if (this.isLoadingMore || !this.hasMore || this.currentFullList.length === 0) {
      return;
    }

    this.isLoadingMore = true;

    // 模拟网络请求延迟
    setTimeout(() => {
      this.currentPage += 1;
      const startIndex = 0; // 从头开始取数据
      const endIndex = this.currentPage * this.pageSize;

      if (endIndex >= this.currentFullList.length) {
        this.filteredVideoList = this.currentFullList.slice(startIndex);
        this.hasMore = false;
      } else {
        this.filteredVideoList = this.currentFullList.slice(startIndex, endIndex);
        this.hasMore = true;
      }

      this.isLoadingMore = false;
    }, 800); // 800ms 模拟网络延迟
  }

  // 如果需要，保留这个方法
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