import { BaseViewModel, PreferenceUtil } from 'common'
import { PreferenceConstant } from 'job_intention'

export interface EducationItem {
  school: string
  major: string
  degree: string
  startDate: string
  endDate: string
}

@ObservedV2
export class EducationalBackgroundModel extends BaseViewModel {
  @Trace items: Array<EducationItem> = [
    {
      school: 'XX大学',
      major: '美术与设计学院',
      degree: '硕士',
      startDate: '2013.09',
      endDate: '2016.07',
    }
  ]

  private pref = PreferenceUtil.getInstance(undefined, 'resume')

  constructor() {
    super()
    const saved = this.pref.get(PreferenceConstant.RESUME_EDUCATION_BACKGROUND)
    if (saved) { this.items = saved as Array<EducationItem> }
  }

  setItems(value: Array<EducationItem>) { this.items = value; this.save() }
  addItem(item: EducationItem) { this.items = [item, ...this.items]; this.save() }
  updateItem(index: number, item: EducationItem) { this.items[index] = item; this.save() }
  removeItem(index: number) { this.items.splice(index, 1); this.save() }

  @Trace editingIndex: number = -1
  @Trace editingItem: EducationItem | undefined = undefined
  @Trace draft: EducationItem = {
    school: '',
    major: '',
    degree: '',
    startDate: '',
    endDate: ''
  }
  startEdit(index: number, item?: EducationItem) {
    this.editingIndex = index
    this.editingItem = item
    if (item) {
      this.draft = {
        school: item.school,
        major: item.major,
        degree: item.degree,
        startDate: item.startDate,
        endDate: item.endDate
      }
    } else {
      this.draft = {
        school: '',
        major: '',
        degree: '',
        startDate: '',
        endDate: ''
      }
    }
  }

  save() { this.pref.put(PreferenceConstant.RESUME_EDUCATION_BACKGROUND, this.items) }

  setDraftSchool(value: string) {
    this.draft = {
      school: value,
      major: this.draft.major,
      degree: this.draft.degree,
      startDate: this.draft.startDate,
      endDate: this.draft.endDate
    }
  }

  setDraftMajor(value: string) {
    this.draft = {
      school: this.draft.school,
      major: value,
      degree: this.draft.degree,
      startDate: this.draft.startDate,
      endDate: this.draft.endDate
    }
  }

  setDraftDegree(value: string) {
    this.draft = {
      school: this.draft.school,
      major: this.draft.major,
      degree: value,
      startDate: this.draft.startDate,
      endDate: this.draft.endDate
    }
  }

  setDraftStartDate(value: string) {
    this.draft = {
      school: this.draft.school,
      major: this.draft.major,
      degree: this.draft.degree,
      startDate: value,
      endDate: this.draft.endDate
    }
  }

  setDraftEndDate(value: string) {
    this.draft = {
      school: this.draft.school,
      major: this.draft.major,
      degree: this.draft.degree,
      startDate: this.draft.startDate,
      endDate: value
    }
  }

  commitDraft() {
    const item: EducationItem = {
      school: (this.draft.school || '').trim(),
      major: (this.draft.major || '').trim(),
      degree: (this.draft.degree || '').trim(),
      startDate: (this.draft.startDate || '').trim(),
      endDate: (this.draft.endDate || '').trim()
    }
    if (this.editingIndex === -1) {
      this.addItem(item)
    } else {
      this.updateItem(this.editingIndex, item)
    }
    this.editingIndex = -1
    this.editingItem = undefined
  }

  private static _instance: EducationalBackgroundModel
  public static get instance() {
    if (!EducationalBackgroundModel._instance) {
      EducationalBackgroundModel._instance = new EducationalBackgroundModel()
    }
    return EducationalBackgroundModel._instance
  }
}
