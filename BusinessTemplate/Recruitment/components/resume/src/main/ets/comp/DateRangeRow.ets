/**
 * 时间范围选择组件
 * 用于工作经历、项目经验、教育背景的时间选择
 */
import { TimePickerDialogParams } from './TimePickerDialog'

export interface DateRangeRowParams {
  title: string // 标题，如"在职时间"、"项目时间"、"在校时间"
  startDate: string // 开始时间
  endDate: string // 结束时间
  startPlaceholder: string // 开始时间占位符，如"请选择入职时间"
  endPlaceholder: string // 结束时间占位符，如"请选择离职时间"
  onStartDateClick: () => void // 点击开始时间的回调
  onEndDateClick: () => void // 点击结束时间的回调
}

@ComponentV2
export struct DateRangeRow {
  @Param @Require title: string = ''
  @Param @Require startDate: string = ''
  @Param @Require endDate: string = ''
  @Param @Require startPlaceholder: string = ''
  @Param @Require endPlaceholder: string = ''
  @Param @Require onStartDateClick: () => void = () => {
  }
  @Param @Require onEndDateClick: () => void = () => {
  }

  build() {
    Row() {
      Column() {
        Text(this.title)
          .fontSize(12)
          .lineHeight(14)
          .fontWeight(400)
          .fontColor($r('sys.color.font_primary'))

        Row() {
          Row() {
            Text(this.startDate || this.startPlaceholder)
              .fontSize(16)
              .fontColor(this.startDate ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
          }
          .margin({ top: 6 })
          .onClick(() => {
            this.onStartDateClick()
          })

          Divider().width(30).color($r('sys.color.comp_divider')).margin({ left: 16, right: 16 })

          Row() {
            Text(this.endDate || this.endPlaceholder)
              .fontSize(16)
              .fontColor(this.endDate ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
          }
          .margin({ top: 6 })
          .onClick(() => {
            this.onEndDateClick()
          })
        }
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(72)
    .padding({
      top: 12,
      bottom: 12
    })
  }
}
