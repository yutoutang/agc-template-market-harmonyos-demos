import { BaseViewModel, PreferenceUtil } from 'common'
import { PreferenceConstant } from 'job_intention'

export interface PersonalInfo {
  name: string
  age: string
  gender: string
  workStartDate: string
  phone: string
  email: string
  avatarUrl: ResourceStr
}

@ObservedV2
export class PersonalInformationModel extends BaseViewModel {
  @Trace data: PersonalInfo = {
    name: '李狗蛋',
    age: '20岁',
    gender: '男',
    workStartDate: '2020.12',
    phone: '777****9999',
    email: '1304****1111@163.com',
    avatarUrl: $r('app.media.cuteDog')
  }
  private pref = PreferenceUtil.getInstance(undefined, 'resume')

  constructor() {
    super()
    const saved = this.pref.get(PreferenceConstant.RESUME_PERSONAL_INFO)
    if (saved) {
      this.data = saved as PersonalInfo
    }
  }

  setName(value: string) {
    this.data = {
      name: value,
      age: this.data.age,
      gender: this.data.gender,
      workStartDate: this.data.workStartDate,
      phone: this.data.phone,
      email: this.data.email,
      avatarUrl: this.data.avatarUrl,
    }
    this.save()
  }

  setAge(value: string) {
    this.data = {
      name: this.data.name,
      age: value,
      gender: this.data.gender,
      workStartDate: this.data.workStartDate,
      phone: this.data.phone,
      email: this.data.email,
      avatarUrl: this.data.avatarUrl,
    }
    this.save()
  }

  setGender(value: string) {
    this.data = {
      name: this.data.name,
      age: this.data.age,
      gender: value,
      workStartDate: this.data.workStartDate,
      phone: this.data.phone,
      email: this.data.email,
      avatarUrl: this.data.avatarUrl,
    }
    this.save()
  }

  setWorkStartDate(value: string) {
    this.data = {
      name: this.data.name,
      age: this.data.age,
      gender: this.data.gender,
      workStartDate: value,
      phone: this.data.phone,
      email: this.data.email,
      avatarUrl: this.data.avatarUrl,
    }
    this.save()
  }

  setPhone(value: string) {
    this.data = {
      name: this.data.name,
      age: this.data.age,
      gender: this.data.gender,
      workStartDate: this.data.workStartDate,
      phone: value,
      email: this.data.email,
      avatarUrl: this.data.avatarUrl,
    }
    this.save()
  }

  setEmail(value: string) {
    this.data = {
      name: this.data.name,
      age: this.data.age,
      gender: this.data.gender,
      workStartDate: this.data.workStartDate,
      phone: this.data.phone,
      email: value,
      avatarUrl: this.data.avatarUrl,
    }
    this.save()
  }

  setAvatar(url: ResourceStr) {
    this.data = {
      name: this.data.name,
      age: this.data.age,
      gender: this.data.gender,
      workStartDate: this.data.workStartDate,
      phone: this.data.phone,
      email: this.data.email,
      avatarUrl: url,
    }
    this.save()
  }

  save() {
    this.pref.put(PreferenceConstant.RESUME_PERSONAL_INFO, this.data)
  }

  private static _instance: PersonalInformationModel

  public static get instance() {
    if (!PersonalInformationModel._instance) {
      PersonalInformationModel._instance = new PersonalInformationModel()
    }
    return PersonalInformationModel._instance
  }
}
