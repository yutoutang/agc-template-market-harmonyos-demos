import { CommonHeader, BarVM } from 'common'
import { OHPage, phoneRouterControl, OHPageConfig } from 'oh_router'
import { EducationalBackgroundModel, EducationItem } from '../viewsmodel/EducationalBackgroundModel'
import { CenterEditDialogParams, CenterEditDialogPageBuilder } from '../comp/CenterEditDialog'
import {
  DegreeSelectDialogParams,
  ExitConfirmDialogParams,
  ExitConfirmDialogPageBuilder,
  CommonSingleDialogController
} from 'job_intention'
import { TimePickerDialogController, TimePickerDialogParams } from '../comp/TimePickerDialog'
import { InfoRow } from '../comp/InfoRow'
import { TextInputRow } from '../comp/TextInputRow'
import { DateRangeRow } from '../comp/DateRangeRow'
import { UnsavedChangesDialog, UnsavedChangesDialogController } from 'job_intention'
import { promptAction } from '@kit.ArkUI'
import { CenterEditDialogController } from '../comp/TextEditDialog'

@Builder
export function EducationalBackgroundPageBuilder() {
  EducationalBackgroundPage()
}

@ComponentV2
export struct EducationalBackgroundPage {
  @Local vm: EducationalBackgroundModel = EducationalBackgroundModel.instance
  @Local editingIndex: number = -1
  @Local dialogStack: NavPathStack = new NavPathStack()
  @Local dialogOpen: boolean = false
  @Local currentEditKey: string = ''
  @Local tempEditText: string = ''
  @Local initialTemp: string = '' // Store initial JSON string to check for changes
  @Local showExitDialog: boolean = false

  aboutToAppear(): void {
    this.editingIndex = this.vm.editingIndex
    this.initialTemp = JSON.stringify(this.vm.draft)
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render()
      },
      useSafePadding: true,
      pageConfig: new OHPageConfig({
        onBackPress: () => {
          return this.checkUnsavedAndExit()
        }
      })
    })
  }

  @Builder
  render() {
    Stack() {
      Column() {
        CommonHeader({
          title: this.vm.editingIndex === -1 ? '添加教育背景' : '编辑教育背景',
          onReturnClick: () => {
            this.checkUnsavedAndExit()
          },
        })

        this.formSection()

        Blank()

        Row() {
          if (this.vm.editingIndex !== -1) {
            Button('删除')
              .width('44%')
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
        .justifyContent(this.editingIndex !== -1 ? FlexAlign.SpaceBetween : FlexAlign.Center)
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

  @Builder
  dialogDestination(name: string, _param: string) {
    if (name === 'ExitConfirmDialog') {
      wrapBuilder(ExitConfirmDialogPageBuilder).builder()
    }
  }

  @Builder
  formSection() {
    Column() {
      TextInputRow({
        title: '学校名称',
        value: this.vm.draft.school,
        isDraftPosition: true,
        placeholder: '请填写学校名称',
        onClickRow: () => {
          this.openCenter('school', this.vm.draft.school)
        }
      })
      Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
      TextInputRow({
        title: '专业名称',
        value: this.vm.draft.major,
        placeholder: '请选择专业名称',
        isDraftPosition: true,
        onClickRow: () => {
          this.openCenter('major', this.vm.draft.major)
        }
      })
      Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
      InfoRow({
        title: '学历层次',
        value: this.vm.draft.degree || '请选择学历层次',
        isSecondary: !this.vm.draft.degree,
        isDraftPosition: true,
        onClickRow: () => {
          this.openDegreeDialog()
        }
      })
      Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))

      DateRangeRow({
        title: '在校时间',
        startDate: this.vm.draft.startDate,
        endDate: this.vm.draft.endDate,
        startPlaceholder: '请选择开始时间',
        endPlaceholder: '请选择毕业时间',
        onStartDateClick: () => {
          this.openDateDialog('start')
        },
        onEndDateClick: () => {
          this.openDateDialog('end')
        }
      })
      Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
    }
    .width('100%')
  }

  checkUnsavedAndExit(): boolean {
    if (JSON.stringify(this.vm.draft) !== this.initialTemp) {
      UnsavedChangesDialogController.openDialog(this.getUIContext(), {
        onConfirm: () => {
          phoneRouterControl.popPage()
        },
        onCancel: () => {
        }
      })
      return true
    } else {
      phoneRouterControl.popPage()
      return true
    }
  }

  openDegreeDialog() {
    const params: DegreeSelectDialogParams = {
      selected: this.vm.draft.degree || '本科',
      title: '学历层次',
      range: ['初中', '中专', '高中', '专科', '本科', '硕士研究生', '博士研究生'],
      onConfirm: (val: string) => {
        this.vm.setDraftDegree(val)
      },
      onCancel: () => {
      }
    }
    CommonSingleDialogController.openDialog(this.getUIContext(), params)

  }

  openDateDialog(type: 'start' | 'end') {
    let currentVal = type === 'start' ? this.vm.draft.startDate : this.vm.draft.endDate
    let year = ''
    let month = ''
    if (currentVal && currentVal.includes('.')) {
      const parts = currentVal.split('.')
      year = parts[0]
      month = parts[1]
    }

    const params: TimePickerDialogParams = {
      title: type === 'start' ? '入学时间' : '毕业时间',
      selectedYear: year,
      selectedMonth: month,
      isEndDate: type === 'end',
      onConfirm: (y: string, m: string) => {

        const val = y === '至今' ? '至今' : `${y}.${m}`
        if (type === 'start') {
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
          this.vm.setDraftStartDate(val)
        } else {
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
        }

      },
      onCancel: () => {

      }
    }
    TimePickerDialogController.openDialog(this.getUIContext(), params)
  }

  openCenter(key:
    string, val:
    string
  ) {
    this.currentEditKey = key
    this.tempEditText = val || ''
    const params: CenterEditDialogParams = {
      title: key === 'school' ? '学校名称' : '专业名称',
      placeholder: key === 'school' ? '请输入学校名称' : '请输入专业名称',
      value: this.tempEditText,
      onCancel: () => {

      },
      onConfirm: (v: string) => {
        this.handleCenterConfirm(v);
      }
    }
    CenterEditDialogController.openDialog(this.getUIContext(), params)

  }

  handleCenterConfirm(value:
    string
  ) {
    if (this.currentEditKey === 'school') {
      this.vm.setDraftSchool(value)
    } else if (this.currentEditKey === 'major') {
      this.vm.setDraftMajor(value)
    }
  }

  saveItem() {
    if (!this.vm.draft.school) {
      this.getUIContext().getPromptAction().showToast({ message: '请输入学校名称' })
      return
    }
    this.vm.commitDraft()
    phoneRouterControl.popPage()
  }
}
