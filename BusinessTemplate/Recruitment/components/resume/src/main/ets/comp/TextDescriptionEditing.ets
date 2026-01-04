import { CommonHeader, BarVM } from 'common'
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router'
import { SelfEvaluationModel } from '../viewsmodel/SelfEvaluationModel'
import { VocationalSkillModel } from '../viewsmodel/VocationalSkillModel'
import { WorkExperienceModel } from '../viewsmodel/WorkExperienceModel'
import { ProjectExperienceModel } from '../viewsmodel/ProjectExperienceModel'
import { UnsavedChangesDialogController } from 'job_intention'

export interface TextEditingConfig {
  title: string
  placeholder: string
  initialText: string
  maxLength?: number
  onSave: (text: string) => void
}

// 简单的页面类型标识
export type TextEditingPageType = 'selfEvaluation' | 'vocationalSkill' | 'workDescription' | 'projectDescription'

// 路由参数接口
export interface TextEditingParam {
  pageType: TextEditingPageType
}

class TextEditingContext {
  private static _instance: TextEditingContext
  public currentPageType: TextEditingPageType | undefined = undefined

  static get instance(): TextEditingContext {
    if (!TextEditingContext._instance) {
      TextEditingContext._instance = new TextEditingContext()
    }
    return TextEditingContext._instance
  }

  setPageType(pageType: TextEditingPageType): void {
    this.currentPageType = pageType
  }

  getPageType(): TextEditingPageType | undefined {
    return this.currentPageType
  }

  clear(): void {
    this.currentPageType = undefined
  }
}

export { TextEditingContext }

@Builder
export function TextEditingBuilder(_param: Object) {
  TextDescriptionEditing()
}

@ComponentV2
export struct TextDescriptionEditing {
  @Param config: TextEditingConfig = {
    title: '',
    placeholder: '',
    initialText: '',
    maxLength: 1000,
    onSave: () => {
    }
  }
  @Local actualConfig: TextEditingConfig = {
    title: '',
    placeholder: '',
    initialText: '',
    maxLength: 1000,
    onSave: () => {
    }
  }
  @Local routerModule: NavPathStack = new NavPathStack()
  @Local text: string = ''
  @Local initialText: string = ''
  @Local pageType: TextEditingPageType | undefined = undefined
  @Local showExitDialog: boolean = false
  private maxLength: number = 1000

  aboutToAppear(): void {
    // 配置将在onReady中从路由参数读取
  }

  private getConfigByPageType(pageType: TextEditingPageType): TextEditingConfig {
    let config: TextEditingConfig; // 提前声明配置变量
    switch (pageType) {
      case 'selfEvaluation':
        config = {
          title: '个人优势',
          placeholder: '请编辑自我评价',
          initialText: SelfEvaluationModel.instance.content,
          maxLength: 1000,
          onSave: (text: string) => {
            SelfEvaluationModel.instance.setContent(text);
          }
        };
        break; // 注意使用 break
      case 'vocationalSkill':
        const currentSkills = VocationalSkillModel.instance.skills;
        const initialText = currentSkills && currentSkills.length > 0 ? currentSkills.join(' ') : '';
        config = {
          // 复杂逻辑内嵌，但return模式统一
          title: '职业技能',
          placeholder: '请编辑您的职业技能',
          initialText: initialText,
          maxLength: 1000,
          onSave: (text: string) => {
            const skillsArray = text.trim() ? text.trim().split(/\s+/) : [];
            VocationalSkillModel.instance.setSkills(skillsArray);
          }
        };
        break;
      case 'workDescription':
        config = {
          title: '工作经历',
          placeholder: '请编辑工作经历',
          initialText: WorkExperienceModel.instance.draft.description,
          maxLength: 1000,
          onSave: (text: string) => {
            WorkExperienceModel.instance.setDraftDescription(text);
          }
        };
        break;
      case 'projectDescription':
        config = {
          title: '项目描述',
          placeholder: '请编辑项目描述',
          initialText: ProjectExperienceModel.instance.draft.description,
          maxLength: 1000,
          onSave: (text: string) => {
            ProjectExperienceModel.instance.setDraftDescription(text);
          }
        };
        break;
      // 如果未来有新增类型，可以考虑增加 default 抛出错误
      // default:
      //   throw new Error(`Unsupported page type: ${pageType}`);
    }
    return config; // 统一在此处返回
  }

