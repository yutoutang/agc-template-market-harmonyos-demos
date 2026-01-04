import { BaseViewModel, PreferenceUtil } from 'common'
import { PreferenceConstant } from 'job_intention'

@ObservedV2
export class SelfEvaluationModel extends BaseViewModel {
  @Trace content: string = '善思好学，用于创新，敢于争先。'
  private pref = PreferenceUtil.getInstance(undefined, 'resume')

  constructor() {
    super()
    const saved = this.pref.get(PreferenceConstant.RESUME_SELF_EVAL)
    if (saved) {
      this.content = saved as string
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