import { SearchDataHelper } from '../data/SearchDataHelper';
import { HotSearchItem } from '../commons/Types';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';

@ObservedV2
export class SearchController {
  @Trace searchCondition: string = '';
  @Trace isShowResult: boolean = false;
  @Trace hotSearch: Array<string> = []; // 热门搜索数据
  @Trace fullHistorySearch: Array<string> = []; // 完整的搜索历史
  @Trace historySearch: Array<string> = []; // 搜索历史10条
  @Trace recommendList: Array<string> = []; // 猜你喜欢
  // 搜索框更新回调
  private searchInputUpdateCallback?: (searchText: string) => void;
  private static _instance: SearchController;

  // 单例模式获取实例
  public static get instance() {
    if (!SearchController._instance) {
      SearchController._instance = new SearchController();
    }
    return SearchController._instance;
  }

  setSearchInputUpdateCallback(callback: (searchText: string) => void) {
    this.searchInputUpdateCallback = callback;
  }

  // 更新搜索条件并通知搜索框
  updateSearchCondition(searchText: string) {
    this.searchCondition = searchText;
    if (this.searchInputUpdateCallback) {
      this.searchInputUpdateCallback(searchText);
    }
  }

  // 历史搜索记录更新不重复
  updateHistorySearch(content: string) {
    if (!content.trim()) {
      return;
    }
    let index: number = this.fullHistorySearch.indexOf(content);
    if (index === -1) {
      this.fullHistorySearch.unshift(content);
    } else {
      this.fullHistorySearch.splice(index, 1);
      this.fullHistorySearch.unshift(content);
    }
    if (this.fullHistorySearch.length > 10) {
      this.fullHistorySearch.splice(10);
    }
    this.updateDisplayHistory();
  }

  // 搜索历史记录
  updateDisplayHistory() {
    this.historySearch = this.fullHistorySearch.slice(0, 10);
  }

  // 历史记录中删除
  deleteHistoryItem(index: number) {
    if (index >= 0 && index < this.fullHistorySearch.length) {
      this.fullHistorySearch.splice(index, 1);
    }
    this.updateDisplayHistory();
    SearchDataHelper.getInstance().remove(index)
  }

  // 清空所有搜索历史
  clearAllHistory() {
    this.fullHistorySearch = [];
    this.historySearch = [];
    SearchDataHelper.getInstance().clean()
  }

  // 生成热门搜索数据
  generateHotSearch(hotSearchData: HotSearchItem[]) {
    if (hotSearchData.length === 0) {
      this.hotSearch = [];
      return;
    }
    const hotSearchItems: string[] = hotSearchData.map(item => item.label);

    const shuffledItems = [...hotSearchItems].sort(() => {
      let cryptoRand = cryptoFramework.createRandom();
      let randData = cryptoRand.generateRandomSync(1);
      return randData.data[0] / 128 - 1; // 转换为 -1 到 1 之间的随机数
    });

    this.hotSearch = shuffledItems.slice(0, 10);
  }


  // 生成猜你喜欢
  generateRecommendList(guessLikeData: string[]) {
    if (guessLikeData.length === 0) {
      this.recommendList = [];
      return;
    }

    const shuffledItems = [...guessLikeData].sort(() => {
      let cryptoRand = cryptoFramework.createRandom();
      let randData = cryptoRand.generateRandomSync(1);
      return randData.data[0] / 128 - 1; // 转换为 -1 到 1 之间的随机数
    });

    this.recommendList = shuffledItems.slice(0, 9);
  }


  refreshRecommendList(guessLikeData: string[]) {
    this.generateRecommendList(guessLikeData);
  }
}