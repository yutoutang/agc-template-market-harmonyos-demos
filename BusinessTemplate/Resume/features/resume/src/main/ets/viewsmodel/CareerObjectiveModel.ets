/**
 * 求职意向数据模型
 * 管理简历的求职意向信息,包括期望职位、期望城市、期望行业、期望薪资等
 */

import { BaseViewModel, PreferenceConstant, PreferenceUtil } from 'common'

export interface CareerObjectiveItem {
  position: string // 意向职位
  city: string // 工作城市
  industry: string // 行业类型
  salary: string // 期望薪资
}

@ObservedV2
export class CareerObjectiveModel extends BaseViewModel {
  @Trace items: Array<CareerObjectiveItem> = []
  @Trace editingIndex: number = -1
  @Trace editingItem: CareerObjectiveItem | undefined = undefined
  @Trace draft: CareerObjectiveItem = {
    position: '',
    city: '',
    industry: '',
    salary: ''
  }
  private pref = PreferenceUtil.getInstance(undefined, 'resume')

  constructor() {
    super()
    const saved =
      this.pref.get(PreferenceConstant.RESUME_CAREER_OBJECTIVE) as Array<CareerObjectiveItem> |
      CareerObjectiveItem | undefined
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
    } else {
      this.items = [{
        position: '意向职位',
        city: '意向城市',
        industry: '互联网服务',
        salary: '15-20K'
      }]
    }
  }

  startEdit(index: number, item?: CareerObjectiveItem) {
    this.editingIndex = index
    this.editingItem = item
    if (item) {
      this.draft = {
        position: item.position,
        city: item.city,
        industry: item.industry,
        salary: item.salary
      }
    } else {
      this.draft = {
        position: '',
        city: '',
        industry: '',
        salary: ''
      }
    }
  }

  setDraftPosition(value: string) {
    this.draft = {
      position: value,
      city: this.draft.city,
      industry: this.draft.industry,
      salary: this.draft.salary
    }
  }

  setDraftCity(value: string) {
    this.draft = {
      position: this.draft.position,
      city: value,
      industry: this.draft.industry,
      salary: this.draft.salary
    }
  }

  setDraftIndustry(value: string) {
    this.draft = {
      position: this.draft.position,
      city: this.draft.city,
      industry: value,
      salary: this.draft.salary
    }
  }

  setDraftSalary(value: string) {
    this.draft = {
      position: this.draft.position,
      city: this.draft.city,
      industry: this.draft.industry,
      salary: value
    }
  }

  saveDraft() {
    const item: CareerObjectiveItem = {
      position: (this.draft.position || '').trim(),
      city: (this.draft.city || '').trim(),
      industry: (this.draft.industry || '').trim(),
      salary: (this.draft.salary || '').trim()
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
    this.items = [...this.items, item]
    this.save()
  }

  updateItem(index: number, item: CareerObjectiveItem) {
    if (index >= 0 && index < this.items.length) {
      const next = [...this.items]
      next[index] = item
      this.items = next
      this.save()
    }
  }

  deleteItem(index: number) {
    if (index >= 0 && index < this.items.length) {
      const next = this.items.filter((_it, i) => i !== index)
      this.items = next
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