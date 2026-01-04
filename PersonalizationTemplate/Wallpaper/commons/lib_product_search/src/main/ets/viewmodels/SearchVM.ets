import { SearchDataHelper } from '../data/SearchDataHelper';
import { ImageInfo } from 'module_wallpaper_details';
import { HistorySearchItem, HotSearchItem } from '../commons/Types';
import { SearchController } from '../controller/SearchController'; // 搜索控制器
import { SearchMockData } from '../data/mock/SearchMockData'; // 搜索Mock数据和类型

@ObservedV2
export class SearchVM {
  @Trace isLoading: boolean = false;
  @Trace historyList: HistorySearchItem[] = [];
  @Trace guessLikeList: string[] = [];
  @Trace hotSearchList: HotSearchItem[] = [];
  @Trace searchWords: string = '';
  @Trace suggestedKeywords: string[] = []; // 存储联想关键词
  public searchController: SearchController = SearchController.instance;
  @Trace isShowResult: boolean = false;
  @Trace searchResults: ImageInfo[] = [];
  @Trace isSearching: boolean = false;
  @Trace filteredResults: ImageInfo[] = []; // 根据标签页过滤搜索结果
  @Trace currentTab: number = 0; // 新：0:综合 1:在线 2:组件
  @Trace sortBy: string = 'hot';

  // 初始化数据方法
  async initData(): Promise<void> {
    this.isLoading = true;
    const promises = [
      this.getHistoryList(),
      this.getGuessLikeList(),
      this.getHotSearchList(),
    ];
    Promise.all(promises).then(() => {
      this.isLoading = false;
      this.searchController.generateHotSearch(this.hotSearchList);
      this.searchController.generateRecommendList(this.guessLikeList);
      this.searchController.setSearchInputUpdateCallback((searchText: string) => {
        this.searchWords = searchText;
      });
    });
  }

  // 历史记录使用mock数据
  async getHistoryList(): Promise<void> {
    this.historyList = SearchDataHelper.getInstance().getHistorys();
    this.searchController.fullHistorySearch = this.historyList.map(item => item.label);
    this.searchController.updateDisplayHistory();
  }

  // 猜你喜欢使用mock数据
  async getGuessLikeList(): Promise<void> {
    this.guessLikeList = SearchMockData.guessLikeList;
    this.searchController.generateRecommendList(this.guessLikeList);
  }

  // 热搜列表使用mock数据
  async getHotSearchList(): Promise<void> {
    this.hotSearchList = SearchMockData.hotSearchList;
    this.hotSearchList.sort((a, b) => b.hotRate - a.hotRate);
    this.searchController.generateHotSearch(this.hotSearchList);
  }

  // 历史记录搜索不重复
  async addHistoryList(value: string): Promise<void> {
    if (!value.trim()) {
      return;
    }
    const currentHistory = [...this.historyList];
    const existingIndex = currentHistory.findIndex(item => item.label === value);
    if (existingIndex >= 0) {
      currentHistory.splice(existingIndex, 1);
    }
    const newHistoryItem: HistorySearchItem = {
      label: value,
      latestSearch: Date.now()
    };
    currentHistory.unshift(newHistoryItem);
    // 限制历史记录数量为10条
    if (currentHistory.length > 10) {
      currentHistory.splice(10);
    }
    this.historyList = currentHistory;
    this.searchController.updateHistorySearch(value);
    SearchDataHelper.getInstance().update(this.historyList)
  }

  async updateHistoryList(list: HistorySearchItem[]): Promise<void> {
    this.historyList = list;
    this.searchController.fullHistorySearch = this.historyList.map(item => item.label);
    this.searchController.updateDisplayHistory();
  }

  // 搜索提交
  async submitSearch(uiContext: UIContext, callback?: Callback<string>): Promise<void> {
    if (!this.searchWords.trim()) {
      uiContext.getPromptAction().showToast({
        message: '请输入搜索内容~',
      });
      return;
    }

    // 如果已经在搜索结果页面，只刷新搜索结果，不改变页面状态
    if (this.isShowResult) {
      await this.performSearch(this.searchWords);
    } else {
      this.isShowResult = true;
      this.searchController.isShowResult = true;
      await this.performSearch(this.searchWords);
    }

    callback?.(this.searchWords);
    await this.addHistoryList(this.searchWords);
    this.suggestedKeywords = []; // 搜索提交后清空联想列表
  }

