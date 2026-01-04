import { PersistenceV2 } from '@kit.ArkUI';
import { BaseViewModel, LoadingStatus, RouterMap, RouterUtils, SearchHistory, SettingModel, } from 'lib_common';
import {
  BaseSearchStoreServiceApi,
  CategoryItem,
  HomeServiceApi,
  HotSearchItem,
  RequestStoreListData,
  SearchParam
} from 'lib_takeaway_api';
import { StoreResponse } from 'lib_takeaway_api/src/main/ets/params/response/StoreResponse';

@ObservedV2
export class HomeViewModel extends BaseViewModel {
  @Trace
  public refreshStatus: RefreshStatus = RefreshStatus.Inactive;
  @Trace
  public loadingStatus: LoadingStatus = LoadingStatus.LOADING;
  @Trace
  public isRefreshing: boolean = false;
  @Trace
  public isShowFilter: boolean = false;
  @Trace
  public changeByThreshold: number = 0;
  @Trace
  public changeByCategoryNum: number = 0;
  @Trace
  categoryList: CategoryItem[] = [];
  @Trace
  storeList: StoreResponse[] = [];
  @Trace hotSearch: string = ''
  @Trace hotSearchList: HotSearchItem[] = []
  @Trace
  scoreThreshold?: number = undefined; //最低评分阈值（可选）
  @Trace
  salesThreshold?: number = undefined; // 最低销量阈值（可选）
  @Trace
  deliveryTimeThreshold?: number = undefined; // 最大配送时间阈值（可选）
  public timerId: number = -1; // 轮播定时器
  @Trace currentHotSearchIndex: number = 0; // 热搜轮播当前索引

  searchHistory: SearchHistory = PersistenceV2.connect(SearchHistory, () => new SearchHistory())!;
  @Trace searchStoreResultList: RequestStoreListData[] = []
  @Trace settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;

  getCurrentHotSearch(): string {
    if (this.hotSearchList.length === 0) {
      return '请输入搜索关键词';
    }
    this.hotSearch = this.hotSearchList[this.currentHotSearchIndex].label;
    return (this.hotSearch || '');
  }

  getHotSearchList() {
    this.hotSearchList = HomeServiceApi.getHostSearchList()
    this.hotSearchList.sort((a, b) => b.hotRate - a.hotRate);
  }

  // 启动定时器
  startCarousel(): void {
    this.timerId = setInterval(() => {
      if (this.hotSearchList.length > 0) {
        const newIndex = (this.currentHotSearchIndex + 1) % this.hotSearchList.length;
        this.currentHotSearchIndex = newIndex;
      }
    }, 3000);
  }

  // 停止
  stopCarousel(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  getSearchResultList(searchValue: string, index: number) {
    this.searchStoreResultList =
      BaseSearchStoreServiceApi.querySearchStoreResultList(searchValue, index, this.settingInfo.address)
  }

  searchChange(searchValue: string, isSubmit: boolean, index: number) {
    this.getSearchResultList(searchValue, index)
    if ((this.searchHistory.historyList.includes(searchValue) || searchValue.trim() === '') || !isSubmit) {
      return
    }
    //只保留最新的10条
    if (this.searchHistory.historyList.length >= 10) {
      this.searchHistory.historyList.pop()
    }
    this.searchHistory.historyList.unshift(searchValue)
  }

  clearHistory() {
    this.searchHistory.historyList = []
  }

  public onRefreshStateChange(state: RefreshStatus): void {
    this.refreshStatus = state;
    if (state === RefreshStatus.Refresh) {
      this.loadHomePage();
    }
  }

  async loadHomePage(): Promise<void> {
    this.loadingStatus = LoadingStatus.LOADING;
    try {
      const res = await HomeServiceApi.getHomeConfig(this.settingInfo.address);
      if (res.code === 0) {
        this.categoryList = res.categoryList;
        this.storeList = res.storeList;
        this.loadingStatus = LoadingStatus.SUCCESS;
      }
    } catch (e) {
      this.loadingStatus = LoadingStatus.FAIL;
    }
    this.isRefreshing = false;
  }

  jumpToCategoryPage(id: string, title: string, index: number) {
    let routerParams = {
      'id': id,
      'title': title,
      'index': index,
    } as Record<string, Object>
    RouterUtils.pushPathByName(RouterMap.STORE_CATEGORY_PAGE, routerParams)
  }

  jumpToSearchStorePage(index: number) {
    this.isShowFilter = false
    RouterUtils.pushPathByName(RouterMap.STORE_SEARCH, {
      index: index,
      searchValue: this.hotSearch || '',
    } as SearchParam)
  }

  jumpToAddressSearchPage() {
    this.isShowFilter = false
    RouterUtils.pushPathByName(RouterMap.ADDRESS_SEARCH_PAGE)
  }

  jumpToMyAddressSearchPage() {
    this.isShowFilter = false
    RouterUtils.pushPathByName(RouterMap.MY_ADDRESS_SEARCH_PAGE)
  }

  jumpToLogin() {
    this.isShowFilter = false
    RouterUtils.pushPathByName(RouterMap.HUAWEI_LOGIN_PAGE)
  }
}