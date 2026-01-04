/**
 * 教育相关选择器组件集合
 * 包含学历选择对话框、日期范围选择对话框、退出确认对话框等
 */

import { ComponentContent } from '@kit.ArkUI'

export interface DegreeSelectDialogParams {
  selected: string
  onConfirm: (val: string) => void
  onCancel: () => void
}

class DegreeSelectData {
  selected: string = ''
  onConfirm: (val: string) => void = () => {
  }
  onCancel: () => void = () => {
  }

  constructor(params: DegreeSelectDialogParams) {
    this.selected = params.selected
    this.onConfirm = params.onConfirm
    this.onCancel = params.onCancel
  }
}

export class DegreeSelectDialogController {
  private static ctx: UIContext
  private static contentNode: ComponentContent<DegreeSelectData> | null = null

  static openDialog(uiContext: UIContext, params: DegreeSelectDialogParams) {
    DegreeSelectDialogController.ctx = uiContext
    const data = new DegreeSelectData(params)
    DegreeSelectDialogController.contentNode =
      new ComponentContent(uiContext, wrapBuilder(degreeSelectDialogBuilder), data)
    uiContext.getPromptAction().openCustomDialog(DegreeSelectDialogController.contentNode, {
      alignment: DialogAlignment.Center,
      autoCancel: false
    })
  }

  static closeDialog() {
    if (DegreeSelectDialogController.contentNode && DegreeSelectDialogController.ctx) {
      DegreeSelectDialogController.ctx.getPromptAction().closeCustomDialog(DegreeSelectDialogController.contentNode)
      DegreeSelectDialogController.contentNode = null
    }
  }
}

@Builder
function degreeSelectDialogBuilder(data: DegreeSelectData) {
  DegreeSelectDialog({ data: data })
}

@Builder
export function DegreeSelectDialogPageBuilder() {
  DegreeSelectDialogPage()
}

@ComponentV2
struct DegreeSelectDialogPage {
  @Local routerModule: NavPathStack = new NavPathStack()
  @Local params: DegreeSelectDialogParams = {
    selected: '',
    onConfirm: () => {
    },
    onCancel: () => {
    }
  }

  build() {
    NavDestination() {
      // 兼容旧模式
      DegreeSelectDialog({
        data: new DegreeSelectData(this.params)
      })
    }
    .hideTitleBar(true)
    .mode(NavDestinationMode.DIALOG)
    .onReady((context) => {
      this.routerModule = context.pathStack
      if (context.pathInfo.param) {
        this.params = context.pathInfo.param as DegreeSelectDialogParams
      }
    })
  }
}

@ComponentV2
struct DegreeSelectDialog {
  @Require @Param data: DegreeSelectData
  @Local selectedValue: string = ''
  private range: string[] = ['初中', '中专', '高中', '专科', '本科', '硕士研究生', '博士研究生']

  aboutToAppear(): void {
    this.selectedValue = this.data.selected || '本科'
    if (!this.range.includes(this.selectedValue)) {
      this.selectedValue = '本科'
    }
  }

  build() {
    Column() {
      Text('学历层次')
        .textAlign(TextAlign.Start)
        .fontSize(20)
        .fontWeight(FontWeight.Normal)
        .fontColor($r('sys.color.black'))
        .margin({ left: 24, top: 16, bottom: 16 })
        .width('100%')

      // TextPicker 容器
      TextPicker({ range: this.range, selected: this.range.indexOf(this.selectedValue) })
        .onChange((value: string | string[], _index: number | number[]) => {
          this.selectedValue = value as string
        })
        .defaultPickerItemHeight(48)
        .canLoop(false)
        .width('100%')
        .height(200)

      Row() {
        Row() {
          Text('取消')
            .fontSize(16)
            .fontColor('#666666')
        }
        .width('50%')
        .height(48)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.data.onCancel()
          DegreeSelectDialogController.closeDialog()
        })

        Divider().vertical(true).height(24).color('#E5E7E9')

        Row() {
          Text('确认')
            .fontSize(16)
            .fontColor('#0A59F7')
        }
        .width('50%')
        .height(48)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.data.onConfirm(this.selectedValue)
          DegreeSelectDialogController.closeDialog()
        })
      }
      .height(48)
      .width('100%')
      .border({ width: { top: 1 }, color: '#E5E7E9' })
    }
    .width(300)
    .backgroundColor(Color.White)
    .borderRadius(32)
    .padding(0)
  }
}