  // 搜索的方法 关键词/存在/不存在
  async performSearch(keyword: string): Promise<void> {
    this.isSearching = true;
    //
    const keywordExists: boolean = SearchMockData.hasKeyword(keyword);
    if (!keywordExists) {
      this.searchResults = [];
      this.filteredResults = [];
    } else {
      this.searchResults = SearchMockData.searchWallpapersByKeyword(keyword);
      this.filterSearchResults(this.currentTab, keyword);
    }
    this.isSearching = false;
  }

  // 根据标签页过滤结果
  filterSearchResults(tabIndex: number, keyword: string): void {
    if (tabIndex === 0) {
      const wallpaperResults = this.searchResults.filter((item: ImageInfo): boolean =>
      item.type !== '组件'
      );
      const widgetResults = this.searchResults.filter((item: ImageInfo): boolean =>
      item.type === '组件'
      );
      this.filteredResults = [...wallpaperResults, ...widgetResults];
    } else if (tabIndex === 1) {
      this.filteredResults = this.searchResults.filter((item: ImageInfo): boolean =>
      item.type !== '组件'
      );
    } else {
      this.filteredResults = this.searchResults.filter((item: ImageInfo): boolean =>
      item.type === '组件'
      );
    }
  }

  // 获取过滤后的结果
  getFilteredResultsByTab(tabIndex: number): ImageInfo[] {
    if (this.searchWords.trim() && this.isShowResult) {
      return this.filteredResults;
    }
    return [];
  }

  // 壁纸取前三个
  getWallpaperResults(): ImageInfo[] {
    const wallpapers = this.searchResults.filter((item: ImageInfo): boolean =>
    item.type !== '组件' && item.type !== '创意'
    );
    return wallpapers.slice(0, 3);
  }

  // 组件取前三个
  getWidgetResults(): ImageInfo[] {
    const widgets = this.searchResults.filter((item: ImageInfo): boolean =>
    item.type === '组件' || item.type === '创意'
    );
    return widgets.slice(0, 3);
  }

  getResultsByType(type: string): ImageInfo[] {
    return this.searchResults.filter((item: ImageInfo): boolean =>
    item.type === type
    );
  }

  // 搜索词更新
  updateSearchWords(value: string): void {
    if (value.length <= 50) {
      this.searchWords = value;
      this.searchController.updateSearchCondition(value);
      if (value.trim()) {
      } else {
        this.suggestedKeywords = []; // 清空时也清空联想
      }
      if (!value.trim()) {
        this.isShowResult = false;
        this.searchController.isShowResult = false;
        this.searchResults = [];
        this.filteredResults = [];
      }
    }
  }

  // 根据输入内容更新联想关键词
  updateSuggestedKeywords(input: string): void {
    if (!input.trim()) {
      this.suggestedKeywords = [];
      return;
    }

    // 所有可搜索的关键词中获取匹配
    const allSearchableKeywords: string[] = SearchMockData.getAllSearchableKeywords();

    // 精确匹配
    const matchedKeywords: string[] = allSearchableKeywords.filter((keyword: string): boolean => {
      return keyword.toLowerCase().includes(input.toLowerCase());
    });
    this.suggestedKeywords = matchedKeywords;
  }

  // 历史记录点击
  handleHistoryItemClick(value: string, uiContext: UIContext): void {
    this.updateSearchWords(value);
    this.submitSearch(uiContext);
  }

  // 猜你喜欢点击
  handleGuessLikeClick(value: string, uiContext: UIContext): void {
    this.updateSearchWords(value);
    this.submitSearch(uiContext);
  }

  // 热搜榜点击
  handleHotSearchClick(value: string, uiContext: UIContext): void {
    this.updateSearchWords(value);
    this.submitSearch(uiContext);
  }

  // 返回搜索首页
  backToSearchHome(): void {
    this.isShowResult = false;
    this.searchController.isShowResult = false;
    this.searchWords = '';
    this.searchController.searchCondition = '';
    this.searchResults = [];
    this.filteredResults = [];
    this.isSearching = false;
    this.currentTab = 0;
    this.suggestedKeywords = [];
  }

  // 切换收藏状态
  toggleLike(item: ImageInfo): void {
    const index: number = this.searchResults.findIndex((result: ImageInfo): boolean => result.id === item.id);
    if (index !== -1) {
      this.searchResults[index].like = !this.searchResults[index].like;
      if (this.searchResults[index].like) {
        this.searchResults[index].hotValue += 10;
      } else {
        this.searchResults[index].hotValue -= 10;
      }
    }
  }

