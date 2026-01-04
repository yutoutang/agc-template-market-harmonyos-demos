@ObservedV2
export class SearchHistory {
  @Trace historyList: string[] = [];

  clear() {
    throw new Error('Method not implemented.');
  }

  add(keyword: string) {
    throw new Error('Method not implemented.');
  }
}