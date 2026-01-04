import { ExamManager } from '../viewmodel/QuestionAnswerRecord';

@ObservedV2
export class SearchController {
  private static _instance: SearchController;

  public static get instance() {
    if (!SearchController._instance) {
      SearchController._instance = new SearchController();
    }
    return SearchController._instance;
  }

  @Trace searchCondition: string = '';
  @Trace searchResult: ExamManager = new ExamManager('', []);
  @Trace isShowResult: boolean = false;
  // 热门搜索
  @Trace hotSearch: Array<string> = ['驾驶', '机动车', '车辆安全技术', '学校', '注意', '检查', '牵引挂车', '随身携带'];
  // 搜索历史
  @Trace historySearch: Array<string> = [];

  updateHistorySearch(content: string){
    let index: number = this.historySearch.indexOf(content);
    if (index === -1) {
      this.historySearch.unshift(content);
      return;
    }
    this.historySearch.splice(index, 1);
    this.historySearch.unshift(content);
    return;
  }
}