  // 切换标签页
  switchTab(tabIndex: number): void {
    if (this.currentTab !== tabIndex) {
      this.currentTab = tabIndex;
      if (this.isShowResult && this.searchWords.trim()) {
        this.filterSearchResults(tabIndex, this.searchWords);
      }
    }
  }

  // 当前标签页的空状态数据
  getEmptyStateText(): string {
    switch (this.currentTab) {
      case 0:
        return '暂无相关壁纸和组件';
      case 1:
        return '暂无相关壁纸';
      case 2:
        return '暂无相关组件';
      default:
        return '暂无相关内容';
    }
  }

  // 是否有搜索结果
  hasSearchResults(): boolean {
    return this.searchResults.length > 0;
  }

  // 是否有壁纸结果
  hasWallpaperResults(): boolean {
    return this.getWallpaperResults().length > 0;
  }

  //是否有组件结果
  hasWidgetResults(): boolean {
    return this.getWidgetResults().length > 0;
  }

  // 清空搜索结果
  clearSearchResults(): void {
    this.searchResults = [];
    this.filteredResults = [];
    this.isSearching = false;
  }

  // 重置搜索状态
  resetSearch(): void {
    this.searchWords = '';
    this.searchController.searchCondition = '';
    this.isShowResult = false;
    this.searchController.isShowResult = false;
    this.clearSearchResults();
    this.currentTab = 0;
    this.suggestedKeywords = [];
  }
}

export interface GuessLikeParams {
  page: number;
  pageSize: number;
}

export interface CardItem {
  cardType: number,
  cards: Card[]
}

@ObservedV2
export class Card {
  @Trace id: number = 0;
  @Trace type: 'weather' | 'woodenFish' = 'weather';
  @Trace cardSize: 'small' | 'medium' | 'large' = 'small';
  @Trace data?: WeatherCardInfo | WoodenFishCardInfo;
}

@ObservedV2
export class WeatherCardInfo {
  @Trace location: string = ''
  @Trace temp: string = ''
  @Trace weather: string = ''
  @Trace backgroundColorInfo?: string = ''
  @Trace textColor?: string = ''
  @Trace futureWeatherColor?: string = ''
  @Trace highTemp: string = ''
  @Trace lowTemp: string = ''
  @Trace backgroundImg?: string = ''
  @Trace futureWeather?: FutureWeatherInfo[] = []

  constructor(params: WeatherCardParams) {
    this.location = params.location;
    this.weather = params.weather;
    this.temp = params.temp;
    this.highTemp = params.highTemp;
    this.lowTemp = params.lowTemp;
    this.futureWeather = params.futureWeather ?? [];
    this.backgroundColorInfo = params.backgroundColorInfo ?? '#fff';
    this.textColor = params.textColor ?? '#000';
    this.futureWeatherColor = params.futureWeatherColor ?? '#99000000';
    this.backgroundImg = params.backgroundImg ?? '';
  }
}

@ObservedV2
export class WoodenFishCardInfo {
  @Trace woodenFishTitle?: string = ''
  @Trace backgroundColorInfo?: string = ''
  @Trace textColor?: string = ''
  @Trace backgroundImg?: string = ''
  @Trace soundEffect?: boolean = true
  @Trace luckValue: number = 0

  constructor(params: WoodenFishCardParams) {
    this.woodenFishTitle = params.woodenFishTitle;
    this.backgroundColorInfo = params.backgroundColorInfo ?? '#fff';
    this.textColor = params.textColor ?? '#99000000';
    this.backgroundImg = params.backgroundImg ?? '';
    this.soundEffect = params.soundEffect ?? true;
    this.luckValue = params.luckValue;
  }
}

export interface FutureWeatherInfo {
  date: string;
  weather: string;
  lowTemp: string;
  highTemp: string;
}

export interface WeatherCardParams {
  location: string;
  weather: string;
  temp: string;
  highTemp: string;
  lowTemp: string;
  futureWeather?: FutureWeatherInfo[];
  backgroundColorInfo?: string; // 可选参数，有默认值
  textColor?: string; // 可选参数，有默认值
  futureWeatherColor?: string; // 可选参数，有默认值
  backgroundImg?: string; // 可选参数，有默认值
}

export interface WoodenFishCardParams {
  woodenFishTitle?: string;
  backgroundColorInfo?: string;
  textColor?: string;
  backgroundImg?: string;
  soundEffect?: boolean;
  luckValue: number;
}