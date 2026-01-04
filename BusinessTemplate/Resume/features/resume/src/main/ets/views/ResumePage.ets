/**
 * 简历主页面
 * 展示简历的所有模块信息,包括基本信息、求职意向、教育背景、工作经历、项目经验等
 * 支持跳转到各个编辑页面和预览简历
 */

import { BarVM, createNWeb, RouterMap, UserInfo } from 'common'
import { ResumeModel } from '../viewsmodel/ResumeModel'
import { PersonalInfo, PersonalInformationModel } from '../viewsmodel/BasicalInformationModel'
import { PersonalInformationPageBuilder } from './BasicalInformationPage'
import { EducationalBackgroundPageBuilder } from './EducationalBackgroundPage'
import { WorkExperiencePageBuilder } from './WorkExperiencePage'
import { ProjectExperiencePageBuilder } from './ProjectExperiencePage'
import { CareerObjectivePageBuilder } from './CareerObjectivePage'
import { QualificationCertificatePageBuilder } from './QualificationCertificatePage'
import { TextEditingBuilder, TextEditingContext } from './DescriptionEditingPage'
import { SelfEvaluationModel } from '../viewsmodel/SelfEvaluationModel'
import { CareerObjectiveItem, CareerObjectiveModel } from '../viewsmodel/CareerObjectiveModel'
import { EducationalBackgroundModel, EducationItem } from '../viewsmodel/EducationalBackgroundModel'
import { VocationalSkillModel } from '../viewsmodel/VocationalSkillModel'
import { CertificateItem, QualificationCertificateModel } from '../viewsmodel/QualificationCertificateModel'
import { WorkExperienceModel, WorkItem } from '../viewsmodel/WorkExperienceModel'
import { ProjectExperienceModel, ProjectItem } from '../viewsmodel/ProjectExperienceModel'
import { PersistenceV2 } from '@kit.ArkUI'
import { phoneRouterControl } from 'oh_router'
import { util } from '@kit.ArkTS'
import { GrayText } from '../comp/GrayText'
import { ResumeDivider } from '../comp/ResumeDivider'
import { ExperienceCard } from '../comp/ExperienceCard'
import { EducationCard } from '../comp/EducationCard'
import { ResumePreviewPageBuilder } from './ResumePreviewPage'

@ComponentV2
export struct ResumePage {
  @Local userInfo: UserInfo = new UserInfo()
  @Local resumeVM: ResumeModel = new ResumeModel()
  @Local personalInfo: PersonalInfo = {
    name: '',
    phone: '',
    email: '',
    avatarUrl: $r('app.media.ic_defaultAvatar'),
    avatarUrlBase64: ''
  }
  @Local selfEval: SelfEvaluationModel = new SelfEvaluationModel()
  @Local career: CareerObjectiveModel = new CareerObjectiveModel()
  @Local edu: EducationalBackgroundModel = new EducationalBackgroundModel()
  @Local skill: VocationalSkillModel = new VocationalSkillModel()
  @Local cert: QualificationCertificateModel = new QualificationCertificateModel()
  @Local work: WorkExperienceModel = new WorkExperienceModel()
  @Local project: ProjectExperienceModel = new ProjectExperienceModel()
  @Local forceUpdate: number = 0
  @Local routerModule: NavPathStack = new NavPathStack()
  @Local showBackButton: boolean = false
  @Local defaultAvatarBase64: string = ''
  private uiContext: UIContext | null = null;

  async aboutToAppear(): Promise<void> {
    this.uiContext = this.getUIContext();
    // 预加载默认头像Base64
    try {
      const context = this.getUIContext().getHostContext()
      if (context) {
        const resourceMgr = context.resourceManager
        const fileData = await resourceMgr.getMediaContent($r('app.media.ic_defaultAvatar'))
        const buffer = fileData.buffer
        const helper = new util.Base64Helper()
        this.defaultAvatarBase64 = helper.encodeToStringSync(new Uint8Array(buffer))
      }
    } catch (e) {
      // Failed to load default avatar
    }

    try {
      this.userInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!
      this.resumeVM = ResumeModel.instance
      // Note: personalInfo will be loaded in loadAllData
      this.selfEval = SelfEvaluationModel.instance
      this.career = CareerObjectiveModel.instance
      this.edu = EducationalBackgroundModel.instance
      this.skill = VocationalSkillModel.instance
      this.cert = QualificationCertificateModel.instance
      this.work = WorkExperienceModel.instance
      this.project = ProjectExperienceModel.instance
    } catch (e) {
      // ResumePage init error
    }
    // 初始化时加载数据
    this.loadAllData()
  }

  onPageEnd(h5Width: number, h5Height: number) {
    this.resumeVM.h5Width = h5Width
    this.resumeVM.h5Height = h5Height
  }

