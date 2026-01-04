import { BarVM, CommonHeader, RouterMap, UserInfo } from 'common'
import { ResumeModel } from '../viewsmodel/ResumeModel'
import { PersonalInformationModel } from '../viewsmodel/BasicalInformationModel'
import { PersonalInformationPageBuilder } from './BasicalInformationPage'
import { EducationalBackgroundPageBuilder } from './EducationalBackgroundPage'
import { WorkExperiencePageBuilder } from './WorkExperiencePage'
import { ProjectExperiencePageBuilder } from './ProjectExperiencePage'
import { QualificationCertificatePageBuilder } from './QualificationCertificatePage'
import { TextEditingBuilder, TextEditingContext } from '../comp/TextDescriptionEditing'
import { SelfEvaluationModel } from '../viewsmodel/SelfEvaluationModel'
import { EducationalBackgroundModel, EducationItem } from '../viewsmodel/EducationalBackgroundModel'
import { VocationalSkillModel } from '../viewsmodel/VocationalSkillModel'
import { CertificateItem, QualificationCertificateModel } from '../viewsmodel/QualificationCertificateModel'
import { WorkExperienceModel, WorkItem } from '../viewsmodel/WorkExperienceModel'
import { ProjectExperienceModel, ProjectItem } from '../viewsmodel/ProjectExperienceModel'
import { PersistenceV2 } from '@kit.ArkUI'
import { phoneRouterControl } from 'oh_router'
import { GrayText } from '../comp/GrayText'
import { ResumeDivider } from '../comp/ResumeDivider'
import { ExperienceCard } from '../comp/ExperienceCard'
import { EducationCard } from '../comp/EducationCard'
import { CareerObjectiveItem, CareerObjectiveModel, CareerObjectivePageBuilder, GlobalContext } from 'job_intention'
import { ResumePreviewPageBuilder } from './ResumePreviewPage'
import { common } from '@kit.AbilityKit'

export interface ResumeTimelineItem {
  title: string
  role: string
  startDate: string
  endDate: string
  description: string
}

@Builder
export function ResumePageBuilder() {
  ResumePage()
}

@Entry
@ComponentV2
export struct ResumePage {
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local resumeVM: ResumeModel = ResumeModel.instance
  @Local personal: PersonalInformationModel = PersonalInformationModel.instance
  @Local selfEval: SelfEvaluationModel = SelfEvaluationModel.instance
  @Local career: CareerObjectiveModel | undefined = undefined
  @Local edu: EducationalBackgroundModel = EducationalBackgroundModel.instance
  @Local skill: VocationalSkillModel = VocationalSkillModel.instance
  @Local cert: QualificationCertificateModel = QualificationCertificateModel.instance
  @Local work: WorkExperienceModel = WorkExperienceModel.instance
  @Local project: ProjectExperienceModel = ProjectExperienceModel.instance
  @Local forceUpdate: number = 0
  @Local years: number = 0
  private abilityContext: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  private get firstCareer(): CareerObjectiveItem | undefined {
    return this.career!.items.length > 0 ? (this.career!.items[0] as CareerObjectiveItem) : undefined
  }

  async aboutToAppear() {
    await GlobalContext.initUIAbilityContext(this.abilityContext);
    this.career = CareerObjectiveModel.instance
    // 初始化时加载数据
    this.loadAllData()
  }

  onPageShow(): void {
    // 页面显示时强制刷新所有Model数据
    this.loadAllData()
  }

  private loadAllData(): void {
    // 重新赋值Model实例，强制建立响应式连接
    this.cert = QualificationCertificateModel.instance
    this.cert.reload() // 重新加载证书数据
    this.career = CareerObjectiveModel.instance
    this.work = WorkExperienceModel.instance
    this.project = ProjectExperienceModel.instance
    this.edu = EducationalBackgroundModel.instance
    const parts = this.personal.data.workStartDate.split('.');
    const year = parts[0];
    const month = parts[1];
    const startDate = new Date(parseInt(year), parseInt(month) - 1);
    const now = new Date();
    const monthsDiff = (now.getFullYear() - startDate.getFullYear()) * 12 + (now.getMonth() - startDate.getMonth());
    this.years = Math.floor(monthsDiff / 12);
    // 强制触发UI刷新
    this.forceUpdate++
  }

  private get workTimeline(): Array<ResumeTimelineItem> {
    return this.work.items.map((w: WorkItem): ResumeTimelineItem => ({
      title: w.company,
      role: w.position,
      startDate: w.startDate,
      endDate: w.endDate,
      description: w.description
    }))
  }

