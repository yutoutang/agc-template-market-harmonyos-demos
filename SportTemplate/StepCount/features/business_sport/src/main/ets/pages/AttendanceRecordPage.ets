import { ResUtil, RouterMap, RouterUtils } from 'lib_common'
import { SportServiceApi, SportType } from 'lib_sport_api'
import { DailyRecord, DailyRecordVM, SportSingleRingType } from 'module_daily'
import { DateType } from 'module_datechart'
import { MotionType } from 'module_running'
import { UICalendarPicker } from '../components/UICalendarPicker'
import { SwiperDirection, TypePicker } from '../constant/CalendarConstant'
import { DateUtils } from '../util/DateUtils'

@Builder
export function AttendanceRecordPageBuilder() {
  AttendanceRecordPage()
}

/**
 * 运动打卡记录页面
 */
@ComponentV2
struct AttendanceRecordPage {
  @Param dateType: DateType = DateType.DAY
  @Provider('attendanceRecordVM') attendanceRecordVM: DailyRecordVM = new DailyRecordVM()

  build() {
    NavDestination() {
      DailyRecord({
        toAllSportPage: () => {
          RouterUtils.pushPathByName(RouterMap.ALL_SPORT_RECORDS_PAGE)
        },
        toSportPage: (date: Date, sportSingleRingType: SportSingleRingType) => {
          RouterUtils.pushPathByName(RouterMap.REAL_TIME_MOTION_PAGE,
            {
              'sportType': SportType.WALKING,
              'target': '',
              'params': '',
              'motionType': MotionType.isFreedom
            } as ESObject, (value: PopInfo) => {
              SportServiceApi.saveTodaySportItem(value.result as ESObject)
            })
        },
        backPage: () => {
          RouterUtils.pop()
        }
      }) {
        this.DatePickerBuilder()
      }
    }
    .onWillShow(() => {
      this.attendanceRecordVM.initDataList(this.attendanceRecordVM.currentDate)
    })
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  /**
   * 日期选择器
   */
  @Builder
  DatePickerBuilder() {
    Row() {
      Image($r('app.media.ic_date_left_arrow'))
        .width(18)
        .onClick(() => {
          this.attendanceRecordVM.currentDate.setDate((this.attendanceRecordVM.currentDate.getDate() - 7))
          this.attendanceRecordVM.initDataList(this.attendanceRecordVM.currentDate)
        })

      UICalendarPicker({
        type: TypePicker.SINGLE,
        swiperDirection: SwiperDirection.VERTICAL,
        selected: this.attendanceRecordVM.currentDate!!,
        onClickDate: (date) => {
          if (date instanceof Date) {
            this.attendanceRecordVM.currentDate = date
            this.attendanceRecordVM.initDataList(date)
          }
        },
        customBuildPanel: () => {
          this.dateBuilder()
        },
        showRing: true
      })

      Image($r('app.media.ic_date_right_arrow'))
        .width(18)
        .onClick(() => {
          this.attendanceRecordVM.currentDate.setDate(this.attendanceRecordVM.currentDate.getDate() + 7)
          this.attendanceRecordVM.initDataList(this.attendanceRecordVM.currentDate)
        })
    }.justifyContent(FlexAlign.SpaceEvenly)
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

  getDateStr(): string {
    if (this.dateType === DateType.WEEK) {
      const weekRange = DateUtils.getWeekRange2(this.attendanceRecordVM.currentDate)
      return DateUtils.formatDate(weekRange[0]) + '-' + DateUtils.formatDate(weekRange[1])
    } else if (this.dateType === DateType.MONTH) {
      return DateUtils.getMonthInfo(this.attendanceRecordVM.currentDate)[1] +
      ResUtil.getStringSync($r('app.string.month'))
    } else {
      return `${DateUtils.formatDate(this.attendanceRecordVM.currentDate)} ${DateUtils.weekFormat.format(this.attendanceRecordVM.currentDate)
        .toUpperCase()
        .replace(ResUtil.getStringSync($r('app.string.week')),
          ResUtil.getStringSync($r('app.string.week_style_sec')))}`
    }
  }
}