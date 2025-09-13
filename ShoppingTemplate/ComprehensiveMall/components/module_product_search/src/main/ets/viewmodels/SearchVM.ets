import { HistorySearchItem, HotSearchItem } from '../commons/Types';
import { ProductSearchApis } from '../https/Apis';

@ObservedV2
export class SearchVM {
  @Trace
  isLoading: boolean = false;
  @Trace
  historyList: HistorySearchItem[] = [];
  @Trace
  guessLikeList: string[] = [];
  @Trace
  hotSearchList: HotSearchItem[] = [];
  @Trace
  searchWords: string = '';

  async initData() {
    this.isLoading = true;
    const promises = [
      this.getHistoryList(),
      this.getGuessLikeList(),
      this.getHotSearchList(),
    ];
    Promise.all(promises).then(() => {
      this.isLoading = false;
    });
  }

  async getHistoryList() {
    this.historyList = await ProductSearchApis.getSearchHistoryList();
  }

  async getGuessLikeList() {
    this.guessLikeList = await ProductSearchApis.getGuessLikeList();
  }

  async getHotSearchList() {
    this.hotSearchList = await ProductSearchApis.getHotSearchList();
    this.hotSearchList.sort((a, b) => b.hotRate - a.hotRate);
  }

  async addHistoryList(value: string) {
    await ProductSearchApis.addSearchHistory(value);
    this.historyList = await ProductSearchApis.getSearchHistoryList();
  }

  async updateHistoryList(list: HistorySearchItem[]) {
    await ProductSearchApis.updateSearchHistoryList(list);
    this.historyList = await ProductSearchApis.getSearchHistoryList();
  }

  async submitSearch(uiContext: UIContext, callback?: Callback<string>) {
    if (!this.searchWords) {
      uiContext.getPromptAction().showToast({
        message: '请输入搜索内容~',
      });
      return;
    }
    callback?.(this.searchWords);
    await ProductSearchApis.addSearchHistory(this.searchWords);
    this.historyList = await ProductSearchApis.getSearchHistoryList();
  }

  updateSearchWords(value: string) {
    this.searchWords = value;
  }
}