  private loadAllData(): void {
    // 每次页面显示时，从单例获取最新数据并创建副本，确保UI刷新
    const model = PersonalInformationModel.instance
    this.personalInfo = {
      name: model.data.name,
      phone: model.data.phone,
      email: model.data.email,
      avatarUrl: model.data.avatarUrl,
      avatarUrlBase64: model.data.avatarUrlBase64
    }

    this.cert = QualificationCertificateModel.instance
    this.cert.reload() // 重新加载证书数据
    this.career = CareerObjectiveModel.instance
    this.work = WorkExperienceModel.instance
    this.project = ProjectExperienceModel.instance
    this.edu = EducationalBackgroundModel.instance

    // 处理个人信息数据，处理空值和默认头像
    let personalData: object = Object({
      name: this.personalInfo.name,
      // 如果为空字符串，设为undefined，以便JSON序列化时忽略该字段，使H5隐藏图标
      phone: this.personalInfo.phone || undefined,
      email: this.personalInfo.email || undefined,
      // 如果没有自定义头像，使用默认头像Base64
      avatarUrlBase64: this.personalInfo.avatarUrlBase64 || this.defaultAvatarBase64
    })

    let webData: object = Object({
      personal: personalData,
      selfEval: this.selfEval.content,
      draftList: this.career.items,
      edu: this.edu.items,
      cert: this.cert.items,
      skill: this.skill.skills,
      work: this.work.items,
      project: this.project.items
    })
    this.resumeVM.setPreviewWebData(webData)
    // 强制触发UI刷新
    this.forceUpdate++
  }

