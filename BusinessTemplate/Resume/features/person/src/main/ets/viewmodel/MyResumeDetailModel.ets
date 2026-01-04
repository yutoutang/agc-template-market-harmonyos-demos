import { BaseViewModel } from 'common';
import { ResumeItem, ResumeSnapshot, ResumeSnapshotUtil } from 'resume';
import { webview } from '@kit.ArkWeb';

@ObservedV2
export class MyResumeDetailPageVM extends BaseViewModel {
  @Trace resumeName: string = '我的简历'
  @Trace webUrl: ResourceStr = ''
  @Trace resumeId: string = ''
  @Trace snapshot: ResumeSnapshot | null = null
  @Trace webData: object = Object({})
  @Trace webController: webview.WebviewController = new webview.WebviewController();
  @Trace loadingState: number = 5
  @Trace h5Width: number = 0
  @Trace h5Height: number = 0

  constructor() {
    super();
  }


  // 加载简历快照数据
  loadResumeSnapshot(): void {
    const allResumes: Array<ResumeItem> = ResumeSnapshotUtil.getAllResumes()
    const targetResume = allResumes.find((item: ResumeItem): boolean => item.id === this.resumeId)
    if (targetResume) {
      this.snapshot = targetResume.snapshot ?? null
      if (this.snapshot) {
        this.webData = Object({
          personal: this.snapshot.personalInfo,
          selfEval: this.snapshot.selfEvaluation.content,
          draftList: this.snapshot.careerObjective,
          edu: this.snapshot.educationalBackground,
          cert: this.snapshot.qualificationCertificate,
          skill: this.snapshot.vocationalSkill ? [this.snapshot.vocationalSkill.skills] : [],
          work: this.snapshot.workExperience,
          project: this.snapshot.projectExperience
        })
      }

    }
  }

  initWebData(): string {
    return JSON.stringify(this.webData)
  }


  private static _instance: MyResumeDetailPageVM;

  public static get instance() {
    if (!MyResumeDetailPageVM._instance) {
      MyResumeDetailPageVM._instance = new MyResumeDetailPageVM();
    }
    return MyResumeDetailPageVM._instance;
  }
}
export interface MyResumeRouterParams {
  type: string
}