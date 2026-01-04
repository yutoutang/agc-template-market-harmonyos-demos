/**
 * 通用时间选择对话框
 * 支持年月选择，可自定义标题
 * 用于工作经历、项目经验、教育背景等场景
 */
import { promptAction, ComponentContent } from '@kit.ArkUI'

export interface TimePickerDialogParams {
  title?: string // 对话框标题，默认为"选择时间"
  selectedYear: string
  selectedMonth: string
  isEndDate?: boolean // 是否为结束时间选择器，如果是true则显示"至今"选项
  startYear?: string // 开始时间的年份（用于验证结束时间）
  startMonth?: string // 开始时间的月份（用于验证结束时间）
  onConfirm: (year: string, month: string) => void
  onCancel: () => void
}

class TimePickerData {
  title: string = '选择时间'
  selectedYear: string = ''
  selectedMonth: string = ''
  isEndDate: boolean = false
  startYear: string = ''
  startMonth: string = ''
  onConfirm: (year: string, month: string) => void = () => {
  }
  onCancel: () => void = () => {
  }

  constructor(params: TimePickerDialogParams) {
    this.title = params.title || '选择时间'
    this.selectedYear = params.selectedYear
    this.selectedMonth = params.selectedMonth
    this.isEndDate = params.isEndDate || false
    this.startYear = params.startYear || ''
    this.startMonth = params.startMonth || ''
    this.onConfirm = params.onConfirm
    this.onCancel = params.onCancel
  }
}

export class TimePickerDialogController {
  private static ctx: UIContext
  private static contentNode: ComponentContent<TimePickerData> | null = null

  static openDialog(uiContext: UIContext, params: TimePickerDialogParams) {
    TimePickerDialogController.ctx = uiContext
    const data = new TimePickerData(params)
    TimePickerDialogController.contentNode = new ComponentContent(uiContext, wrapBuilder(timePickerDialogBuilder), data)
    uiContext.getPromptAction().openCustomDialog(TimePickerDialogController.contentNode, {
      alignment: DialogAlignment.Center,
      autoCancel: false
    })
  }

  static closeDialog() {
    if (TimePickerDialogController.contentNode && TimePickerDialogController.ctx) {
      TimePickerDialogController.ctx.getPromptAction().closeCustomDialog(TimePickerDialogController.contentNode)
      TimePickerDialogController.contentNode = null
    }
  }
}

@Builder
function timePickerDialogBuilder(data: TimePickerData) {
  TimePickerDialogContent({ data: data })
}

@ComponentV2
struct TimePickerDialogContent {
  @Require @Param data: TimePickerData
  @Local selectedYear: string = ''
  @Local selectedMonth: string = ''
  @Local isPresent: boolean = false
  @Local years: string[] = []
  @Local months: string[] = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']
  private allYears: string[] = []

  aboutToAppear(): void {
    const currentYear = new Date().getFullYear()
    const currentMonth = new Date().getMonth() + 1

    for (let i = 1990; i <= currentYear; i++) {
      this.allYears.push(i.toString())
    }

    if (this.data.isEndDate) {
      this.months.push('至今')
    }

    this.isPresent = this.data.selectedYear === '至今'

    if (this.isPresent) {
      this.years = [...this.allYears, ' ']
      this.selectedYear = ' '
      this.selectedMonth = '至今'
    } else {
      this.years = [...this.allYears]
      this.selectedYear = this.data.selectedYear || currentYear.toString()
      this.selectedMonth = this.data.selectedMonth ?
      this.data.selectedMonth.padStart(2, '0') :
      currentMonth.toString().padStart(2, '0')
    }

    if (!this.isPresent && !this.years.includes(this.selectedYear)) {
      this.selectedYear = currentYear.toString()
    }

    if (!this.months.includes(this.selectedMonth)) {
      this.selectedMonth = this.data.isEndDate ? '至今' : currentMonth.toString().padStart(2, '0')
    }
  }

  build() {
    Column() {
      Text(this.data.title)
        .textAlign(TextAlign.Start)
        .fontSize(20)
        .fontWeight(700)
        .fontColor($r('sys.color.black'))
        .padding({ left: 24, top: 16, bottom: 16 })
        .width('100%')

      TextPicker({
        range: [this.years, this.months],
        value: [this.selectedYear, this.selectedMonth]
      })
        .divider({ color: 'rgba(0, 0, 0, 0.10)' })
        .onChange((value: string | string[], _index: number | number[]) => {
          if (Array.isArray(value)) {
            const newYear = value[0]
            const newMonth = value[1]

            if (newMonth === '至今' && this.selectedMonth !== '至今') {
              this.isPresent = true
              this.years = [...this.allYears, ' ']
              this.selectedYear = ' '
              this.selectedMonth = '至今'
              return
            }

            if (this.selectedMonth === '至今' && newMonth !== '至今') {
              this.isPresent = false
              this.years = [...this.allYears]
              this.selectedYear = new Date().getFullYear().toString()
              this.selectedMonth = newMonth
              return
            }

            if (this.isPresent && newYear !== ' ') {
              this.isPresent = false
              this.years = [...this.allYears]
              this.selectedYear = newYear
              this.selectedMonth = '01'
              return
            }

            this.selectedYear = newYear
            this.selectedMonth = newMonth
          }
        })
        .defaultPickerItemHeight(36)
        .canLoop(false)
        .height(180)
        .width('80%')

      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor('#666666')
          .onClick(() => {
            this.data.onCancel()
            TimePickerDialogController.closeDialog()
          })
          .width('50%')
          .textAlign(TextAlign.Center)
          .height(48)

        Divider().vertical(true).height(24).color('#E5E7E9')

        Text('确定')
          .fontSize(16)
          .fontColor('#0A59F7')
          .onClick(() => {
            if (this.data.isEndDate && !this.isPresent && this.data.startYear && this.data.startMonth) {
              const startDate = parseInt(this.data.startYear) * 100 + parseInt(this.data.startMonth)
              const endDate = parseInt(this.selectedYear) * 100 + parseInt(this.selectedMonth)

              if (endDate < startDate) {
                promptAction.showToast({
                  message: '结束时间不能早于开始时间',
                  duration: 1500
                })
                return
              }
            }

            if (this.isPresent) {
              this.data.onConfirm('至今', '')
            } else {
              this.data.onConfirm(this.selectedYear, this.selectedMonth)
            }
            TimePickerDialogController.closeDialog()
          })
          .width('50%')
          .textAlign(TextAlign.Center)
          .height(48)
      }
      .height(48)
      .width('100%')
      .border({ width: { top: 1 }, color: '#E5E7E9' })
      .margin({ top: 16 })
    }
    .width(300)
    .backgroundColor(Color.White)
    .borderRadius(32)
    .padding({ bottom: 0 })
  }
}

