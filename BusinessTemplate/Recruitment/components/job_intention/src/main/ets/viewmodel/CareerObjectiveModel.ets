import { PreferenceUtil } from '../util/PreferenceUtil'
import { PreferenceConstant } from '../constant/PreferenceConstant'

export interface CareerObjectiveItem {
  jobType: string // 工作性质
  position: string // 意向职位
  city: string // 工作城市
  industry: string // 行业类型
  salary: string // 期望薪资
  jobStatus: string // 求职状态
}

@ObservedV2
export class CareerObjectiveModel {
  @Trace jobStatus: string = ''
  @Trace items: Array<CareerObjectiveItem> = []
  @Trace editingIndex: number = -1
  @Trace editingItem: CareerObjectiveItem | undefined = undefined
  @Trace draft: CareerObjectiveItem = {
    jobType: '',
    position: '',
    city: '',
    industry: '',
    salary: '',
    jobStatus: ''
  }
  private pref = PreferenceUtil.getInstance(undefined, 'resume')

  constructor() {
    const saved = this.pref.get(PreferenceConstant.RESUME_CAREER_OBJECTIVE)
    if (saved) {
      if (Array.isArray(saved)) {
        this.items = saved as Array<CareerObjectiveItem>
      } else {
        // 兼容旧数据格式
        const data = saved as CareerObjectiveItem
        if (data.position || data.city || data.industry || data.salary) {
          this.items = [data]
        }
      }
    }
  }

  startEdit(index: number, item?: CareerObjectiveItem) {
    this.editingIndex = index
    this.editingItem = item
    if (item) {
      this.draft = {
        jobType: item.jobType || '',
        position: item.position,
        city: item.city,
        industry: item.industry,
        salary: item.salary,
        jobStatus: item.jobStatus || ''
      }
    } else {
      this.draft = {
        jobType: '全职',
        position: '',
        city: '',
        industry: '',
        salary: '',
        jobStatus: ''
      }
    }
  }

  setDraftJobType(value: string) {
    this.draft = {
      jobType: value,
      position: this.draft.position,
      city: this.draft.city,
      industry: this.draft.industry,
      salary: this.draft.salary,
      jobStatus: this.draft.jobStatus
    }
  }

  setDraftPosition(value: string) {
    this.draft = {
      jobType: this.draft.jobType,
      position: value,
      city: this.draft.city,
      industry: this.draft.industry,
      salary: this.draft.salary,
      jobStatus: this.draft.jobStatus
    }
  }

  setDraftCity(value: string) {
    this.draft = {
      jobType: this.draft.jobType,
      position: this.draft.position,
      city: value,
      industry: this.draft.industry,
      salary: this.draft.salary,
      jobStatus: this.draft.jobStatus
    }
  }

  setDraftIndustry(value: string) {
    this.draft = {
      jobType: this.draft.jobType,
      position: this.draft.position,
      city: this.draft.city,
      industry: value,
      salary: this.draft.salary,
      jobStatus: this.draft.jobStatus
    }
  }

  setDraftSalary(value: string) {
    this.draft = {
      jobType: this.draft.jobType,
      position: this.draft.position,
      city: this.draft.city,
      industry: this.draft.industry,
      salary: value,
      jobStatus: this.draft.jobStatus
    }
  }

  setDraftJobStatus(value: string) {
    this.draft = {
      jobType: this.draft.jobType,
      position: this.draft.position,
      city: this.draft.city,
      industry: this.draft.industry,
      salary: this.draft.salary,
      jobStatus: value
    }
  }

  saveDraft() {
    const item: CareerObjectiveItem = {
      jobType: (this.draft.jobType || '').trim(),
      position: (this.draft.position || '').trim(),
      city: (this.draft.city || '').trim(),
      industry: (this.draft.industry || '').trim(),
      salary: (this.draft.salary || '').trim(),
      jobStatus: (this.draft.jobStatus || '').trim()
    }
    if (this.editingIndex === -1) {
      this.addItem(item)
    } else {
      this.updateItem(this.editingIndex, item)
    }
    this.editingIndex = -1
    this.editingItem = undefined
  }

  addItem(item: CareerObjectiveItem) {
    this.items.push(item)
    this.save()
  }

  updateItem(index: number, item: CareerObjectiveItem) {
    if (index >= 0 && index < this.items.length) {
      this.items[index] = item
      this.save()
    }
  }

  deleteItem(index: number) {
    if (index >= 0 && index < this.items.length) {
      this.items.splice(index, 1)
      this.save()
    }
  }

  save() {
    this.pref.put(PreferenceConstant.RESUME_CAREER_OBJECTIVE, this.items)
  }

  private static _instance: CareerObjectiveModel

  public static get instance() {
    if (!CareerObjectiveModel._instance) {
      CareerObjectiveModel._instance = new CareerObjectiveModel()
    }
    return CareerObjectiveModel._instance
  }
}