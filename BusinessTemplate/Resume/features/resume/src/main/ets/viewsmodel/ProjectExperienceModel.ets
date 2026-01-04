/**
 * 项目经验数据模型
 * 管理简历的项目经验信息,包括项目名称、担任角色、项目时间、项目描述等
 */

import { BaseViewModel, PreferenceUtil, PreferenceConstant } from 'common'

export interface ProjectItem {
  name: string
  role: string
  startDate: string
  endDate: string
  description: string
}

@ObservedV2
export class ProjectExperienceModel extends BaseViewModel {
  @Trace items: Array<ProjectItem> = []
  @Trace editingIndex: number = -1
  @Trace editingItem: ProjectItem | undefined = undefined
  @Trace draft: ProjectItem = {
    name: '',
    role: '',
    startDate: '2',
    endDate: '',
    description: ''
  }

  startEdit(index: number, item?: ProjectItem) {
    this.editingIndex = index
    this.editingItem = item
    if (item) {
      this.draft = {
        name: item.name,
        role: item.role,
        startDate: item.startDate,
        endDate: item.endDate,
        description: item.description
      }
    } else {
      this.draft = {
        name: '',
        role: '',
        startDate: '',
        endDate: '',
        description: ''
      }
    }
  }

  private pref = PreferenceUtil.getInstance(undefined, 'resume')

  constructor() {
    super()
    const saved = this.pref.get(PreferenceConstant.RESUME_PROJECT_EXPERIENCE) as Array<ProjectItem> | undefined
    if (saved) {
      this.items = saved
    } else {
      this.items = [{
        name: '项目名称',
        role: '担任角色',
        startDate: '2024.06',
        endDate: '至今',
        description: '例如：组织/领导/参与/协助团队/独立完成+具体的工作（数据分析/报告撰写/活动策划/新媒体运营）+利用XX工具+查阅...'
      }]
    }
  }

  setItems(value: Array<ProjectItem>) {
    this.items = value;
    this.save()
  }

  addItem(item: ProjectItem) {
    this.items = [item, ...this.items];
    this.save()
  }

  updateItem(index: number, item: ProjectItem) {
    const next = [...this.items]
    next[index] = item
    this.items = next
    this.save()
  }

  removeItem(index: number) {
    const next = this.items.filter((_it, i) => i !== index)
    this.items = next
    this.save()
  }

  save() {
    this.pref.put(PreferenceConstant.RESUME_PROJECT_EXPERIENCE, this.items)
  }

  setDraftName(value: string) {
    this.draft = {
      name: value,
      role: this.draft.role,
      startDate: this.draft.startDate,
      endDate: this.draft.endDate,
      description: this.draft.description
    }
  }

  setDraftRole(value: string) {
    this.draft = {
      name: this.draft.name,
      role: value,
      startDate: this.draft.startDate,
      endDate: this.draft.endDate,
      description: this.draft.description
    }
  }

  setDraftStartDate(value: string) {
    this.draft = {
      name: this.draft.name,
      role: this.draft.role,
      startDate: value,
      endDate: this.draft.endDate,
      description: this.draft.description
    }
  }

  setDraftEndDate(value: string) {
    this.draft = {
      name: this.draft.name,
      role: this.draft.role,
      startDate: this.draft.startDate,
      endDate: value,
      description: this.draft.description
    }
  }

  setDraftDescription(value: string) {
    this.draft = {
      name: this.draft.name,
      role: this.draft.role,
      startDate: this.draft.startDate,
      endDate: this.draft.endDate,
      description: value
    }
  }

  commitDraft() {
    const item: ProjectItem = {
      name: (this.draft.name || '').trim(),
      role: (this.draft.role || '').trim(),
      startDate: (this.draft.startDate || '').trim(),
      endDate: (this.draft.endDate || '').trim(),
      description: (this.draft.description || '').trim()
    }
    if (this.editingIndex === -1) {
      this.addItem(item)
    } else {
      this.updateItem(this.editingIndex, item)
    }
    this.editingIndex = -1
    this.editingItem = undefined
  }

  // 项目角色选择配置数据
  getRoleCategories(): string[] {
    return ['产品', '设计', '开发', '测试', '运维/其他', '其他角色']
  }

  getRoleSubItems(): Record<string, string[]> {
    return {
      '产品': ['项目经理', '产品经理', '产品助理', '需求分析师'],
      '设计': ['UI设计师', 'UX设计师', '交互设计师', '视觉设计师'],
      '开发': ['前端开发', '后端开发', '全栈开发', '移动端开发', '鸿蒙开发', '架构师', '技术负责人'],
      '测试': ['测试工程师', '自动化测试', '测试负责人'],
      '运维/其他': ['运维工程师', 'DBA', 'Scrum Master', '文档工程师'],
      '其他角色': ['自由职业']
    }
  }

  getRoleGroupMapping(): Record<string, string[]> {
    return {
      '产品': ['产品'],
      '设计': ['设计'],
      '开发': ['开发'],
      '测试': ['测试'],
      '运维/其他': ['运维/其他'],
      '其他角色': ['其他角色']
    }
  }

  private static _instance: ProjectExperienceModel

  public static get instance() {
    if (!ProjectExperienceModel._instance) {
      ProjectExperienceModel._instance = new ProjectExperienceModel()
    }
    return ProjectExperienceModel._instance
  }
}