export interface DateSelectDialogParams {
  selectedYear: string
  selectedMonth: string
  onConfirm: (year: string, month: string) => void
  onCancel: () => void
}

@Builder
export function DateSelectDialogPageBuilder() {
  DateSelectDialogPage()
}

@ComponentV2
struct DateSelectDialogPage {
  @Local routerModule: NavPathStack = new NavPathStack()
  @Local params: DateSelectDialogParams = {
    selectedYear: '',
    selectedMonth: '',
    onConfirm: () => {
    },
    onCancel: () => {
    }
  }

  build() {
    NavDestination() {
      DateSelectDialog({ params: this.params })
    }
    .hideTitleBar(true)
    .mode(NavDestinationMode.DIALOG)
    .onReady((context) => {
      this.routerModule = context.pathStack
      if (context.pathInfo.param) {
        this.params = context.pathInfo.param as DateSelectDialogParams
      }
    })
  }
}

@ComponentV2
struct DateSelectDialog {
  @Require @Param params: DateSelectDialogParams
  @Local selectedYear: string = ''
  @Local selectedMonth: string = ''
  @Local selectedDay: string = ''
  private years: string[] = []
  private months: string[] = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']
  private days: string[] = []

  aboutToAppear(): void {
    const currentYear = new Date().getFullYear()
    const currentMonth = new Date().getMonth() + 1
    const currentDay = new Date().getDate()

    // 生成年份列表
    for (let i = 1990; i <= currentYear + 5; i++) {
      this.years.push(i.toString())
    }

    // 生成日期列表
    for (let i = 1; i <= 31; i++) {
      this.days.push(i.toString().padStart(2, '0'))
    }

    this.selectedYear = this.params.selectedYear || currentYear.toString()
    this.selectedMonth =
      this.params.selectedMonth ? this.params.selectedMonth.padStart(2, '0') : currentMonth.toString().padStart(2, '0')
    this.selectedDay = currentDay.toString().padStart(2, '0')

    if (!this.years.includes(this.selectedYear)) {
      this.selectedYear = currentYear.toString()
    }
    if (!this.months.includes(this.selectedMonth)) {
      this.selectedMonth = currentMonth.toString().padStart(2, '0')
    }
  }

  build() {
    Column() {
      Column() {
        Text('在职时间')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({ top: 20, bottom: 20 })

        TextPicker({ range: [this.years, this.months], value: [this.selectedYear, this.selectedMonth] })
          .onChange((value: string | string[], _index: number | number[]) => {
            if (Array.isArray(value)) {
              this.selectedYear = value[0]
              this.selectedMonth = value[1]
            }
          })
          .defaultPickerItemHeight(48)
          .canLoop(false)
          .layoutWeight(1)
          .width('100%')

        Row() {
          Text('取消')
            .fontSize(16)
            .fontColor('#666666')
            .onClick(() => {
              this.params.onCancel()
            })
            .width('50%')
            .textAlign(TextAlign.Center)
            .height(48)

          Divider().vertical(true).height(24).color('#E5E7E9')

          Text('确定')
            .fontSize(16)
            .fontColor('#0A59F7')
            .onClick(() => {
              this.params.onConfirm(this.selectedYear, this.selectedMonth)
            })
            .width('50%')
            .textAlign(TextAlign.Center)
            .height(48)
        }
        .height(48)
        .width('100%')
        .border({ width: { top: 1 }, color: '#E5E7E9' })
      }
      .width(300)
      .height(320)
      .backgroundColor(Color.White)
      .borderRadius(32)
      .hitTestBehavior(HitTestMode.Block)
      .onClick(() => {
      })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('rgba(0, 0, 0, 0.5)')
    .onClick(() => {
      this.params.onCancel()
    })
  }
}

export interface DateRangeSelectDialogParams {
  startDate: string
  endDate: string
  onConfirm: (startDate: string, endDate: string) => void
  onCancel: () => void
}

@Builder
export function DateRangeSelectDialogPageBuilder() {
  DateRangeSelectDialogPage()
}

@ComponentV2
struct DateRangeSelectDialogPage {
  @Local routerModule: NavPathStack = new NavPathStack()
  @Local params: DateRangeSelectDialogParams = {
    startDate: '',
    endDate: '',
    onConfirm: () => {
    },
    onCancel: () => {
    }
  }

