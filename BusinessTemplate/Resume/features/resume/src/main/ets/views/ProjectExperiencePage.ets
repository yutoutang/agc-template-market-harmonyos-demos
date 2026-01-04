/**
 * 项目经验页面
 * 用于添加和编辑简历的项目经验信息,包括项目名称、担任角色、项目时间、项目描述等
 */

import { CommonHeader, RouterMap, BreakpointModel, GlobalContext } from 'common'
import { OHPage, phoneRouterControl, OHPageConfig } from 'oh_router'
import { AppStorageV2 } from '@kit.ArkUI'
import { ProjectExperienceModel, ProjectItem } from '../viewsmodel/ProjectExperienceModel'
import { CenterEditDialogParams, CenterEditDialogController } from '../comp/TextEditDialog'
import { TimePickerDialogController, TimePickerDialogParams } from '../comp/TimePickerDialog'
import { CategorySelectPageBuilder, CategorySelectParams } from '../comp/CategorySelect'
import { TextEditingBuilder, TextEditingContext } from './DescriptionEditingPage'
import { InfoRow } from '../comp/InfoRow'
import { SelectRow } from '../comp/SelectRow'
import { DateRangeRow } from '../comp/DateRangeRow'
import { UnsavedChangesDialogController } from '../comp/UnsavedChangesDialog'

