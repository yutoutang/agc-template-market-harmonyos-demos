/**
 * 基本信息数据模型
 * 管理简历的个人基本信息数据,包括姓名、手机号、邮箱、头像等
 */

import { BaseViewModel, PreferenceUtil, PreferenceConstant } from 'common'

export interface PersonalInfo {
  name: string
  phone: string
  email: string
  avatarUrl: ResourceStr
  avatarUrlBase64?: string
}

@ObservedV2
export class PersonalInformationModel extends BaseViewModel {
  @Trace data: PersonalInfo = {
    name: '',
    phone: '',
    email: '',
    avatarUrl: $r('app.media.ic_defaultAvatar'),
    avatarUrlBase64: ''
  }
  private pref = PreferenceUtil.getInstance(undefined, 'resume')

  constructor() {
    super()
    const saved = this.pref.get(PreferenceConstant.RESUME_PERSONAL_INFO) as PersonalInfo | undefined
    if (saved) {
      this.data = saved
    }
  }

  setName(value: string) {
    this.data = {
      name: value,
      phone: this.data.phone,
      email: this.data.email,
      avatarUrl: this.data.avatarUrl,
      avatarUrlBase64: this.data.avatarUrlBase64
    }
    this.save()
  }

  setPhone(value: string) {
    this.data = {
      name: this.data.name,
      phone: value,
      email: this.data.email,
      avatarUrl: this.data.avatarUrl,
      avatarUrlBase64: this.data.avatarUrlBase64
    }
    this.save()
  }

  setEmail(value: string) {
    this.data = {
      name: this.data.name,
      phone: this.data.phone,
      email: value,
      avatarUrl: this.data.avatarUrl,
      avatarUrlBase64: this.data.avatarUrlBase64
    }
    this.save()
  }

  setAvatar(url: ResourceStr) {
    this.data = {
      name: this.data.name,
      phone: this.data.phone,
      email: this.data.email,
      avatarUrl: url,
      avatarUrlBase64: this.data.avatarUrlBase64
    }
    this.save()
  }

  setAvatarBuffer(url: string) {
    this.data = {
      name: this.data.name,
      phone: this.data.phone,
      email: this.data.email,
      avatarUrl: this.data.avatarUrl,
      avatarUrlBase64: url
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