  build() {
    NavDestination() {
      DateRangeSelectDialog({ params: this.params })
    }
    .hideTitleBar(true)
    .mode(NavDestinationMode.DIALOG)
    .onReady((context) => {
      this.routerModule = context.pathStack
      if (context.pathInfo.param) {
        this.params = context.pathInfo.param as DateRangeSelectDialogParams
      }
    })
  }
}

@ComponentV2
struct DateRangeSelectDialog {
  @Require @Param params: DateRangeSelectDialogParams
  @Local startYear: string = ''
  @Local startMonth: string = ''
  @Local startDay: string = ''
  @Local endYear: string = ''
  @Local endMonth: string = ''
  @Local endDay: string = ''
  private years: string[] = []
  private months: string[] = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']
  private days: string[] = []

  aboutToAppear(): void {
    const currentYear = new Date().getFullYear()
    const currentMonth = new Date().getMonth() + 1
    const currentDay = new Date().getDate()

    // 生成年份列表
    for (let i = 1990; i <= currentYear + 5; i++) {
      this.years.push(i.toString())
    }

    // 生成日期列表
    for (let i = 1; i <= 31; i++) {
      this.days.push(i.toString().padStart(2, '0'))
    }

    // Parse startDate (format: YYYY.MM.DD or YYYY.MM)
    if (this.params.startDate && this.params.startDate.includes('.')) {
      const parts = this.params.startDate.split('.')
      this.startYear = parts[0]
      this.startMonth = parts[1].padStart(2, '0')
      this.startDay = parts[2] ? parts[2].padStart(2, '0') : '01'
    } else {
      this.startYear = currentYear.toString()
      this.startMonth = currentMonth.toString().padStart(2, '0')
      this.startDay = currentDay.toString().padStart(2, '0')
    }

    // Parse endDate (format: YYYY.MM.DD or YYYY.MM)
    if (this.params.endDate && this.params.endDate.includes('.')) {
      const parts = this.params.endDate.split('.')
      this.endYear = parts[0]
      this.endMonth = parts[1].padStart(2, '0')
      this.endDay = parts[2] ? parts[2].padStart(2, '0') : '01'
    } else {
      this.endYear = currentYear.toString()
      this.endMonth = currentMonth.toString().padStart(2, '0')
      this.endDay = currentDay.toString().padStart(2, '0')
    }

    // 验证数据
    if (!this.years.includes(this.startYear)) {
      this.startYear = currentYear.toString()
    }
    if (!this.months.includes(this.startMonth)) {
      this.startMonth = currentMonth.toString().padStart(2, '0')
    }
    if (!this.days.includes(this.startDay)) {
      this.startDay = currentDay.toString().padStart(2, '0')
    }
    if (!this.years.includes(this.endYear)) {
      this.endYear = currentYear.toString()
    }
    if (!this.months.includes(this.endMonth)) {
      this.endMonth = currentMonth.toString().padStart(2, '0')
    }
    if (!this.days.includes(this.endDay)) {
      this.endDay = currentDay.toString().padStart(2, '0')
    }
  }

