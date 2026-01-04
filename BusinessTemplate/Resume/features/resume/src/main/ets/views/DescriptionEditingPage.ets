/**
 * 此页面应用于自我评价、职业技能、工作经历描述、项目描述页面的文本编辑
 */

import { CommonHeader, GlobalContext } from 'common'
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router'
import { SelfEvaluationModel } from '../viewsmodel/SelfEvaluationModel'
import { VocationalSkillModel } from '../viewsmodel/VocationalSkillModel'
import { WorkExperienceModel, WorkItem } from '../viewsmodel/WorkExperienceModel'
import { ProjectExperienceModel, ProjectItem } from '../viewsmodel/ProjectExperienceModel'
import { UnsavedChangesDialogController } from '../comp/UnsavedChangesDialog'

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
    switch (pageType) {
      case 'selfEvaluation':
        return {
          title: '自我评价',
          placeholder: '请编辑自我评价',
          initialText: SelfEvaluationModel.instance.content,
          maxLength: 1000,
          onSave: (text: string) => {
            SelfEvaluationModel.instance.setContent(text)
          }
        }
      case 'vocationalSkill':
        const currentSkills = VocationalSkillModel.instance.skills
        const initialText = currentSkills && currentSkills.length > 0 ? currentSkills.join(' ') : ''
        return {
          title: '职业技能',
          placeholder: '请编辑您的职业技能',
          initialText: initialText,
          maxLength: 1000,
          onSave: (text: string) => {
            const skillsArray = text.trim() ? [text]: []
            VocationalSkillModel.instance.setSkills(skillsArray)
          }
        }
      case 'workDescription':
        return {
          title: '工作经历',
          placeholder: '请编辑工作经历',
          initialText: WorkExperienceModel.instance.draft.description,
          maxLength: 1000,
          onSave: (text: string) => {
            WorkExperienceModel.instance.setDraftDescription(text)
            // 立即同步到 items 数组，如果正在编辑现有项
            const editingIndex = WorkExperienceModel.instance.editingIndex
            if (editingIndex !== -1 && WorkExperienceModel.instance.items[editingIndex]) {
              const currentItem = WorkExperienceModel.instance.items[editingIndex]
              const updatedItem: WorkItem = {
                company: currentItem.company,
                position: currentItem.position,
                industry: currentItem.industry,
                startDate: currentItem.startDate,
                endDate: currentItem.endDate,
                description: text
              }
              WorkExperienceModel.instance.updateItem(editingIndex, updatedItem)
            }
          }
        }
      case 'projectDescription':
        return {
          title: '项目描述',
          placeholder: '请编辑项目描述',
          initialText: ProjectExperienceModel.instance.draft.description,
          maxLength: 1000,
          onSave: (text: string) => {
            ProjectExperienceModel.instance.setDraftDescription(text)
            // 立即同步到 items 数组，如果正在编辑现有项
            const editingIndex = ProjectExperienceModel.instance.editingIndex
            if (editingIndex !== -1 && ProjectExperienceModel.instance.items[editingIndex]) {
              const currentItem = ProjectExperienceModel.instance.items[editingIndex]
              const updatedItem: ProjectItem = {
                name: currentItem.name,
                role: currentItem.role,
                startDate: currentItem.startDate,
                endDate: currentItem.endDate,
                description: text
              }
              ProjectExperienceModel.instance.updateItem(editingIndex, updatedItem)
            }
          }
        }
      default:
        return {} as TextEditingConfig
    }
  }

  checkUnsavedAndExit(): boolean {
    if (this.text !== this.initialText) {
      UnsavedChangesDialogController.openDialog(GlobalContext.getUIContext(), {
        onConfirm: () => {
          phoneRouterControl.popPage()
        },
        onCancel: () => {}
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
      pageBackgroundColor: $r('sys.color.comp_background_list_card')
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
        backgroundColorParam: $r('sys.color.comp_background_list_card'),
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
          .maxLength(this.maxLength)
          .onChange((value: string) => {
            this.text = value
          })

        Text(`${this.text.length}/${this.maxLength}`)
          .fontSize(12)
          .fontColor(this.text.length >= this.maxLength ? '#FF0000' : '#999999')
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
        .fontColor($r('sys.color.comp_background_list_card'))
        .margin({ bottom: 12, top: 12 })
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          if (this.pageType === 'selfEvaluation' && (!this.text || this.text.trim().length === 0)) {
            GlobalContext.getUIContext().getPromptAction().showToast({
              message: '自我评价不能为空'
            })
            return
          }
          this.actualConfig.onSave(this.text)
          phoneRouterControl.popPage()
        })

    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
