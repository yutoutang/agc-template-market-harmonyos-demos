/**
 * 教育背景页面
 * 用于添加和编辑简历的教育背景信息,包括学校名称、专业、学历、在校时间等
 */

import { CommonHeader, BreakpointModel, GlobalContext } from 'common'
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router'
import { AppStorageV2 } from '@kit.ArkUI'
import { EducationalBackgroundModel } from '../viewsmodel/EducationalBackgroundModel'
import { CenterEditDialogController, CenterEditDialogParams } from '../comp/TextEditDialog'
import {
  DegreeSelectDialogController,
  DegreeSelectDialogParams
} from '../comp/EducationPickers'
import { TimePickerDialogController, TimePickerDialogParams } from '../comp/TimePickerDialog'
import { InfoRow } from '../comp/InfoRow'
import { DateRangeRow } from '../comp/DateRangeRow'
import { UnsavedChangesDialogController } from '../comp/UnsavedChangesDialog'

@ComponentV2
export struct EducationalBackgroundPage {
  @Local vm: EducationalBackgroundModel = EducationalBackgroundModel.instance
  @Local editingIndex: number = -1
  @Local currentEditKey: string = ''
  @Local tempEditText: string = ''
  @Local initialTemp: string = '' // Store initial JSON string to check for changes
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  aboutToAppear(): void {
    this.editingIndex = this.vm.editingIndex
    this.initialTemp = JSON.stringify(this.vm.draft)
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render()
      },
      useSafePadding: false,
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
                GlobalContext.getUIContext().getPromptAction().showDialog({
                  title: '提示',
                  message: '确定要删除该教育背景吗？',
                  buttons: [
                    { text: '取消', color: '#666666' },
                    { text: '删除', color: '#FF0000' }
                  ]
                }).then((result) => {
                  if (result.index === 1) {
                    this.vm.removeItem(this.vm.editingIndex)
                    AppStorage.setOrCreate('resumeDataUpdated', Date.now())
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
        .justifyContent(this.editingIndex !== -1 ? FlexAlign.SpaceBetween : FlexAlign.Center)
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

  @Builder
  formSection() {
    Column() {
      InfoRow({
        title: '学校名称',
        value: this.vm.draft.school,
        placeholder: '请填写学校名称',
        isRequired: true,
        onClickRow: () => {
          this.openCenter('school', this.vm.draft.school)
        }
      })
      Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
      InfoRow({
        title: '专业名称',
        value: this.vm.draft.major,
        placeholder: '请选择专业名称',
        onClickRow: () => {
          this.openCenter('major', this.vm.draft.major)
        }
      })
      Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
      InfoRow({
        title: '学历层次',
        value: this.vm.draft.degree || '请选择学历层次',
        isSecondary: !this.vm.draft.degree,
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
      UnsavedChangesDialogController.openDialog(GlobalContext.getUIContext(), {
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
      onConfirm: (val: string) => {
        this.vm.setDraftDegree(val)
      },
      onCancel: () => {
      }
    }
    DegreeSelectDialogController.openDialog(GlobalContext.getUIContext(), params)
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

    // 获取开始时间用于验证（仅在选择结束时间时需要）
    let startYear = ''
    let startMonth = ''
    if (type === 'end' && this.vm.draft.startDate && this.vm.draft.startDate.includes('.')) {
      const parts = this.vm.draft.startDate.split('.')
      startYear = parts[0]
      startMonth = parts[1]
    }

    const params: TimePickerDialogParams = {
      title: type === 'start' ? '入学时间' : '毕业时间',
      selectedYear: year,
      selectedMonth: month,
      isEndDate: type === 'end',
      startYear: startYear,
      startMonth: startMonth,
      onConfirm: (y: string, m: string) => {
        const val = y === '至今' ? '至今' : `${y}.${m}`
        if (type === 'start') {
          this.vm.setDraftStartDate(val)
        } else {
          this.vm.setDraftEndDate(val)
        }
      },
      onCancel: () => {
      }
    }
    TimePickerDialogController.openDialog(GlobalContext.getUIContext(), params)
  }

  openCenter(key: string, val: string) {
    this.currentEditKey = key
    this.tempEditText = val || ''
    const params: CenterEditDialogParams = {
      title: key === 'school' ? '学校名称' : '专业名称',
      placeholder: key === 'school' ? '请输入学校名称' : '请输入专业名称',
      value: this.tempEditText,
      onCancel: () => {
      },
      onConfirm: (v: string) => {
        this.handleCenterConfirm(v)
      }
    }
    CenterEditDialogController.openDialog(GlobalContext.getUIContext(), params)
  }

  handleCenterConfirm(value: string) {
    if (this.currentEditKey === 'school') {
      this.vm.setDraftSchool(value)
    } else if (this.currentEditKey === 'major') {
      this.vm.setDraftMajor(value)
    }
  }

  saveItem() {
    if (!this.vm.draft.school) {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '请输入学校名称' })
      return
    }
    this.vm.commitDraft()
    AppStorage.setOrCreate('resumeDataUpdated', Date.now())
    phoneRouterControl.popPage()
  }
}

@Builder
export function EducationalBackgroundPageBuilder() {
  EducationalBackgroundPage()
}
