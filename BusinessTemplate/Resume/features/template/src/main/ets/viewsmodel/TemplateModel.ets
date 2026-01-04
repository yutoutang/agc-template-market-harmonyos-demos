/**
 * 模板数据模型
 * 管理简历模板的数据和状态,包括模板列表、选中模板、WebView控制器等
 * 负责准备模板预览所需的简历数据
 */

import { BaseViewModel } from 'common';
import {
  PersonalInformationModel,
  SelfEvaluationModel,
  CareerObjectiveModel,
  EducationalBackgroundModel,
  QualificationCertificateModel,
  VocationalSkillModel,
  WorkExperienceModel,
  ProjectExperienceModel,
  FilterTags
} from 'resume'
import { webview } from '@kit.ArkWeb';

export interface TemplateCard {
  name: string;
  coverColor: string;
  filterTags?: FilterTags; // 改为可选，避免其他页面报错
}

@ObservedV2
export class TemplateModel extends BaseViewModel {
  personal: PersonalInformationModel = PersonalInformationModel.instance
  selfEval: SelfEvaluationModel = SelfEvaluationModel.instance
  career: CareerObjectiveModel = CareerObjectiveModel.instance
  edu: EducationalBackgroundModel = EducationalBackgroundModel.instance
  cert: QualificationCertificateModel = QualificationCertificateModel.instance
  skill: VocationalSkillModel = VocationalSkillModel.instance
  work: WorkExperienceModel = WorkExperienceModel.instance
  project: ProjectExperienceModel = ProjectExperienceModel.instance
  @Trace webController: webview.WebviewController = new webview.WebviewController();
  @Trace templateCards: Array<TemplateCard> = [
    {
      name: '简约',
      coverColor: '#FFFFFF',
      filterTags: {
        industry: '互联网',
        position: '人力资源专员/助理',
        style: '简约'
      } as FilterTags
    } as TemplateCard,
    {
      name: '大气',
      coverColor: '#F5F7FA',
      filterTags: {
        industry: '电子商务',
        position: '行政专员/助理',
        style: '大气'
      } as FilterTags
    } as TemplateCard,
    {
      name: '简约1',
      coverColor: '#FFFFFF',
      filterTags: {
        industry: '互联网',
        position: '人力资源专员/助理',
        style: '简约'
      } as FilterTags
    } as TemplateCard,
    {
      name: '大气1',
      coverColor: '#F5F7FA',
      filterTags: {
        industry: '电子商务',
        position: '行政专员/助理',
        style: '大气'
      } as FilterTags
    } as TemplateCard,
    {
      name: '简约2',
      coverColor: '#FFFFFF',
      filterTags: {
        industry: '互联网',
        position: '人力资源专员/助理',
        style: '简约'
      } as FilterTags
    } as TemplateCard,
    {
      name: '大气2',
      coverColor: '#F5F7FA',
      filterTags: {
        industry: '电子商务',
        position: '行政专员/助理',
        style: '大气'
      } as FilterTags
    } as TemplateCard
  ]
  @Trace selectedTemplate: TemplateCard | null = null
  @Trace filteredTemplateCards: Array<TemplateCard> = []
  @Trace applied: boolean = false
  @Trace webUrl: ResourceStr = ''

  constructor() {
    super();
    this.filteredTemplateCards = this.templateCards.slice();
  }

  isUserDataReady(): boolean {
    const hasName = this.personal.data.name !== ''
    const hasSelf = this.selfEval.content !== ''
    const hasCareer = this.career.items.length > 0
    const hasEdu = this.edu.items.length > 0
    return hasName && hasSelf && hasCareer && hasEdu
  }

  initWebData(): string {
    let webData: object = Object({
      personal: this.personal.data,
      selfEval: this.selfEval.content,
      draftList: this.career.items,
      edu: this.edu.items,
      cert: this.cert.items,
      skill: this.skill.skills,
      work: this.work.items,
      project: this.project.items
    })
    return JSON.stringify(webData)
  }

  applyFilter(keyword: string) {
    const k = keyword ?? '';
    this.filteredTemplateCards = k === ''
      ? this.templateCards.slice()
      : this.templateCards.filter(item => item.name.includes(k));
  }

  applyFilterByTags(selectedTags: string[]) {
    if (!selectedTags || selectedTags.length === 0) {
      this.filteredTemplateCards = this.templateCards.slice();
      return;
    }

    // 提取所有选中的标签值（不区分分类）
    const selectedValues = new Set<string>();
    selectedTags.forEach(tag => {
      const parts = tag.split('_');
      if (parts.length === 2) {
        selectedValues.add(parts[1]); // 只保存标签值，如"电子商务"、"简约"等
      }
    });

    // 过滤模板:只要模板的任意标签匹配任意一个选中的筛选条件，就显示
    this.filteredTemplateCards = this.templateCards.filter(template => {
      // 如果模板没有 filterTags，则不匹配任何筛选条件
      if (!template.filterTags) {
        return false;
      }

      // 检查模板的任意标签是否匹配选中的筛选条件（Or逻辑）
      const templateTags: string[] = [
        template.filterTags.industry,
        template.filterTags.position,
        template.filterTags.style
      ].filter(tag => tag !== undefined && tag !== '') as string[];

      // 只要模板的任意一个标签在选中的筛选条件中，就显示该模板
      return templateTags.some(tag => selectedValues.has(tag));
    });
  }

  setApplied(flag: boolean) {
    this.applied = flag
  }

  private static _instance: TemplateModel;

  public static get instance() {
    if (!TemplateModel._instance) {
      TemplateModel._instance = new TemplateModel();
    }
    return TemplateModel._instance;
  }
}
