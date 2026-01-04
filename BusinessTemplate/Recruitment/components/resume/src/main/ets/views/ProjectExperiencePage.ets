import { BarVM, CommonHeader, RouterMap } from 'common'
import { OHPage, phoneRouterControl, OHPageConfig } from 'oh_router'
import { ProjectExperienceModel, ProjectItem } from '../viewsmodel/ProjectExperienceModel'
import { CenterEditDialogParams, CenterEditDialogPageBuilder } from '../comp/CenterEditDialog'
import { DateRangeSelectDialogPageBuilder, DateRangeSelectDialogParams } from 'job_intention'
import { TimePickerDialogController, TimePickerDialogParams } from '../comp/TimePickerDialog'
import { TextEditingBuilder, TextEditingContext } from '../comp/TextDescriptionEditing'
import { InfoRow } from '../comp/InfoRow'
import { TextInputRow } from '../comp/TextInputRow'
import { SelectRow } from '../comp/SelectRow'
import { DateRangeRow } from '../comp/DateRangeRow'
import { UnsavedChangesDialog, UnsavedChangesDialogController } from 'job_intention'
import { promptAction } from '@kit.ArkUI'
import { CategorySelectPageBuilder, CategorySelectParams } from 'job_intention'
import { CenterEditDialogController } from '../comp/TextEditDialog'

@Builder
export function ProjectExperiencePageBuilder() {
  ProjectExperiencePage()
}

@ComponentV2
export struct ProjectExperiencePage {
  @Local vm: ProjectExperienceModel = ProjectExperienceModel.instance
  @Local editingIndex: number = -1
  @Local dialogStack: NavPathStack = new NavPathStack()
  @Local dialogOpen: boolean = false
  @Local currentEditKey: string = ''
  @Local tempEditText: string = ''
  @Local showExitDialog: boolean = false
  @Local initialDraft: string = ''

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
      useSafePadding: true,
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
                this.vm.removeItem(this.vm.editingIndex)
                phoneRouterControl.popPage()
              })
          }
          Button('保存')
            .width('90%')
            .height(44)
            .backgroundColor('#0A59F7')
            .borderRadius(22)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_on_primary'))
            .layoutWeight(2)
            .onClick(() => {
              this.saveItem()
            })
        }
        .width('100%')
        .height(56)
        .justifyContent(FlexAlign.Center)
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .height('100%')

      Navigation(this.dialogStack) {
      }
      .width('100%')
      .height('100%')
      .hideTitleBar(true)
      .hideNavBar(true)
      .navDestination(this.dialogDestination)
      .hitTestBehavior(this.dialogOpen ? HitTestMode.Default : HitTestMode.None)

      // 未保存更改确认弹窗
      UnsavedChangesDialog({
        visible: this.showExitDialog,
        onConfirm: () => {
          this.showExitDialog = false
          phoneRouterControl.popPage()
        },
        onCancel: () => {
          this.showExitDialog = false
        }
      })
    }
    .width('100%')
    .height('100%')
    .padding({
      top: BarVM.instance.staBarH,
      bottom: BarVM.instance.aiBarH
    })
  }

  // 检查是否有未保存的修改
  hasUnsavedChanges(): boolean {
    const currentDraft = JSON.stringify(this.vm.draft)
    return currentDraft !== this.initialDraft
  }

  // 处理返回
  handleBack(): void {
    if (this.hasUnsavedChanges()) {
      UnsavedChangesDialogController.openDialog(this.getUIContext(), {
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
  dialogDestination(name: string, _param: string) {
  if (name === 'DateRangeSelectDialog') {
      wrapBuilder(DateRangeSelectDialogPageBuilder).builder()
    }
  }

  @Builder
  formSection() {
    Column() {
      TextInputRow({
        title: '项目名称',
        value: ProjectExperienceModel.instance.draft.name,
        placeholder: '请填写项目名称',
        isDraftPosition:true,
        onClickRow: () => {
          this.openCenter('name', ProjectExperienceModel.instance.draft.name)
        }
      })
      Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))

      SelectRow({
        title: '担任角色',
        value: ProjectExperienceModel.instance.draft.role,
        placeholder: '请选择担任角色',
        isDraftPosition:true,
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
        isDraftPosition:true,
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
        return '如：2019.09'
      case 'endDate':
        return '如：2022.06'
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
      onCancel: () => {

      },
      onConfirm: (v: string) => {
        this.handleCenterConfirm(v);

      }
    }
    CenterEditDialogController.openDialog(this.getUIContext(), params)

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
        if (this.vm.draft.endDate) {

          const startDate = new Date(y + '.' + m).getTime()
          const endDate = new Date(this.vm.draft.endDate).getTime()

          if (endDate < startDate) {
            promptAction.showToast({
              message: '结束时间不能早于开始时间',
              duration: 1500
            })
            return
          }
        }
        const val = `${y}.${m}`
        this.vm.setDraftStartDate(val)

      },
      onCancel: () => {
      }
    }
    TimePickerDialogController.openDialog(this.getUIContext(), params)
  }

  openEndDatePicker() {
    let year = ''
    let month = ''
    if (this.vm.draft.endDate && this.vm.draft.endDate.includes('.')) {
      const parts = this.vm.draft.endDate.split('.')
      year = parts[0]
      month = parts[1]
    }
    const params: TimePickerDialogParams = {
      title: '结束时间',
      selectedYear: year,
      selectedMonth: month,
      isEndDate: true,
      onConfirm: (y: string, m: string) => {
        if (this.vm.draft.startDate) {

          const startDate = new Date(this.vm.draft.startDate).getTime()
          const endDate = new Date(y + '.' + m).getTime()

          if (endDate < startDate) {
            promptAction.showToast({
              message: '结束时间不能早于开始时间',
              duration: 1500
            })
            return
          }
        }
        const val = y === '至今' ? '至今' : `${y}.${m}`
        this.vm.setDraftEndDate(val)

      },
      onCancel: () => {

      }
    }
    TimePickerDialogController.openDialog(this.getUIContext(), params)
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
      this.getUIContext().getPromptAction().showToast({ message: '请填写项目名称' });
      return
    }
    if (!item.role) {
      this.getUIContext().getPromptAction().showToast({ message: '请填写项目角色' });
      return
    }
    if (!item.startDate) {
      this.getUIContext().getPromptAction().showToast({ message: '请选择开始时间' });
      return
    }
    if (!item.endDate) {
      this.getUIContext().getPromptAction().showToast({ message: '请选择结束时间' });
      return
    }
    if (!item.description) {
      this.getUIContext()
        .getPromptAction()
        .showToast({
          message: '请填写项目描述'
        });
      return
    }
    this.vm.commitDraft()
    this.getUIContext().getPromptAction().showToast({ message: '保存成功' })
    phoneRouterControl.popPage()
  }
}
