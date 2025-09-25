import { i18n } from '@kit.LocalizationKit';
import { CommonConstants } from '../constants/CommonContants';
import { DateUtils } from '../utils/DateUtil';
import { DateElement } from '../types/DateElement';
import { CalendarUtil } from '../utils/CalendarUtil';

@ObservedV2
class ShowDays {
  @Trace showDays: DateElement [][] = [];
  @Trace showWeekDays: DateElement [][] = [];
}

@ComponentV2
export struct CalenderView {
  readonly TIME_DEF_VALUE = -1;
  private calendar = i18n.getCalendar(CommonConstants.EN_LOCALE);
  private showDays: ShowDays = new ShowDays();
  @Local gridSize: number = CommonConstants.GRID_LARGE_SIZE;
  @Local currentDay: number = this.calendar.get(CommonConstants.FIELD_DAY);
  @Local currentMonth: number = this.calendar.get(CommonConstants.FIELD_MONTH);
  @Local currentYear: number = this.calendar.get(CommonConstants.FIELD_YEAR);
  @Param isShowLunar: boolean = true;
  @Param titleFontOpacity: Resource = $r('app.float.calendar_title_font_opacity')
  @Param scaleNumber: number = 1;
  @Param selectedDay: DateElement = new DateElement(0, 0, this.TIME_DEF_VALUE);
  @Event onChangeDay: (val: DateElement) => void = (val: DateElement) => {
  };
  @Param showMonth: DateElement = new DateElement(this.TIME_DEF_VALUE, this.TIME_DEF_VALUE, this.TIME_DEF_VALUE);
  @Event onChangeMonth: (showMonth: DateElement) => void = (showMonth: DateElement) => {
  };
  @Param viewType: number = CommonConstants.MONTH_VIEW;
  @Param useParamBuilder: boolean = false;  // 是否展示自定义图标
  @Param showLunar: boolean = true;  // 是否展示农历
  @Param scheduleDates: Array<string> = [];  // 含有计划的时间数组
  @Param showSchedule: boolean = false;  // 是否展示日程计划标记
  @BuilderParam customBuilderParam: () => void = this.customBuilder;  // 自定义图标插槽
  @Event onChangeViewType: (showType: number) => void = (showType: number) => {
  };

  @Monitor('showMonth','selectedDay')
  onSelectedMonthChange(monitor: IMonitor) {
    this.refresh();
  }

  @Monitor('viewType')
  changeViewType() {
    this.setWeedViewData()
  }

  aboutToAppear() {
    this.refresh();
  }

  refresh() {
    this.init();

    // 设置日历实例到当前月份的第0天
    this.calendar.set(this.showMonth.year, this.showMonth.month, 0);

    // 计算上个月的信息
    let preMonth = this.showMonth.month - 1 >= 0 ? this.showMonth.month - 1 : 11;
    let preMonthYear = this.showMonth.month - 1 >= 0 ? this.showMonth.year : this.showMonth.year - 1;
    let preMonthDays: number = -this.calendar.compareDays(new Date(preMonthYear, preMonth, 0)) - 1;

    // 计算下个月的信息
    let nextMonth = this.showMonth.month + 1 < 12 ? this.showMonth.month + 1 : 0;
    let nextMonthYear = this.showMonth.month + 1 < 12 ? this.showMonth.year : this.showMonth.year + 1;

    // 计算当前显示月份的总天数
    let selectMonthDays: number = this.calendar.compareDays(new Date(nextMonthYear, nextMonth, 0));

    // 获取当前月第一天是周几（0-6）
    let firstDayOfWeek = this.calendar.get(CommonConstants.FIELD_DAY_OF_WEEK);

    // 日历表格
    let weedDays: DateElement [] = [];
    let diffDays = firstDayOfWeek < 7 ? firstDayOfWeek : 0;

    // 填充上个月的剩余天数（补全第一行）
    for (let i = 1; i <= diffDays; i++) {
      weedDays.push(new DateElement(preMonthYear, preMonth, preMonthDays - diffDays + i));
    }

    // 填充当前月日期
    for (let i = 1; i <= selectMonthDays; i++) {
      if (weedDays.length === 7) {
        this.showDays.showDays.push(weedDays);
        weedDays = [];
      }
      weedDays.push(new DateElement(this.showMonth.year, this.showMonth.month, i));
    }

    // 填充下个月的日期（补全最后一行）
    if (weedDays.length < 7) {
      let diffDays = 7 - weedDays.length;
      for (let i = 0; i < diffDays; i++) {
        weedDays.push(new DateElement(nextMonthYear, nextMonth, i + 1));
      }
    }
    this.showDays.showDays.push(weedDays);

    // 如果选中日期不在当前月，自动重置为当前月第一天
    if (this.selectedDay.year !== this.showMonth.year || this.selectedDay.month !== this.showMonth.month) {
      this.selectedDay.year = this.showMonth.year;
      this.selectedDay.month = this.showMonth.month;
      this.onChangeDay(this.selectedDay);
    }

    // 如果未设置选中日期，默认选中今天
    if (this.selectedDay.day === this.TIME_DEF_VALUE) {
      this.selectedDay.day = this.currentDay;
      this.onChangeDay(this.selectedDay);
    }

    // 在周视图模式下，找到选中日期所在的周
    this.setWeedViewData()
  }

