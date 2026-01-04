import { HistorySearchItem } from '../commons/Types';


export class SearchDataHelper {
  private static instance: SearchDataHelper;
  private history: HistorySearchItem[] = []; // 上传记录列表

  public static getInstance(): SearchDataHelper {
    if (!SearchDataHelper.instance) {
      SearchDataHelper.instance = new SearchDataHelper();
    }
    return SearchDataHelper.instance;
  }

  public getHistorys(): HistorySearchItem[] {
    return this.history;
  }

  public update(list: HistorySearchItem[]) {
    this.history = [];
    this.history.push(...list)
  }

  public remove(index: number) {
    if (index >= 0 && index < this.history.length) {
      this.history.splice(index, 1);
    }
  }

  public clean() {
    this.history = [];
  }
}