@ComponentV2
export struct ProjectExperiencePage {
  @Local vm: ProjectExperienceModel = ProjectExperienceModel.instance
  @Local editingIndex: number = -1
  @Local currentEditKey: string = ''
  @Local tempEditText: string = ''
  @Local initialDraft: string = ''
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  aboutToAppear(): void {
    this.editingIndex = this.vm.editingIndex
    // 保存初始状态用于检测是否有修改
    this.initialDraft = JSON.stringify(this.vm.draft)
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render()
      },
      useSafePadding: false,
      pageConfig: new OHPageConfig({
        onBackPress: () => {
          this.handleBack()
          return true
        }
      })
    })
  }

  @Builder
  render() {
    Stack() {
      Column() {
        CommonHeader({
          title: this.vm.editingIndex === -1 ? '添加项目经验' : '编辑项目经验',
          onReturnClick: () => {
            this.handleBack()
          },
        })

        this.formSection()

        Blank()

        Row() {
          if (this.vm.editingIndex !== -1) {
            Button('删除')
              .height(44)
              .backgroundColor('#E5E7E9')
              .borderRadius(22)
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_tertiary'))
              .layoutWeight(1)
              .margin({ right: 8 })
              .onClick(() => {
                GlobalContext.getUIContext().getPromptAction().showDialog({
                  title: '提示',
                  message: '确定要删除该项目经验吗？',
                  buttons: [
                    { text: '取消', color: '#666666' },
                    { text: '删除', color: '#FF0000' }
                  ]
                }).then((result) => {
                  if (result.index === 1) {
                    this.vm.removeItem(this.vm.editingIndex)
                    phoneRouterControl.popPage()
                  }
                })
              })
          }
          Button('保存')
            .width('90%')
            .height(44)
            .backgroundColor('#0A59F7')
            .borderRadius(22)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.comp_background_list_card'))
            .layoutWeight(2)
            .onClick(() => {
              this.saveItem()
            })
        }
        .width('100%')
        .height(56)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })
    }
    .width('100%')
    .height('100%')
  }

  // 检查是否有未保存的修改
  hasUnsavedChanges(): boolean {
    const currentDraft = JSON.stringify(this.vm.draft)
    return currentDraft !== this.initialDraft
  }

  // 处理返回
  handleBack(): void {
    if (this.hasUnsavedChanges()) {
      UnsavedChangesDialogController.openDialog(GlobalContext.getUIContext(), {
        onConfirm: () => {
          phoneRouterControl.popPage()
        },
        onCancel: () => {}
      })
    } else {
      phoneRouterControl.popPage()
    }
  }

  @Builder
  formSection() {
    Column() {
      InfoRow({
        title: '项目名称',
        value: ProjectExperienceModel.instance.draft.name,
        placeholder: '请填写项目名称',
        onClickRow: () => {
          this.openCenter('name', ProjectExperienceModel.instance.draft.name)
        }
      })
      Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))

      SelectRow({
        title: '担任角色',
        value: ProjectExperienceModel.instance.draft.role,
        placeholder: '请选择担任角色',
        onClickRow: () => {
          const model = ProjectExperienceModel.instance
          const roleParams: CategorySelectParams = {
            selected: model.draft.role,
            config: {
              title: '项目角色',
              categories: model.getRoleCategories(),
              subItems: model.getRoleSubItems(),
              searchPlaceholder: '请搜索项目角色',
              showCustomInput: true,
              customInputTitle: '自定义角色',
              customInputPlaceholder: '请输入角色名称',
              freeOption: '自由职业',
              groupedDisplay: true,
              groupMapping: model.getRoleGroupMapping()
            },
            onConfirm: (val: string) => {
              this.vm.setDraftRole(val)
            }
          }
          phoneRouterControl.jumpPage({
            pageName: RouterMap.RESUME_ROLE_SELECT_PAGE,
            builder: wrapBuilder(CategorySelectPageBuilder),
            param: roleParams
          })
        }
      })
      Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))

      DateRangeRow({
        title: '项目时间',
        startDate: ProjectExperienceModel.instance.draft.startDate,
        endDate: ProjectExperienceModel.instance.draft.endDate,
        startPlaceholder: '请选择开始时间',
        endPlaceholder: '请选择结束时间',
        onStartDateClick: () => {
          this.openStartDatePicker()
        },
        onEndDateClick: () => {
          this.openEndDatePicker()
        }
      })
      Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))

      InfoRow({
        title: '项目描述',
        value: ProjectExperienceModel.instance.draft.description || '请编辑项目描述',
        isSecondary: !ProjectExperienceModel.instance.draft.description,
        onClickRow: () => {
          TextEditingContext.instance.setPageType('projectDescription')
          phoneRouterControl.jumpPage({
            pageName: RouterMap.RESUME_PROJECT_DESCRIPTION_PAGE,
            builder: wrapBuilder(TextEditingBuilder)
          })
        }
      })
      Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
    }
    .width('100%')
  }

  getDialogTitle(key: string): string {
    switch (key) {
      case 'name':
        return '项目名称'
      case 'role':
        return '项目角色'
      case 'startDate':
        return '开始时间'
      case 'endDate':
        return '结束时间'
      default:
        return '项目描述'
    }
  }

  getDialogPlaceholder(key: string): string {
    switch (key) {
      case 'name':
        return '请输入项目名称'
      case 'role':
        return '请输入项目角色'
      case 'startDate':
        return '如:2019.09'
      case 'endDate':
        return '如:2022.06'
      default:
        return '请输入项目描述'
    }
  }

  openCenter(key: string, val: string) {
    this.currentEditKey = key
    this.tempEditText = val || ''
    const params: CenterEditDialogParams = {
      title: this.getDialogTitle(key),
      placeholder: this.getDialogPlaceholder(key),
      value: this.tempEditText,
      onCancel: () => {},
      onConfirm: (v: string) => {
        this.handleCenterConfirm(v)
      }
    }
    CenterEditDialogController.openDialog(GlobalContext.getUIContext(), params)
  }

  openStartDatePicker() {
    let year = ''
    let month = ''
    if (this.vm.draft.startDate && this.vm.draft.startDate.includes('.')) {
      const parts = this.vm.draft.startDate.split('.')
      year = parts[0]
      month = parts[1]
    }
    const params: TimePickerDialogParams = {
      title: '开始时间',
      selectedYear: year,
      selectedMonth: month,
      onConfirm: (y: string, m: string) => {
        const val = `${y}.${m}`
        this.vm.setDraftStartDate(val)
      },
      onCancel: () => {}
    }
    TimePickerDialogController.openDialog(GlobalContext.getUIContext(), params)
  }

  openEndDatePicker() {
    let year = ''
    let month = ''
    if (this.vm.draft.endDate && this.vm.draft.endDate.includes('.')) {
      const parts = this.vm.draft.endDate.split('.')
      year = parts[0]
      month = parts[1]
    }
    
    // 获取开始时间用于验证
    let startYear = ''
    let startMonth = ''
    if (this.vm.draft.startDate && this.vm.draft.startDate.includes('.')) {
      const parts = this.vm.draft.startDate.split('.')
      startYear = parts[0]
      startMonth = parts[1]
    }
    
    const params: TimePickerDialogParams = {
      title: '结束时间',
      selectedYear: year,
      selectedMonth: month,
      isEndDate: true,
      startYear: startYear,
      startMonth: startMonth,
      onConfirm: (y: string, m: string) => {
        const val = y === '至今' ? '至今' : `${y}.${m}`
        this.vm.setDraftEndDate(val)
      },
      onCancel: () => {}
    }
    TimePickerDialogController.openDialog(GlobalContext.getUIContext(), params)
  }

  handleCenterConfirm(v: string) {
    const value: string = (v || '').trim()
    if (this.currentEditKey === 'name') {
      this.vm.setDraftName(value)
    } else if (this.currentEditKey === 'role') {
      this.vm.setDraftRole(value)
    } else if (this.currentEditKey === 'startDate') {
      this.vm.setDraftStartDate(value)
    } else if (this.currentEditKey === 'endDate') {
      this.vm.setDraftEndDate(value)
    } else if (this.currentEditKey === 'description') {
      this.vm.setDraftDescription(value)
    }
  }

  saveItem() {
    const item: ProjectItem = {
      name: (this.vm.draft.name || '').trim(),
      role: (this.vm.draft.role || '').trim(),
      startDate: (this.vm.draft.startDate || '').trim(),
      endDate: (this.vm.draft.endDate || '').trim(),
      description: (this.vm.draft.description || '').trim()
    }
    if (!item.name) {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '请填写项目名称' });
      return
    }
    if (!item.role) {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '请填写项目角色' });
      return
    }
    if (!item.startDate) {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '请选择开始时间' });
      return
    }
    if (!item.endDate) {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '请选择结束时间' });
      return
    }
    if (!item.description) {
      GlobalContext.getUIContext()
        .getPromptAction()
        .showToast({
          message: '请填写项目描述'
        });
      return
    }
    this.vm.commitDraft()
    GlobalContext.getUIContext().getPromptAction().showToast({ message: '保存成功' })
    // 通知 ResumePage 刷新数据
    AppStorage.setOrCreate('resumeDataUpdated', Date.now())
    phoneRouterControl.popPage()
  }
}

@Builder
export function ProjectExperiencePageBuilder() {
  ProjectExperiencePage()
}