  checkUnsavedAndExit(): boolean {
    if (this.text !== this.initialText) {
      UnsavedChangesDialogController.openDialog(this.getUIContext(), {
        onConfirm: () => {
          phoneRouterControl.popPage()
        },
        onCancel: () => {
        }
      })
      return true
    }
    return false
  }

  build() {
    OHPage({
      pageConfig: new OHPageConfig({
        onBackPress: () => {
          return this.checkUnsavedAndExit()
        }
      }),
      childBuilder: () => {
        this.pageNav()
      },
      useSafePadding: true,
      pageBackgroundColor: '#FFFFFF'
    })
  }

  @Builder
  pageNav() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.routerModule = context.pathStack

      // 优先从单例中获取pageType
      this.pageType = TextEditingContext.instance.getPageType()
      // 如果单例中没有，尝试从参数中获取
      if (!this.pageType && context.pathInfo.param) {
        const param = context.pathInfo.param as TextEditingParam
        if (param.pageType) {
          this.pageType = param.pageType
        }
      }

      // 根据pageType获取配置
      if (this.pageType) {
        this.actualConfig = this.getConfigByPageType(this.pageType)
        // 清除单例中的pageType
        TextEditingContext.instance.clear()
      } else if (this.config.title) {
        // 使用外部传入的config
        this.actualConfig = this.config
      } else {
        // 默认配置
        this.actualConfig = {
          title: '编辑',
          placeholder: '请输入内容',
          initialText: '',
          maxLength: 1000,
          onSave: (text: string) => {
          }
        }
      }
      this.text = this.actualConfig.initialText || ''
      this.initialText = this.text
      if (this.actualConfig.maxLength) {
        this.maxLength = this.actualConfig.maxLength
      }
    })
  }

  @Builder
  render() {
    Column() {
      CommonHeader({
        title: this.actualConfig.title,
        backgroundColorParam: '#FFFFFF',
        onReturnClick: () => {
          if (!this.checkUnsavedAndExit()) {
            phoneRouterControl.popPage()
          }
        }
      })

      Stack({ alignContent: Alignment.BottomEnd }) {
        TextArea({ text: this.text, placeholder: this.actualConfig.placeholder })
          .width('100%')
          .height('100%')
          .padding({
            top: 16,
            left: 0,
            right: 0,
            bottom: 40
          })
          .borderRadius(0)
          .fontSize(16)
          .textAlign(TextAlign.Start)
          .backgroundColor(Color.White)
          .maxLength(this.actualConfig.maxLength)
          .onChange((value: string) => {
            if (value.length > this.maxLength) {
              this.text = value.substring(0, this.maxLength)
            } else {
              this.text = value
            }
          })

        Text(`${this.text.length}/${this.maxLength}`)
          .fontSize(12)
          .fontColor('#999999')
          .margin({ right: 16, bottom: 16 })
      }
      .layoutWeight(1)
      .width('100%')

      Button('保存')
        .width('100%')
        .height(44)
        .backgroundColor('#0A59F7')
        .borderRadius(22)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_on_primary'))
        .margin({ bottom: 12, top: 12 })
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          this.actualConfig.onSave(this.text)
          phoneRouterControl.popPage()
        })


    }
    .width('100%')
    .height('100%')
    .padding({
      top: BarVM.instance.staBarH,
      bottom: BarVM.instance.aiBarH
    })
    .backgroundColor(Color.White)
  }
}
