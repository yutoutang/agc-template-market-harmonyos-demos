/**
 * 自我评价数据模型
 * 管理简历的自我评价内容
 */

import { BaseViewModel, PreferenceUtil, PreferenceConstant } from 'common'

@ObservedV2
export class SelfEvaluationModel extends BaseViewModel {
  @Trace content: string = '例如：[自我评价高度概括与求职目标相关的个人优势，工作经历，项目经历，可分段填写概括，字数建议限制在600字以内]'
  private pref = PreferenceUtil.getInstance(undefined, 'resume')

  constructor() {
    super()
    const saved = this.pref.get(PreferenceConstant.RESUME_SELF_EVAL) as string | undefined
    if (saved) {
      this.content = saved
    }
  }

  setContent(value: string) {
    this.content = value;
    this.pref.put(PreferenceConstant.RESUME_SELF_EVAL, this.content)
  }

  private static _instance: SelfEvaluationModel

  public static get instance() {
    if (!SelfEvaluationModel._instance) {
      SelfEvaluationModel._instance = new SelfEvaluationModel()
    }
    return SelfEvaluationModel._instance
  }
}