  init() {
    this.showDays.showDays = [];
    if (this.showMonth.year === this.TIME_DEF_VALUE) {
      this.showMonth.year = this.currentYear;
      this.showMonth.month = this.currentMonth;
      this.onChangeMonth(this.showMonth);
    }
  }

  setWeedViewData() {
    this.showDays.showDays.forEach(week => {
      week.forEach(day => {
        if (this.isSelectedDay(day)) {
          this.showDays.showWeekDays = [week];
        }
      })
    })
  }

  private isToday(day: DateElement): boolean {
    return this.currentDay === day.day && this.currentMonth === day.month &&
      this.currentYear === day.year;
  }

  isBeforeDay(day: DateElement) {
    return this.calendar.compareDays(new Date(day.year, day.month, day.day)) < 0;
  }

  appendZero(num: number): string {
    return num < 10 ? '0' + num : '' + num;
  }

  private isSelectedDay(day: DateElement): boolean {
    return this.selectedDay.isEquals(day);
  }

  isCurrentMonth(day: DateElement) {
    return this.showMonth.year === day.year && this.showMonth.month === day.month;
  }

  private changeMonthByGesture(e: GestureEvent) {
    if (e.offsetX > 10) {
      if (this.viewType === CommonConstants.MONTH_VIEW) {
        this.showMonth.year = this.showMonth.month - 1 < 0 ? this.showMonth.year - 1 : this.showMonth.year;
        this.showMonth.month = this.showMonth.month - 1 < 0 ? 11 : this.showMonth.month - 1;
        this.onChangeMonth(this.showMonth);
      } else {
        let selectedDate = new Date(this.selectedDay.year, this.selectedDay.month, this.selectedDay.day);
        selectedDate = new Date(selectedDate.getTime() - CommonConstants.SEVEN_DAY);
        this.changeSelectDay(new DateElement(selectedDate.getFullYear(),
          selectedDate.getMonth(),
          selectedDate.getDate()))
      }
    } else if (e.offsetX < -10) {
      if (this.viewType === CommonConstants.MONTH_VIEW) {
        this.showMonth.year = this.showMonth.month + 1 < 12 ? this.showMonth.year : this.showMonth.year + 1;
        this.showMonth.month = this.showMonth.month + 1 < 12 ? this.showMonth.month + 1 : 0;
        this.onChangeMonth(this.showMonth);
      } else {
        let selectedDate = new Date(this.selectedDay.year, this.selectedDay.month, this.selectedDay.day);
        selectedDate = new Date(selectedDate.getTime() + CommonConstants.SEVEN_DAY);
        this.changeSelectDay(new DateElement(selectedDate.getFullYear(),
          selectedDate.getMonth(),
          selectedDate.getDate()))
      }
    }
  }

