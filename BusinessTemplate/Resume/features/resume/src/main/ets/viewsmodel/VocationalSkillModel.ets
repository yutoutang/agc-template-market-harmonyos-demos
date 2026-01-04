/**
 * 职业技能数据模型
 * 管理简历的职业技能列表
 */

import { BaseViewModel, PreferenceUtil, PreferenceConstant } from 'common'

@ObservedV2
export class VocationalSkillModel extends BaseViewModel {
  @Trace skills: Array<string> = [
    '例如：一名具备 [X年] 经验、结果导向的 [你的职位，如：市场专员]。精通 [技能一，如：数据分析与市场调研]、[技能...]'
  ]
  private pref = PreferenceUtil.getInstance(undefined, 'resume')

  constructor() {
    super()
    const saved = this.pref.get(PreferenceConstant.RESUME_VOCATIONAL_SKILL) as Array<string> | undefined
    if (saved) {
      this.skills = saved
    }
  }

  setSkills(value: Array<string>) {
    this.skills = value;
    this.save()
  }

  addSkill(value: string) {
    if (value) {
      this.skills = [value, ...this.skills];
      this.save()
    }
  }

  removeSkill(index: number) {
    this.skills.splice(index, 1);
    this.save()
  }

  save() {
    this.pref.put(PreferenceConstant.RESUME_VOCATIONAL_SKILL, this.skills)
  }

  private static _instance: VocationalSkillModel

  public static get instance() {
    if (!VocationalSkillModel._instance) {
      VocationalSkillModel._instance = new VocationalSkillModel()
    }
    return VocationalSkillModel._instance
  }
}