  private get projectTimeline(): Array<ResumeTimelineItem> {
    return this.project.items.map((p: ProjectItem): ResumeTimelineItem => ({
      title: p.name,
      role: p.role,
      startDate: p.startDate,
      endDate: p.endDate,
      description: p.description
    }))
  }

  @Builder
  personalHeader() {
    Row() {
      Column() {
        Row() {
          Text(this.personal.data.name || '')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          Image($r('app.media.ic_edit'))
            .width(20)
            .height(19)
            .margin({ left: 7 })
            .onClick(() => {
              phoneRouterControl.jumpPage({
                pageName: RouterMap.RESUME_PERSONAL_INFO_PAGE,
                builder: wrapBuilder(PersonalInformationPageBuilder)
              })
            })
        }

        Row() {

          if (this.personal.data.gender) {
            GrayText({ text: this.personal.data.gender,fontSize:14 })
          }
          if (this.personal.data.age) {
            GrayText({ text: '·' + this.personal.data.age,fontSize:14  })
          }
          if (this.personal.data.workStartDate) {
            GrayText({ text: '·' + this.years + '年工作经验' ,fontSize:14 })
          }
        }
        .margin({ top: 8 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)

      Row() {
        Image(this.personal.data.avatarUrl)
          .borderRadius(30)
      }.width(60).height(60)
    }
    .width('100%')
    .padding({ top: 20 })
  }

  @Builder
  timelineList(items: Array<ResumeTimelineItem>) {
    Column() {
      ForEach(items, (it: ResumeTimelineItem, idx: number) => {
        Column() {
          Row() {
            Text(it.title)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
            Blank()
            GrayText({ text: (it.startDate || '') + '-' + (it.endDate || '至今') })

              .margin({ right: 7 })
            SymbolGlyph($r('sys.symbol.chevron_right')).fontSize('24vp').fontColor([$r('sys.color.font_fourth')])
          }
          .width('100%')

          Row() {
            GrayText({ text: it.role })
          }
          .width('100%')
          .margin({ top: 4 })

          GrayText({
            text: it.description,
            lineHeight: 18
          })
            .margin({ top: 8 })

          if (idx === items.length - 1) {
            Row().height(1).backgroundColor('#E5E7E9').width('100%').margin({ top: 10, bottom: 10 })
          }
        }
        .width('100%')
        .padding({ top: 8, bottom: 8 })
      }, (item: ResumeTimelineItem, index: number) => `${JSON.stringify(item)}_${index}}`)
    }
    .width('100%')
  }

  @Builder
  certificateChips() {
    // 使用forceUpdate确保响应式更新
    if (this.forceUpdate >= 0 && this.cert.items && this.cert.items.length > 0) {
      Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Start }) {
        ForEach(this.cert.items, (c: CertificateItem) => {
          GrayText({ text: c.name })
            .padding({
              left: 10,
              right: 10,
              top: 6,
              bottom: 6
            })
            .backgroundColor('#F5F5F5')
            .borderRadius(4)
            .margin({ right: 8, bottom: 8 })
        }, (c: CertificateItem) => JSON.stringify(c))
      }
      .width('100%')
      .margin({ top: 8 })
    }
  }

  @Builder
  sectionHeader(title: string, required: boolean = false, icAdd: ResourceStr = '', actionClick?: () => void) {
    Row() {
      Row() {
        Text(title)
          .fontSize(16)
          .lineHeight(19)
          .fontWeight(700)
          .fontColor($r('sys.color.font_primary'))
        if (required) {
          Text(' *')
            .fontSize(18)
            .fontColor('#C4272B')
        }
      }

      Blank()
      if (icAdd && icAdd !== '') {
        if (icAdd === '编辑') {
          Text(icAdd)
            .fontSize(14)
            .lineHeight(16)
            .fontWeight(400)
            .fontColor('#0A59F7')
            .onClick(() => {
              if (actionClick) {
                actionClick()
              }
            })
        } else {
          Image(icAdd)
            .width(16)
            .onClick(() => {
              if (actionClick) {
                actionClick()
              }
            })
        }
      }
    }
    .width('100%')

  }

  @Builder
  buildStack() {
    Stack({ alignContent: Alignment.End }) {
      CommonHeader({
        title: '在线简历',
        backgroundColorParam: '#fff',
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
      })

    }
    .width('100%')
    .height(48)
  }

