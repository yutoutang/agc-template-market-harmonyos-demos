import { BaseViewModel, PreferenceUtil } from 'common'
import { PreferenceConstant } from 'job_intention'

@ObservedV2
export class VocationalSkillModel extends BaseViewModel {
  @Trace skills: Array<string> = [
    '使用现有的设计系统重新设计公司的主页和潜在客户开发表单；跳出率降低了40%，潜在客户增加了15%。',
    '设计了一个由自助服务知识库和交互式聊天机器人组成的在线客户支持中心。指导了15名暑期实习生。'
  ]

  private pref = PreferenceUtil.getInstance(undefined, 'resume')

  constructor() {
    super()
    const saved = this.pref.get(PreferenceConstant.RESUME_VOCATIONAL_SKILL)
    if (saved) { this.skills = saved as Array<string> }
  }

  setSkills(value: Array<string>) { this.skills = value; this.save() }
  addSkill(value: string) { if (value) { this.skills = [value, ...this.skills]; this.save() } }
  removeSkill(index: number) { this.skills.splice(index, 1); this.save() }

  save() { this.pref.put(PreferenceConstant.RESUME_VOCATIONAL_SKILL, this.skills) }

  private static _instance: VocationalSkillModel
  public static get instance() {
    if (!VocationalSkillModel._instance) {
      VocationalSkillModel._instance = new VocationalSkillModel()
    }
    return VocationalSkillModel._instance
  }
}