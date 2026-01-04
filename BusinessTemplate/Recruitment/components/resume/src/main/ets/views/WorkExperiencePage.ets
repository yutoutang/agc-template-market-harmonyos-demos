import { CommonHeader, RouterMap, BreakpointModel, BarVM } from 'common'
import { OHPage, phoneRouterControl, OHPageConfig } from 'oh_router'
import { WorkExperienceModel, WorkItem } from '../viewsmodel/WorkExperienceModel'
import { CenterEditDialogParams, CenterEditDialogPageBuilder } from '../comp/CenterEditDialog'
import { DateRangeSelectDialogPageBuilder } from 'job_intention'
import { TimePickerDialogController, TimePickerDialogParams } from '../comp/TimePickerDialog'
import { TextEditingBuilder, TextEditingContext } from '../comp/TextDescriptionEditing'
import { InfoRow } from '../comp/InfoRow'
import { TextInputRow } from '../comp/TextInputRow'
import { SelectRow } from '../comp/SelectRow'
import { DateRangeRow } from '../comp/DateRangeRow'
import { UnsavedChangesDialog, UnsavedChangesDialogController } from 'job_intention'
import { AppStorageV2, promptAction } from '@kit.ArkUI'
import {
  CategorySelectPageBuilder,
  CategorySelectParams,
  IndustrySelectPageBuilder,
  IndustrySelectParams
} from 'job_intention'
import { CenterEditDialogController } from '../comp/TextEditDialog'

@Builder
export function WorkExperiencePageBuilder() {
  WorkExperiencePage()
}

@ComponentV2
export struct WorkExperiencePage {
  @Local vm: WorkExperienceModel = WorkExperienceModel.instance
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local editingIndex: number = -1
  @Local dialogStack: NavPathStack = new NavPathStack()
  @Local dialogOpen: boolean = false
  @Local currentEditKey: string = ''
  @Local tempEditText: string = ''
  @Local forceUpdate: number = 0
  @Local initialDraft: string = ''

  aboutToAppear(): void {
    this.editingIndex = this.vm.editingIndex
    // 设置AppStorage标记，标识当前是工作经历页面
    AppStorage.setOrCreate('lastEditPage', 'work')
    // 保存初始状态用于检测是否有修改
    this.initialDraft = JSON.stringify(this.vm.draft)
  }

