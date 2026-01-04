import { BaseViewModel, PreferenceUtil } from 'common'
import { PreferenceConstant } from 'job_intention'

export interface WorkItem {
  company: string
  position: string
  industry: string
  startDate: string
  endDate: string
  description: string
}

@ObservedV2
export class WorkExperienceModel extends BaseViewModel {
  @Trace items: Array<WorkItem> = [
    {
      company: 'XX科技公司',
      position: 'C++',
      industry: '互联网',
      startDate: '2020.09',
      endDate: '2023.09',
      description: '重新设计网站流程和导航菜单'
    },
    {
      company: 'XX有限公司',
      position: 'C',
      industry: '软件开发',
      startDate: '2023.09',
      endDate: '至今',
      description: '开发软件服务'
    }
  ]
  @Trace editingItem: WorkItem | undefined = undefined
  @Trace editingIndex: number = -1
  @Trace draft: WorkItem = {
    company: '',
    position: '',
    industry: '',
    startDate: '',
    endDate: '',
    description: ''
  }

  startEdit(index: number, item?: WorkItem) {
    this.editingItem = item
    this.editingIndex = index
    if (item) {
      this.draft = {
        company: item.company,
        position: item.position,
        industry: item.industry,
        startDate: item.startDate,
        endDate: item.endDate,
        description: item.description
      }
    } else {
      this.draft = {
        company: '',
        position: '',
        industry: '',
        startDate: '',
        endDate: '',
        description: ''
      }
    }
  }

  private pref = PreferenceUtil.getInstance(undefined, 'resume')

  constructor() {
    super()
    const saved = this.pref.get(PreferenceConstant.RESUME_WORK_EXPERIENCE)
    if (saved) {
      this.items = saved as Array<WorkItem>
    }
  }

  setItems(value: Array<WorkItem>) {
    this.items = value;
    this.save()
  }

  addItem(item: WorkItem) {
    this.items = [item, ...this.items];
    this.save()
  }

  updateItem(index: number, item: WorkItem) {
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

  setDraftCompany(value: string) {
    this.draft = {
      company: value,
      position: this.draft.position,
      industry: this.draft.industry,
      startDate: this.draft.startDate,
      endDate: this.draft.endDate,
      description: this.draft.description
    }
  }

  setDraftPosition(value: string) {
    this.draft = {
      company: this.draft.company,
      position: value,
      industry: this.draft.industry,
      startDate: this.draft.startDate,
      endDate: this.draft.endDate,
      description: this.draft.description
    }
  }

  setDraftIndustry(value: string) {
    this.draft = {
      company: this.draft.company,
      position: this.draft.position,
      industry: value,
      startDate: this.draft.startDate,
      endDate: this.draft.endDate,
      description: this.draft.description
    }
  }

  setDraftStartDate(value: string) {
    this.draft = {
      company: this.draft.company,
      position: this.draft.position,
      industry: this.draft.industry,
      startDate: value,
      endDate: this.draft.endDate,
      description: this.draft.description
    }
  }

  setDraftEndDate(value: string) {
    this.draft = {
      company: this.draft.company,
      position: this.draft.position,
      industry: this.draft.industry,
      startDate: this.draft.startDate,
      endDate: value,
      description: this.draft.description
    }
  }

  setDraftDescription(value: string) {
    this.draft = {
      company: this.draft.company,
      position: this.draft.position,
      industry: this.draft.industry,
      startDate: this.draft.startDate,
      endDate: this.draft.endDate,
      description: value
    }
  }

  commitDraft() {
    const item: WorkItem = {
      company: (this.draft.company || '').trim(),
      position: (this.draft.position || '').trim(),
      industry: (this.draft.industry || '').trim(),
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

  save() {
    this.pref.put(PreferenceConstant.RESUME_WORK_EXPERIENCE, this.items)
  }

  // 职位类别
  getPositionCategories(): string[] {
    return ['互联网/AI', '电子/电气/通信', '产品', '其他职位']
  }

  getPositionSubItems(): Record<string, string[]> {
    return {
      '后端开发': ['Java', 'C/C++', '语音/视频/图形开发', 'C#'],
      '前端/移动开发': ['前端开发工程师', 'iOS', '鸿蒙开发工程师'],
      '测试': ['测试工程师', '软件测试', '自动化测试', '功能测试', '硬件测试'],
      '运维/技术支持': ['运维工程师', 'IT技术支持', '网络工程师', '网络安全'],
      '电子/电气/通信': ['电子工程师', '电气工程师', '通信工程师'],
      '产品': ['产品经理', '产品助理'],
      '其他职位': ['行政', '人事', '财务']
    }
  }

  getPositionGroupMapping(): Record<string, string[]> {
    return {
      '互联网/AI': ['后端开发', '前端/移动开发', '测试', '运维/技术支持'],
      '电子/电气/通信': ['电子/电气/通信'],
      '产品': ['产品'],
      '其他职位': ['其他职位']
    }
  }

  private static _instance: WorkExperienceModel

  public static get instance() {
    if (!WorkExperienceModel._instance) {
      WorkExperienceModel._instance = new WorkExperienceModel()
    }
    return WorkExperienceModel._instance
  }
}
