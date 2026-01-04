import { CommonConstants, ResUtil } from 'lib_common'
import { DateUtils } from '../util/DateUtils'
import { UICalendarPicker } from './UICalendarPicker'
import { SwiperDirection, TypePicker } from '../constant/CalendarConstant'
import { DateType } from 'module_datechart'

@ComponentV2
export struct DayWeekMonthSwitcher {
  @Param dateType: DateType = DateType.DAY
  @Local tagBgHeight: number = 0
  @Local tagBarWidth: number = 0
  @Local translateX: number = 0
  @Param curDate: Date = new Date()
  @Event $dateType: (type: DateType) => void = (type: DateType) => {
    // do noting
  }
  @Event $curDate: (date: Date) => void = (date: Date) => {
    // do noting
  }

  @Monitor('dateType')
  showTypeChange(monitor: IMonitor) {
    const before = monitor.value<DateType>('dateType')?.before
    const now = monitor.value<DateType>('dateType')?.now
    if (before !== undefined && now !== undefined) {
      const diff = now.valueOf() - before.valueOf()
      this.translateX = this.translateX + (diff * this.tagBarWidth / 3)
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Start }) {
        Text()
          .width('33%')
          .height('100%')
          .backgroundColor(Color.White)
          .borderRadius(this.tagBgHeight / 2)
          .onSizeChange((oldSize, newSize) => {
            this.tagBgHeight = newSize.height as number
          })
          .translate({ x: this.translateX })
          .animation({ duration: 300, curve: Curve.FastOutSlowIn })

        Row() {
          Text($r('app.string.day'))
            .tagStyle(this.dateType === DateType.DAY)
            .onClick(() => {
              if (this.dateType !== DateType.DAY) {
                this.$dateType(DateType.DAY)
              }
            })
          Text($r('app.string.week'))
            .tagStyle(this.dateType === DateType.WEEK)
            .onClick(() => {
              if (this.dateType !== DateType.WEEK) {
                this.$dateType(DateType.WEEK)
              }
            })
          Text($r('app.string.month'))
            .tagStyle(this.dateType === DateType.MONTH)
            .onClick(() => {
              if (this.dateType !== DateType.MONTH) {
                this.$dateType(DateType.MONTH)
              }
            })
        }
        .width('100%')
        .onSizeChange((oldSize, newSize) => {
          this.tagBarWidth = newSize.width as number
        })
      }
      .width('100%')
      .border({ width: 1, color: Color.White, radius: 20 })
      .backgroundColor($r('app.color.color_7DFFFFFF'))
      .height(40)
      .padding({
        left: 9,
        right: 9,
        top: 6,
        bottom: 6
      })

      Row() {
        Image($r('app.media.ic_date_left_arrow'))
          .width(18)
          .onClick(() => {
            this.adjustDate(false)
          })

        UICalendarPicker({
          type: TypePicker.SINGLE,
          swiperDirection: SwiperDirection.VERTICAL,
          selected: this.curDate!!,
          onClickDate: (date) => {
            if (date instanceof Date) {
              this.$curDate(date)
            }
          },
          customBuildPanel: () => {
            this.dateBuilder()
          }
        })

        Image($r('app.media.ic_date_right_arrow'))
          .width(18)
          .onClick(() => {
            this.adjustDate(true)
          }).visibility(this.isShowDateAdd() ? Visibility.Visible : Visibility.Hidden)
      }.justifyContent(FlexAlign.SpaceEvenly)
      .margin({ top: 17 })
    }
    .padding({
      right: CommonConstants.PADDING_PAGE,
      left: CommonConstants.PADDING_PAGE,
      bottom: CommonConstants.PADDING_PAGE
    })
  }

  @Builder
  dateBuilder() {
    Row({ space: 6 }) {
      Text(this.getDateStr())
        .fontSize(15)
      Image($r('app.media.ic_date_selector_arrow'))
        .width(12)
    }.padding({ left: 24, right: 24 })
  }

  isShowDateAdd(): boolean {
    if (this.dateType === DateType.DAY && DateUtils.formatDate(this.curDate) === DateUtils.formatDate(new Date())) {
      return false
    } else if (this.dateType === DateType.WEEK && DateUtils.getWeekRange2(this.curDate)[1] > new Date()) {
      return false
    } else if (this.dateType === DateType.MONTH && this.curDate.getMonth() === new Date().getMonth()) {
      return false
    }
    return true
  }

  getDateStr(): string {
    if (this.dateType === DateType.WEEK) {
      const weekRange = DateUtils.getWeekRange2(this.curDate)
      return DateUtils.formatDate(weekRange[0]) + '-' + DateUtils.formatDate(weekRange[1])
    } else if (this.dateType === DateType.MONTH) {
      return DateUtils.getMonthInfo(this.curDate)[1] + ResUtil.getStringSync($r('app.string.month'))
    } else {
      return `${DateUtils.formatDate(this.curDate)} ${DateUtils.weekFormat.format(this.curDate)
        .toUpperCase()
        .replace(ResUtil.getStringSync($r('app.string.week')),
          ResUtil.getStringSync($r('app.string.week_style_sec')))}`
    }
  }

  adjustDate(isAdd: boolean) {
    const newDate = new Date(this.curDate)
    if (this.dateType === DateType.WEEK) {
      newDate.setDate(newDate.getDate() - (isAdd ? -7 : 7))
    } else if (this.dateType === DateType.MONTH) {
      newDate.setMonth(newDate.getMonth() - (isAdd ? -1 : 1))
    } else {
      newDate.setDate(newDate.getDate() - (isAdd ? -1 : 1))
    }
    this.$curDate(newDate)
  }
}

@Extend(Text)
function tagStyle(selected: boolean) {
  .fontColor(selected ? $r('app.color.color_333333') : $r('app.color.color_99333333'))
  .fontSize(11)
  .layoutWeight(1)
  .textAlign(TextAlign.Center)
}