  @Builder
  buildScroll() {
    Scroll() {
      Column() {
        // 关键：每次页面显示时强制刷新ViewModel
        Blank()
          .height(0)
          .visibility(Visibility.None)
          .onAppear(() => {
            // 重新赋值vm，强制建立响应式连接
            this.cert = QualificationCertificateModel.instance
            this.cert.reload() // 重新加载证书数据
            this.career = CareerObjectiveModel.instance
            this.work = WorkExperienceModel.instance
            this.project = ProjectExperienceModel.instance
            this.edu = EducationalBackgroundModel.instance
            this.forceUpdate++
          })

        this.personalHeader()
        ResumeDivider({
          marginTop: 20,
          marginBottom: 20
        })

        this.sectionHeader('个人优势', this.resumeVM.requireSelfEvaluation, '编辑', () => {
          TextEditingContext.instance.setPageType('selfEvaluation')
          phoneRouterControl.jumpPage({
            pageName: RouterMap.RESUME_SELF_EVALUATION_PAGE,
            builder: wrapBuilder(TextEditingBuilder)
          })
        })
        if (this.selfEval.content && this.selfEval.content !== '') {
          GrayText({
            text: this.selfEval.content,
            lineHeight: 18,
            maxLines: 4,
            textOverflow: TextOverflow.Ellipsis,
            fontSize: 14
          })
            .width('100%')
        }
        ResumeDivider({
          marginTop: 20,
          marginBottom: 20
        })

        this.sectionHeader('求职意向', this.resumeVM.requireCareerObjective,
          $r('app.media.ic_add'), () => {
            CareerObjectiveModel.instance.startEdit(-1)
            phoneRouterControl.jumpPage({
              pageName: RouterMap.RESUME_CAREER_OBJECTIVE_PAGE,
              builder: wrapBuilder(CareerObjectivePageBuilder),
              onPop: () => {
                phoneRouterControl.popLastPage()
              }
            })
          })
        if (this.career!.items.length > 0) {
          Column() {
            ForEach(this.career!.items, (ci: CareerObjectiveItem, index: number) => {
              Row() {
                Column({ space: 4 }) {
                  // 意向职位
                  if (ci.position) {
                    Row({ space: 7 }) {
                      Text(ci.position)
                        .fontSize(14)
                        .fontWeight(FontWeight.Bold)
                        .fontColor($r('sys.color.font_primary'))
                      GrayText({
                        text: ci.salary || '',
                        fontSize: 14,
                        lineHeight: 16,
                        fontWeight: 700,
                        fontColor: '#FF0A59F7'
                      })
                    }
                  }

                  // 工作城市和行业
                  Row() {
                    if (ci.city) {
                      GrayText({ text: ci.city, fontSize: 14 })
                    }
                    if (ci.city && ci.industry) {
                      GrayText({ text: '·', fontSize: 14 })
                    }
                    if (ci.industry) {
                      GrayText({ text: ci.industry, fontSize: 14 })
                    }
                    if (ci.jobStatus) {
                      GrayText({ text: '·', fontSize: 14 })
                      GrayText({ text: ci.jobStatus, fontSize: 14 })
                    }
                    if (ci.jobType) {
                      GrayText({ text: '·', fontSize: 14 })
                      GrayText({ text: ci.jobType, fontSize: 14 })
                    }
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .fontSize('24vp')
                  .fontColor([$r('sys.color.font_fourth')])
              }
              .width('100%')
              .padding({ top: 12 })
              .borderRadius(8)
              .justifyContent(FlexAlign.SpaceBetween)
              .onClick(() => {
                // 点击已有数据，进入编辑模式
                CareerObjectiveModel.instance.startEdit(index, ci)
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.RESUME_CAREER_OBJECTIVE_PAGE,
                  builder: wrapBuilder(CareerObjectivePageBuilder),
                  onPop: () => {
                    phoneRouterControl.popLastPage()
                  }
                })
              })
            }, (item: CareerObjectiveItem, index: number) => `${JSON.stringify(item)}_${index}}`)
          }
        }
        ResumeDivider({
          marginTop: 20,
          marginBottom: 20
        })

        this.sectionHeader('工作经历', false, $r('app.media.ic_add'), () => {
          this.work.startEdit(-1)
          phoneRouterControl.jumpPage({
            pageName: RouterMap.RESUME_WORK_EXPERIENCE_PAGE,
            builder: wrapBuilder(WorkExperiencePageBuilder)
          })
        })
        if (this.work.items.length > 0) {
          Column() {
            ForEach(this.work.items, (w: WorkItem, idx: number) => {
              ExperienceCard({
                title: w.company,
                subtitle: w.position,
                description: w.description,
                startDate: w.startDate,
                endDate: w.endDate,
                onEditClick: () => {
                  this.work.startEdit(idx, w)
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.RESUME_WORK_EXPERIENCE_PAGE,
                    builder: wrapBuilder(WorkExperiencePageBuilder)
                  })
                }
              })

              if (idx === this.work.items.length - 1) {
                ResumeDivider({})
              }
            }, (item: WorkItem, index: number) => `${JSON.stringify(item)}_${index}}`)
          }
          .width('100%')
        } else {
          ResumeDivider({
            marginTop: 20,
            marginBottom: 20
          })
        }
        this.buildScrollAfter()
      }
      .width('100%')
      .padding({ bottom: BarVM.instance.aiBarH })
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .layoutWeight(1)
  }

  @Builder
  buildScrollAfter() {

    this.sectionHeader('项目经验', false, $r('app.media.ic_add'), () => {
      this.project.startEdit(-1)
      phoneRouterControl.jumpPage({
        pageName: RouterMap.RESUME_PROJECT_EXPERIENCE_PAGE,
        builder: wrapBuilder(ProjectExperiencePageBuilder)
      })
    })
    if (this.project.items.length > 0) {
      Column() {
        ForEach(this.project.items, (p: ProjectItem, idx: number) => {
          ExperienceCard({
            title: p.name,
            subtitle: p.role,
            description: p.description,
            startDate: p.startDate,
            endDate: p.endDate,
            titleFontSize: 14,
            titleFontWeight: 700,
            titleColor: '#333333',
            onEditClick: () => {
              this.project.startEdit(idx, p)
              phoneRouterControl.jumpPage({
                pageName: RouterMap.RESUME_PROJECT_EXPERIENCE_PAGE,
                builder: wrapBuilder(ProjectExperiencePageBuilder)
              })
            }
          })

          if (idx === this.project.items.length - 1) {
            ResumeDivider({})
          }
        }, (item: ProjectItem, index: number) => `${JSON.stringify(item)}_${index}}`)
      }
      .width('100%')
    } else {
      ResumeDivider({
        marginTop: 20,
        marginBottom: 20
      })
    }


    this.sectionHeader('教育背景', this.resumeVM.requireEducationBackground, $r('app.media.ic_add'), () => {
      this.edu.startEdit(-1)
      phoneRouterControl.jumpPage({
        pageName: RouterMap.RESUME_EDUCATION_BACKGROUND_PAGE,
        builder: wrapBuilder(EducationalBackgroundPageBuilder)
      })
    })
    if (this.edu.items.length > 0) {
      Column() {
        ForEach(this.edu.items, (e: EducationItem, idx: number) => {
          EducationCard({
            school: e.school,
            degree: e.degree,
            major: e.major,
            startDate: e.startDate,
            endDate: e.endDate,
            onEditClick: () => {
              this.edu.startEdit(idx, e)
              phoneRouterControl.jumpPage({
                pageName: RouterMap.RESUME_EDUCATION_BACKGROUND_PAGE,
                builder: wrapBuilder(EducationalBackgroundPageBuilder)
              })
            }
          })

          if (idx === this.edu.items.length - 1) {
            ResumeDivider({})
          }
        }, (item: EducationItem, index: number) => `${JSON.stringify(item)}_${index}}`)
      }
      .width('100%')
    } else {
      ResumeDivider({
        marginTop: 20,
        marginBottom: 20
      })
    }

    this.sectionHeader('技能证书', false, $r('app.media.ic_add'), () => {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.RESUME_QUALIFICATION_CERTIFICATE_PAGE,
        builder: wrapBuilder(QualificationCertificatePageBuilder)
      }).then(() => {
        // 页面返回后刷新证书数据
        this.cert = QualificationCertificateModel.instance
        this.cert.reload()
        this.forceUpdate++
      })
    })
    this.certificateChips()
  }

  build() {
    NavDestination() {
      Column() {
        this.buildStack()
        this.buildScroll()

        Row() {
          Text('预览在线简历')
            .fontSize(14)
            .fontColor('#FF564AF7')
        }
        .width('100%')
        .height(40)
        .justifyContent(FlexAlign.Center)
        .borderRadius(8)
        .backgroundColor('rgba(86, 74, 247, 0.1)')
        .margin({ top: 8 })
        .onClick(() => {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.RESUME_PREVIEW_PAGE,
            builder: wrapBuilder(ResumePreviewPageBuilder)
          })
        })
      }
      .width('100%')
      .height('100%')
      .padding({
        top: BarVM.instance.staBarH,
        bottom: BarVM.instance.aiBarH,
        left: 16,
        right: 16,
      })
    }
    .onVisibleAreaChange([0, 1], (isExpanding, currentRatio) => {
      if (isExpanding && currentRatio > 0) {
        setTimeout(() => {
          this.loadAllData()
        }, 300)

      }
    })
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }
}