  @Builder
  personalHeader() {
    // 绑定forceUpdate以强制刷新
    if (this.forceUpdate >= 0) {
      Row() {
        Column() {
          Row() {
            Text(this.personalInfo.name || '姓名')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
            if (!this.personalInfo.name) {
              Text(' *')
                .fontSize(18)
                .fontColor('#C4272B')
            }
            Image($r('app.media.ic_edit'))
              .width(16)
              .margin({ left: 14 })
              .onClick(() => {
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.RESUME_PERSONAL_INFO_PAGE,
                  builder: wrapBuilder(PersonalInformationPageBuilder)
                })
              })
          }

          Row() {
            if (this.personalInfo.phone && this.personalInfo.phone !== '') {
              Image($r('app.media.ic_phone'))
                .width(16)
                .margin({ right: 4 })
              GrayText({ text: this.personalInfo.phone })
            }

            if (this.personalInfo.email && this.personalInfo.email !== '') {
              Image($r('app.media.ic_email'))
                .width(16)
                .margin({ left: 16, right: 4 })
              GrayText({ text: this.personalInfo.email })
            }
          }
          .margin({ top: 6 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)

        Row() {
          Image(this.personalInfo.avatarUrl)
            .width(60)
            .height(60)
            .borderRadius(30)
            .objectFit(ImageFit.Cover)
        }
      }
      .width('100%')
      .padding({ top: 8, bottom: 8 })
    }
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
        }, (c: CertificateItem) => c.name)
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
          .fontWeight(FontWeight.Bold)
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
            .width(20)
            .onClick(() => {
              if (actionClick) {
                actionClick()
              }
            })
        }
      }
    }
    .width('100%')
    .height(30)
  }

  @Builder
  buildEduSkillCert() {
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
        }, (e: EducationItem, idx: number) => `edu-${idx}-${this.forceUpdate}`)
      }
      .width('100%')
    } else {
      ResumeDivider({})
    }

    this.sectionHeader('职业技能', false, '编辑', () => {
      TextEditingContext.instance.setPageType('vocationalSkill')
      phoneRouterControl.jumpPage({
        pageName: RouterMap.RESUME_VOCATIONAL_SKILL_PAGE,
        builder: wrapBuilder(TextEditingBuilder)
      })
    })
    if (this.skill.skills && this.skill.skills.length > 0) {
      GrayText({
        text: this.skill.skills.join(''),
        lineHeight: 18
      })
        .width('100%')
    }
    ResumeDivider({})

    this.sectionHeader('资格证书', false, $r('app.media.ic_add'), () => {
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
    ResumeDivider({ marginTop: 10, marginBottom: 10 })
  }

  @Builder
  buildScroll() {
    Scroll() {
      Column() {
        this.personalHeader()
        ResumeDivider({})

        this.sectionHeader('自我评价', this.resumeVM.requireSelfEvaluation, '编辑', () => {
          TextEditingContext.instance.setPageType('selfEvaluation')
          phoneRouterControl.jumpPage({
            pageName: RouterMap.RESUME_SELF_EVALUATION_PAGE,
            builder: wrapBuilder(TextEditingBuilder)
          })
        })
        if (this.selfEval.content && this.selfEval.content !== '') {
          GrayText({
            text: this.selfEval.content,
            lineHeight: 18
          })
            .width('100%')
        }
        ResumeDivider({})

        Row() {
          Row() {
            Text('求职意向')
              .fontSize(16)
              .lineHeight(19)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
            if (this.resumeVM.requireCareerObjective) {
              Text(' *')
                .fontSize(18)
                .fontColor('#C4272B')
            }
          }

          Blank()
          if (this.career.items.length < 1) {
            Image($r('app.media.ic_add'))
              .width(20)
              .onClick(() => {
                CareerObjectiveModel.instance.startEdit(-1)
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.RESUME_CAREER_OBJECTIVE_PAGE,
                  builder: wrapBuilder(CareerObjectivePageBuilder)
                })
              })
          }
        }
        .width('100%')
        .height(30)

        if (this.career.items.length > 0) {
          Column() {
            ForEach(this.career.items, (ci: CareerObjectiveItem, index: number) => {
              Row() {
                Column({ space: 4 }) {
                  // 意向职位
                  Row({ space: 7 }) {
                    if (ci.position) {
                      Text(ci.position)
                        .fontSize(14)
                        .fontWeight(FontWeight.Bold)
                        .fontColor($r('sys.color.font_primary'))
                    }
                    GrayText({
                      text: ci.salary || '',
                      fontSize: 14,
                      lineHeight: 16,
                      fontWeight: 700,
                      fontColor: '#FF0A59F7'
                    })
                  }

                  // 工作城市和行业
                  Row() {
                    if (ci.city) {
                      GrayText({ text: ci.city })
                    }
                    if (ci.city && ci.industry) {
                      GrayText({ text: '·' })
                    }
                    if (ci.industry) {
                      GrayText({ text: ci.industry })
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
                  builder: wrapBuilder(CareerObjectivePageBuilder)
                })
              })
            }, (ci: CareerObjectiveItem, index: number) => `career-${index}-${this.forceUpdate}`)
          }
        }
        ResumeDivider({})

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
            }, (w: WorkItem, idx: number) => `work-${idx}-${this.forceUpdate}`)
          }
          .width('100%')
        } else {
          ResumeDivider({})
        }

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
            }, (p: ProjectItem, idx: number) => `project-${idx}-${this.forceUpdate}`)
          }
          .width('100%')
        } else {
          ResumeDivider({})
        }
        this.buildEduSkillCert()
      }
      .width('100%')
      .padding({ bottom: BarVM.instance.aiBarH })
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          if (this.showBackButton) {
            Button({ type: ButtonType.Circle }) {
              SymbolGlyph($r('sys.symbol.chevron_backward')).fontSize(24).fontColor([Color.Black])
            }
            .width(40)
            .height(40)
            .backgroundColor('#F3F4F5')
            .margin({ right: 8 })
            .border({ width: 1, color: '#E5E7E9' })
            .onClick(() => phoneRouterControl.popPage())
          }

          Text(this.resumeVM.pageTitle)
            .fontSize(this.showBackButton ? 18 : $r('sys.float.Title_M'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
            .textAlign(this.showBackButton ? TextAlign.Center : TextAlign.Start)
          Blank()
          Text(this.resumeVM.previewLabel)
            .fontSize(14)
            .fontColor('#0A59F7')
            .onClick(() => {
              phoneRouterControl.jumpPage({
                pageName: 'ResumePreviewPage',
                builder: wrapBuilder(ResumePreviewPageBuilder)
              })
            })
            .padding({
              top: 5,
              bottom: 5,
            })
        }
        .width('100%')
        .height(48)

        this.buildScroll()
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16, bottom: 24 })
    }
    .onVisibleAreaChange([0, 1], (isExpanding, currentRatio) => {
      if (isExpanding && currentRatio > 0) {
        createNWeb('template', this.uiContext!, '3', ResumeModel.instance, this.resumeVM.webController, '',
          this.onPageEnd);
        this.loadAllData()
      }
    })
    .onReady((context: NavDestinationContext) => {
      this.routerModule = context.pathStack
      // 使用AppStorage获取返回按钮显示标志，避免路由参数传递导致的闪退
      const showBack = AppStorage.get<boolean>('resumePageShowBackButton')
      if (showBack === true) {
        this.showBackButton = true
        // 使用后清除标志
        AppStorage.setOrCreate('resumePageShowBackButton', false)
      }
    })
    .onShown(() => {
      // 页面显示时刷新数据
      this.loadAllData()
    })
    .hideTitleBar(true)
  }
}

@Builder
export function ResumePageBuilder() {
  ResumePage({})
}