  build() {
    Column() {
      Column() {
        Text('在职时间')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ top: 20, bottom: 20 })

        Row() {
          Text('入职时间')
            .fontSize(14)
            .fontColor('#999999')
            .width('50%')
            .textAlign(TextAlign.Center)
          Text('离职时间')
            .fontSize(14)
            .fontColor('#999999')
            .width('50%')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .margin({ bottom: 8 })

        Row() {
          TextPicker({
            range: [this.years, this.months, this.days],
            value: [this.startYear, this.startMonth, this.startDay]
          })
            .onChange((value: string | string[], _index: number | number[]) => {
              if (Array.isArray(value)) {
                this.startYear = value[0]
                this.startMonth = value[1]
                this.startDay = value[2]
              }
            })
            .defaultPickerItemHeight(48)
            .canLoop(false)
            .layoutWeight(1)

          Divider()
            .vertical(true)
            .height('80%')
            .color('#E5E7E9')
            .margin({ left: 4, right: 4 })

          TextPicker({
            range: [this.years, this.months, this.days],
            value: [this.endYear, this.endMonth, this.endDay]
          })
            .onChange((value: string | string[], _index: number | number[]) => {
              if (Array.isArray(value)) {
                this.endYear = value[0]
                this.endMonth = value[1]
                this.endDay = value[2]
              }
            })
            .defaultPickerItemHeight(48)
            .canLoop(false)
            .layoutWeight(1)
        }
        .layoutWeight(1)
        .width('100%')

        Row() {
          Text('取消')
            .fontSize(16)
            .fontColor('#666666')
            .onClick(() => {
              this.params.onCancel()
            })
            .width('50%')
            .textAlign(TextAlign.Center)
            .height(48)

          Divider().vertical(true).height(24).color('#E5E7E9')

          Text('确定')
            .fontSize(16)
            .fontColor('#0A59F7')
            .onClick(() => {
              const startDate = `${this.startYear}.${this.startMonth}.${this.startDay}`
              const endDate = `${this.endYear}.${this.endMonth}.${this.endDay}`
              this.params.onConfirm(startDate, endDate)
            })
            .width('50%')
            .textAlign(TextAlign.Center)
            .height(48)
        }
        .height(48)
        .width('100%')
        .border({ width: { top: 1 }, color: '#E5E7E9' })
      }
      .width('85%')
      .constraintSize({ maxWidth: 400 })
      .height(380)
      .backgroundColor(Color.White)
      .borderRadius(32)
      .hitTestBehavior(HitTestMode.Block)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
      })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('rgba(0, 0, 0, 0.5)')
    .onClick(() => {
      this.params.onCancel()
    })
  }
}

export interface ExitConfirmDialogParams {
  onConfirm: () => void
  onCancel: () => void
}

@Builder
export function ExitConfirmDialogPageBuilder() {
  ExitConfirmDialogPage()
}

@ComponentV2
struct ExitConfirmDialogPage {
  @Local routerModule: NavPathStack = new NavPathStack()
  @Local params: ExitConfirmDialogParams = {
    onConfirm: () => {
    },
    onCancel: () => {
    }
  }

  build() {
    NavDestination() {
      ExitConfirmDialog({ params: this.params })
    }
    .hideTitleBar(true)
    .mode(NavDestinationMode.DIALOG)
    .onReady((context) => {
      this.routerModule = context.pathStack
      this.params = context.pathInfo.param as ExitConfirmDialogParams
    })
  }
}

@ComponentV2
struct ExitConfirmDialog {
  @Require @Param params: ExitConfirmDialogParams

  build() {
    Column() {
      Column() {
        Text('确认退出')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.black'))
          .margin({ top: 24, bottom: 12 })

        Text('修改内容将不会保存')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ bottom: 24 })

        Row() {
          Text('取消')
            .fontSize(16)
            .fontColor('#666666')
            .onClick(() => {
              this.params.onCancel()
            })
            .width('50%')
            .textAlign(TextAlign.Center)
            .height(48)

          Divider().vertical(true).height(24).color('#E5E7E9')

          Text('确认')
            .fontSize(16)
            .fontColor('#0A59F7')
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              this.params.onConfirm()
            })
            .width('50%')
            .textAlign(TextAlign.Center)
            .height(48)
        }
        .height(48)
        .width('100%')
        .border({ width: { top: 1 }, color: '#E5E7E9' })
      }
      .width(280)
      .backgroundColor(Color.White)
      .borderRadius(32)
      .hitTestBehavior(HitTestMode.Block)
      .onClick(() => {
      })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('rgba(0, 0, 0, 0.5)')
    .onClick(() => {
      this.params.onCancel()
    })
  }
}