  onPageShow(): void {
    // 关键：重新赋值vm，强制建立响应式连接
    this.vm = WorkExperienceModel.instance
    // 强制触发UI刷新
    this.forceUpdate++
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
        // 关键：每次页面显示时强制刷新ViewModel
        Blank()
          .height(0)
          .visibility(Visibility.None)
          .onAppear(() => {
            // 重新赋值vm，强制建立响应式连接
            const instance = WorkExperienceModel.instance
            // 强制同步单例数据到本地vm
            this.vm = instance
            this.forceUpdate++
          })

        CommonHeader({
          title: this.vm.editingIndex === -1 ? '添加工作经历' : '编辑工作经历',
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
        onCancel: () => {
        }
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
      // 🔑 关键：强制UI重新渲染的触发器
      Text(`${this.forceUpdate}`)
        .height(0)
        .width(0)
        .visibility(Visibility.None)

      TextInputRow({
        title: '公司名称',
        value: WorkExperienceModel.instance.draft.company,
        placeholder: '请填写公司名称',
        isDraftPosition: true,
        onClickRow: () => {
          this.openCenter('company', WorkExperienceModel.instance.draft.company)
        }
      })
      Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))

      SelectRow({
        title: '职位名称',
        value: WorkExperienceModel.instance.draft.position,
        placeholder: '请选择职位名称',
        isDraftPosition: true,
        onClickRow: () => {
          const model = WorkExperienceModel.instance
          const posParams: CategorySelectParams = {
            selected: model.draft.position,
            config: {
              title: '职位名称',
              categories: model.getPositionCategories(),
              subItems: model.getPositionSubItems(),
              searchPlaceholder: '请搜索职位',
              showCustomInput: true,
              customInputTitle: '自定义职位',
              customInputPlaceholder: '请输入职位名称',
              freeOption: '自由职业',
              groupedDisplay: true,
              groupMapping: model.getPositionGroupMapping(),
              textMax: 12
            },
            onConfirm: (val: string) => {
              this.vm.setDraftPosition(val)
            }
          }
          phoneRouterControl.jumpPage({
            pageName: RouterMap.RESUME_POSITION_SELECT_PAGE,
            builder: wrapBuilder(CategorySelectPageBuilder),
            param: posParams
          })
        }
      })
      Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))

      InfoRow({
        title: '所属行业',
        value: WorkExperienceModel.instance.draft.industry || '请选择所属行业',
        isSecondary: !WorkExperienceModel.instance.draft.industry,
        isDraftPosition: true,
        onClickRow: () => {
          const indParams: IndustrySelectParams = {
            selected: WorkExperienceModel.instance.draft.industry ?
            WorkExperienceModel.instance.draft.industry.split(',') : [],
            onConfirm: (val: string[]) => {
              this.vm.setDraftIndustry(val.join(','))
            }
          }
          phoneRouterControl.jumpPage({
            pageName: RouterMap.RESUME_INDUSTRY_SELECT_PAGE,
            builder: wrapBuilder(IndustrySelectPageBuilder),
            param: indParams
          })
        }
      })
      Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))

      DateRangeRow({
        title: '在职时间',
        startDate: WorkExperienceModel.instance.draft.startDate,
        endDate: WorkExperienceModel.instance.draft.endDate,
        startPlaceholder: '请选择入职时间',
        endPlaceholder: '请选择离职时间',
        onStartDateClick: () => {
          this.openStartDatePicker()
        },
        onEndDateClick: () => {
          this.openEndDatePicker()
        }
      })
      Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))

      InfoRow({
        title: '工作经历',
        value: WorkExperienceModel.instance.draft.description || '请填写工作经历',
        isSecondary: !WorkExperienceModel.instance.draft.description,
        isDraftPosition: true,
        onClickRow: () => {
          TextEditingContext.instance.setPageType('workDescription')
          phoneRouterControl.jumpPage({
            pageName: RouterMap.RESUME_WORK_DESCRIPTION_PAGE,
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
      case 'company':
        return '公司名称'
      case 'position':
        return '职位名称'
      case 'industry':
        return '所属行业'
      case 'startDate':
        return '入职时间'
      case 'endDate':
        return '离职时间'
      default:
        return '工作描述'
    }
  }

  getDialogPlaceholder(key: string): string {
    switch (key) {
      case 'company':
        return '请填写公司名称'
      case 'position':
        return '请填写职位名称'
      case 'industry':
        return '请填写所属行业'
      case 'startDate':
        return '如：2019.09'
      case 'endDate':
        return '如：2022.06'
      default:
        return '请输入工作描述'
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
      title: '入职时间',
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
      title: '离职时间',
      selectedYear: year,
      selectedMonth: month,
      isEndDate: true,
      onConfirm: (y: string, m: string) => {
        const val = y === '至今' ? '至今' : `${y}.${m}`
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
        this.vm.setDraftEndDate(val)
      },
      onCancel: () => {
      }
    }
    TimePickerDialogController.openDialog(this.getUIContext(), params)
  }

  handleCenterConfirm(v: string) {
    const value: string = (v || '').trim()
    if (this.currentEditKey === 'company') {
      this.vm.setDraftCompany(value)
    } else if (this.currentEditKey === 'position') {
      this.vm.setDraftPosition(value)
    } else if (this.currentEditKey === 'industry') {
      this.vm.setDraftIndustry(value)
    } else if (this.currentEditKey === 'startDate') {
      this.vm.setDraftStartDate(value)
    } else if (this.currentEditKey === 'endDate') {
      this.vm.setDraftEndDate(value)
    } else if (this.currentEditKey === 'description') {
      this.vm.setDraftDescription(value)
    }
  }

  saveItem() {
    const item: WorkItem = {
      company: (this.vm.draft.company || '').trim(),
      position: (this.vm.draft.position || '').trim(),
      industry: (this.vm.draft.industry || '').trim(),
      startDate: (this.vm.draft.startDate || '').trim(),
      endDate: (this.vm.draft.endDate || '').trim(),
      description: (this.vm.draft.description || '').trim()
    }
    if (!item.company) {
      this.getUIContext().getPromptAction().showToast({ message: '请填写公司名称' });
      return
    }
    if (!item.position) {
      this.getUIContext().getPromptAction().showToast({ message: '请填写职位名称' });
      return
    }
    if (!item.industry) {
      this.getUIContext().getPromptAction().showToast({ message: '请填写所属行业' });
      return
    }
    if (!item.startDate) {
      this.getUIContext().getPromptAction().showToast({ message: '请选择入职时间' });
      return
    }
    if (!item.endDate) {
      this.getUIContext().getPromptAction().showToast({ message: '请选择离职时间' });
      return
    }
    if (!item.description) {
      this.getUIContext().getPromptAction().showToast({ message: '请填写工作描述' });
      return
    }
    this.vm.commitDraft()
    this.getUIContext().getPromptAction().showToast({ message: '保存成功' })
    phoneRouterControl.popPage()
  }
}
