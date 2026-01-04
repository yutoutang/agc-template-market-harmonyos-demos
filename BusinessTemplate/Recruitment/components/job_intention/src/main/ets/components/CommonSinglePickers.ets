import { ComponentContent, LengthMetrics } from '@kit.ArkUI'

export interface DegreeSelectDialogParams {
  selected: string
  onConfirm: (val: string) => void
  onCancel: () => void
  range: string[]
  title: string
}

class DegreeSelectData {
  selected: string = ''
  onConfirm: (val: string) => void = () => {
  }
  onCancel: () => void = () => {
  }
  range: string[] = []
  title: string = ''

  constructor(params: DegreeSelectDialogParams) {
    this.selected = params.selected
    this.onConfirm = params.onConfirm
    this.onCancel = params.onCancel
    this.range = params.range
    this.title = params.title
  }
}

export class CommonSingleDialogController {
  private static ctx: UIContext
  private static contentNode: ComponentContent<DegreeSelectData> | null = null

  static openDialog(uiContext: UIContext, params: DegreeSelectDialogParams) {
    CommonSingleDialogController.ctx = uiContext
    const data = new DegreeSelectData(params)
    CommonSingleDialogController.contentNode =
      new ComponentContent(uiContext, wrapBuilder(degreeSelectDialogBuilder), data)
    uiContext.getPromptAction().openCustomDialog(CommonSingleDialogController.contentNode, {
      alignment: DialogAlignment.Center,
      autoCancel: false
    })
  }

  static closeDialog() {
    if (CommonSingleDialogController.contentNode && CommonSingleDialogController.ctx) {
      CommonSingleDialogController.ctx.getPromptAction().closeCustomDialog(CommonSingleDialogController.contentNode)
      CommonSingleDialogController.contentNode = null
    }
  }
}

@Builder
function degreeSelectDialogBuilder(data: DegreeSelectData) {
  DegreeSelectDialog({ data: data })
}

@ComponentV2
struct DegreeSelectDialog {
  @Require @Param data: DegreeSelectData
  @Local selectedValue: string = ''
  private singleColumnWidths: LengthMetrics[] = [
    LengthMetrics.percent(50)
  ];
  aboutToAppear(): void {
    this.selectedValue = this.data.selected
  }

  build() {
    Column() {
      Text(this.data.title)
        .textAlign(TextAlign.Start)
        .fontSize(20)
        .fontWeight(700)
        .fontColor('#000000')
        .padding({
          left:20
        })
        .margin({
          top:14
        })
        .width('100%')
     Column(){


      // TextPicker 容器
      TextPicker({
        range: this.data.range,
        selected: this.data.range.indexOf(this.selectedValue),
      })
        .onChange((value: string | string[], _index: number | number[]) => {
          this.selectedValue = value as string
        })
        .defaultPickerItemHeight(43)
        .canLoop(false)
        .width(180)
        .height(200)
        .textStyle({ color:'rgba(34,33,40,0.7886)', font: { size: 14, weight: 400 } })
        .selectedTextStyle({ color: '#564AF7', font: { size: 16, weight: 600 } })
        .divider({
          strokeWidth: '1px',
          color: '#F0F0F0'
        })
     }
      Row() {
        Row() {
          Text('取消')
            .fontSize(16)
            .fontColor('#676767')
        }
        .width('50%')
        .height(48)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.data.onCancel()
          CommonSingleDialogController.closeDialog()
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
          CommonSingleDialogController.closeDialog()
        })
      }
      .height(48)
      .width('100%')

    }
    .width('calc(100% - 32vp)')
    .backgroundColor(Color.White)
    .borderRadius(32)
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
      .borderRadius(16)
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
      .borderRadius(16)
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
      .borderRadius(16)
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
