import { BaseViewModel } from 'common'

export interface ResumeRequirementsOptions {
  selfEvaluation?: boolean
  careerObjective?: boolean
  educationBackground?: boolean
}

@ObservedV2
export class ResumeModel extends BaseViewModel {
  @Trace pageTitle: string = '简历'
  @Trace previewLabel: string = '预览'
  @Trace requireSelfEvaluation: boolean = true
  @Trace requireCareerObjective: boolean = true
  @Trace requireEducationBackground: boolean = true

  setPageTitle(value: string) { this.pageTitle = value }
  setPreviewLabel(value: string) { this.previewLabel = value }
  setRequirements(options: ResumeRequirementsOptions) {
    if (options.selfEvaluation !== undefined) { this.requireSelfEvaluation = options.selfEvaluation }
    if (options.careerObjective !== undefined) { this.requireCareerObjective = options.careerObjective }
    if (options.educationBackground !== undefined) { this.requireEducationBackground = options.educationBackground }
  }

  private static _instance: ResumeModel
  public static get instance() {
    if (!ResumeModel._instance) {
      ResumeModel._instance = new ResumeModel()
    }
    return ResumeModel._instance
  }
}