  changeSelectDay(day: DateElement) {
    this.selectedDay.year = day.year;
    this.selectedDay.month = day.month;
    this.selectedDay.day = day.day;
    this.onChangeDay(day);
    this.setWeedViewData();
    this.changeMonth(day);
  }

  changeMonth(month: DateElement) {
    this.showMonth.year = month.year;
    this.showMonth.month = month.month;
    this.onChangeMonth(month);
  }

  chooseTextColor(day: DateElement): ResourceColor {
    if (day.month !== this.selectedDay.month) {
      return $r('sys.color.font_fourth')
    }
    if (this.isSelectedDay(day)) {
      return $r('app.color.start_window_background')
    }
    const dateKey = CalendarUtil.buildKeyByDateElement(day);
    return this.scheduleDates.indexOf(dateKey) !== -1?$r('sys.color.multi_color_04') :$r('sys.color.font_primary');
  }

  isHasSchedule(day: DateElement) {
    let dayStr: string = CalendarUtil.buildKeyByDateElement(day);
    return this.scheduleDates.indexOf(dayStr) !== -1;
  }

  @Builder
  customBuilder() {
    // custom builder
  }

  build() {
    Column() {
      /****日期--周***/
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(CommonConstants.WEEK_TITLE, (str: Resource, index: number) => {
          Column() {
            Text(str)
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .textAlign(TextAlign.Center)
              .opacity(this.titleFontOpacity)
          }
          .justifyContent(FlexAlign.Center)
          .width($r('app.float.content_size'))
          .height($r('app.float.height_or_line_height'))
        }, (str: Resource) => JSON.stringify(str))
      }
      .width(CommonConstants.FULL_PERCENT)
      .borderRadius($r('app.float.height_or_line_height'))
      .margin({
        bottom: $r('app.float.day_button_radius'),
        left: CommonConstants.COMMON_MARGIN,
        right: CommonConstants.COMMON_MARGIN
      })

      /****日期--天***/
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.viewType === CommonConstants.MONTH_VIEW ? this.showDays.showDays : this.showDays.showWeekDays,
          (weekDays: DateElement []) => {
            Flex({ justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(weekDays, (day: DateElement, index: number) => {
                Column() {
                  if (this.useParamBuilder) {
                    this.customBuilderParam()
                  }
                  Text(this.isToday(day) ? '今' : `${day.day}`)
                    .fontSize(12)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.chooseTextColor(day))
                  if (this.showLunar) {
                    Text(DateUtils.getCurrentLunarDayDesc(day.year, day.month, day.day))
                      .fontSize(10)
                      .fontWeight(FontWeight.Regular)
                      .visibility(this.isShowLunar ? Visibility.Visible : Visibility.None)
                      .fontColor(this.chooseTextColor(day))
                  }
                  if (this.isHasSchedule(day) && this.showSchedule) {
                    Column()
                      .width(4)
                      .height(4)
                      .borderRadius(2)
                      .backgroundColor($r('app.color.sys_default_blue'))
                  }
                }
                .onClick(() => {
                  this.changeSelectDay(day);
                })
                .backgroundColor(this.isSelectedDay(day) ? $r('sys.color.confirm') : 'transparent')
                .borderRadius($r('app.float.schedule_border_radius'))
                .justifyContent(FlexAlign.Center)
                .width(CommonConstants.GRID_LARGE_SIZE)
                .height(this.gridSize)
                .animation({
                  curve: Curve.Linear,
                  duration: 200
                })
              }, (day: DateElement) => JSON.stringify(day))
            }
            .width('100%')
            .margin({ top: '6vp' })
          }, (weekDays: DateElement []) => JSON.stringify(weekDays))
      }
      .width('100%')
      .gesture(PanGesture({ fingers: 1, direction: PanDirection.Horizontal, distance: 5 })
        .onActionEnd((e: GestureEvent) => {
          this.changeMonthByGesture(e);
        })
      )
    }
  }
}