/**
 * 搜索数据模型
 * 管理模板搜索的状态,包括搜索条件、搜索结果、搜索历史等
 */

import { TemplateModel, TemplateCard } from './TemplateModel'
import { PreferenceUtil, PreferenceConstant } from 'common'

@ObservedV2
export class TemplateClassification {
  /**
   * 模板名称
   */
  templateName: string | Resource

  constructor(templateName: string | Resource) {
    this.templateName = templateName
  }
}

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
  @Trace searchResult: TemplateClassification = new TemplateClassification('');
  @Trace isShowResult: boolean = false;
  @Trace historySearch: Array<string> = ['简约','大气','2'];
  @Trace suggestions: Array<TemplateCard> = [];
  @Trace resultList: Array<TemplateCard> = [];
  private pref = PreferenceUtil.getInstance(undefined, 'template')

  constructor() {
    this.loadSearchHistory()
  }

  private loadSearchHistory() {
    const saved = this.pref.get(PreferenceConstant.TEMPLATE_SEARCH_HISTORY) as Array<string> | undefined
    if (saved && Array.isArray(saved)) {
      this.historySearch = saved
    }
  }

  private saveSearchHistory() {
    this.pref.put(PreferenceConstant.TEMPLATE_SEARCH_HISTORY, this.historySearch)
  }

  private getAllTemplates(): Array<TemplateCard> {
    // 搜索基于筛选结果:如果有筛选条件，则在筛选结果中搜索；否则在全量数据中搜索
    const filtered = TemplateModel.instance.filteredTemplateCards;
    const all = TemplateModel.instance.templateCards;
    // 如果筛选后的数据与全量数据长度不同，说明用户应用了筛选，搜索应该在筛选结果中进行
    return filtered.length !== all.length ? filtered : all;
  }

  updateSuggestions(keyword: string) {
    const all = this.getAllTemplates();
    const k = keyword || '';
    this.suggestions = k === '' ? [] : all.filter(item => item.name.includes(k));
  }

  search() {
    const all = this.getAllTemplates();
    const k = this.searchCondition || '';
    // 如果搜索关键词为空，返回当前筛选结果（如果有筛选）或空数组
    if (k === '') {
      this.resultList = [];
    } else {
      this.resultList = all.filter(item => item.name.includes(k));
    }
    this.isShowResult = true;
    // 将搜索结果同步到 TemplateModel，以便模板列表页面显示搜索结果
    // 只有搜索有结果时才更新 filteredTemplateCards，避免搜索无结果时显示空白
    if (this.resultList.length > 0) {
      TemplateModel.instance.filteredTemplateCards = this.resultList.slice();
    }
    // 如果搜索无结果，保持之前的筛选状态不变
  }

  searchFromSuggestion(name: string) {
    this.searchCondition = name;
    this.updateHistorySearch(name);
    this.search();
  }

  updateHistorySearch(content: string) {
    let index: number = this.historySearch.indexOf(content);
    if (index === -1) {
      this.historySearch.unshift(content);
    } else {
      this.historySearch.splice(index, 1);
      this.historySearch.unshift(content);
    }
    this.saveSearchHistory();
  }

  deleteHistoryItem(index: number) {
    if (index >= 0 && index < this.historySearch.length) {
      this.historySearch.splice(index, 1)
      this.saveSearchHistory()
    }
  }

  clearAllHistory() {
    this.historySearch = []
    this.saveSearchHistory()
  }
}