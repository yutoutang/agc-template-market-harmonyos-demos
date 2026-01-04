/**
 * 简历主数据模型
 * 管理简历页面的全局状态,包括页面标题、预览配置、WebView控制器等
 */

import { BaseViewModel } from 'common'
import { webview } from '@kit.ArkWeb'

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
  @Trace webController: webview.WebviewController = new webview.WebviewController();
  @Trace webUrl: ResourceStr = $rawfile('export.html')
  @Trace webData: object = Object({})
  @Trace loadingState: number = 5
  @Trace h5Width: number = 0
  @Trace h5Height: number = 0

  setPageTitle(value: string) {
    this.pageTitle = value
  }

  setPreviewLabel(value: string) {
    this.previewLabel = value
  }

  setRequirements(options: ResumeRequirementsOptions) {
    if (options.selfEvaluation !== undefined) {
      this.requireSelfEvaluation = options.selfEvaluation
    }
    if (options.careerObjective !== undefined) {
      this.requireCareerObjective = options.careerObjective
    }
    if (options.educationBackground !== undefined) {
      this.requireEducationBackground = options.educationBackground
    }
  }

  setPreviewWebData(webData: object) {
    this.webData = webData
  }

  initWebData() {
    return JSON.stringify(this.webData)
  }

  private static _instance: ResumeModel

  public static get instance() {
    if (!ResumeModel._instance) {
      ResumeModel._instance = new ResumeModel()
    }
    return ResumeModel._instance
  }
}
