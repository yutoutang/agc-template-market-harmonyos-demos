import { SegmentButton, SegmentController } from './component/SegmentButton';
import { TimelineBar } from './component/TimelineBar';
import { CalendarButtonType } from '../types/Types';
import { CalendarUtil, CalenderView, CommonConstants, DateUtils, DateElement } from 'calendar_component';
import { LayoutUtil } from '../utils/LayoutUtil';
import { TimeLineConstants } from '../constant/CalendarConstant';
import { PriorityEnum, TodoDataManager, TodoItem, TodoSectionList } from '@ohos_agcit/daily_schedule_todo';
import { AvoidArea } from '@ohos_agcit/daily_schedule_component_lib';
import { AppStorageV2, curves } from '@kit.ArkUI';
import { TodoCard } from './component/TodoCard';
import { ThemeController } from '@ohos_agcit/daily_schedule_common_lib';
import { DataPreferencesUtils } from '../utils/DataPreferencesUtils';
import { Utils } from '../utils/Utils';
import { ConfigurationConstant } from '@kit.AbilityKit';

@ComponentV2
export struct CalendarPage {
  buttons: string[] = ['月', '周', '日'];
  dataManager: TodoDataManager = TodoDataManager.instance
  controller: Scroller = new Scroller()
  themeController: ThemeController = ThemeController.instance;
  dateTimeController: CustomDialogController = new CustomDialogController({
    builder: () => {
      this.dateTimeDialog();
    },
    alignment: DialogAlignment.Center
  });
  // 避让区域
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  // 分段式按钮控制器
  @Local segmentController: SegmentController = new SegmentController(0, this.onChange.bind(this));
  // 视图模式触发
  @Local viewButtonType: CalendarButtonType = CalendarButtonType.MONTH
  // 今日待办
  @Local todayTodoItems: TodoItem[] = []
  // 选择的日期
  @Local selectedDay: DateElement = new DateElement(DateUtils.getCurrentYear(),
    DateUtils.getCurrentMonth(), DateUtils.getCurrentDay());
  // 时间筛选器的时间
  @Local selectedDateTime: Date =
    new Date(`${this.selectedDay.year}-${this.selectedDay.month + 1}-${this.selectedDay.day}`);
  @Local selectedMonth: DateElement =
    new DateElement(DateUtils.getCurrentYear(), DateUtils.getCurrentMonth(), 0);
  @Local showYear: number = DateUtils.getCurrentYear();
  @Local showMonth: number = DateUtils.getCurrentMonth();
  @Local isShowLunar: boolean = true;
  @Local viewType: number = CommonConstants.MONTH_VIEW;
  @Local scaleNum: number = 1;
  @Local scheduleDates: Array<string> = [];

  @Monitor('viewTypes')
  onViewTypeChange() {
    this.refreshTodoData();
  }

  @Monitor('dataManager.refreshNum')
  onTaskMapChange() {
    if (this.dataManager.refreshNum) {
      this.dataManager.refreshNum = 0
      this.refreshTodoData();
    }
    this.scheduleDates = Array.from(this.dataManager.taskMap.keys());
  }

  aboutToAppear(): void {
    this.todayTodoItems = Utils.filterTodayTasks(this.dataManager.allTasks,
      new Date(`${this.selectedDay.year}-${this.selectedDay.month}-${this.selectedDay.day}`))
    this.selectedDateTime = new Date(`${this.selectedDay.year}-${this.selectedDay.month + 1}-${this.selectedDay.day}`)
    this.refreshTodoData();
    this.scheduleDates = Array.from(this.dataManager.taskMap.keys());
  }

  /**
   * 分段式按钮回调函数
   * @param index
   */
  onChange(index: number) {
    console.log(String(index))
    if (this.segmentController.activeIndex === 0) {
      this.viewButtonType = CalendarButtonType.MONTH
      this.viewType = CommonConstants.MONTH_VIEW
    }
    if (this.segmentController.activeIndex === 1) {
      this.viewButtonType = CalendarButtonType.WEEK
      getContext(this).eventHub.emit('WEEK', 1);
      this.viewType = CommonConstants.WEEK_VIEW
    }
    if (this.segmentController.activeIndex === 2) {
      this.viewButtonType = CalendarButtonType.DAY
      getContext(this).eventHub.emit('WEEK', 1);
      this.viewType = CommonConstants.WEEK_VIEW;
    }
    this.refreshTodoData();
  }

  /**
   * 刷新待办数据
   */
  refreshTodoData() {
    this.selectedDateTime = new Date(`${this.selectedDay.year}-${this.selectedDay.month + 1}-${this.selectedDay.day}`)
    this.todayTodoItems = Utils.filterTodayTasks(this.dataManager.allTasks,
      new Date(`${this.showYear}-${this.showMonth + 1}-${this.selectedDay.day}`))
  }

  buildHeaderText(): string {
    let year = this.selectedDay.year;
    let month = this.selectedDay.month + 1;
    if (month < 10) {
      return year + '年' + '0' + month + '月'
    }
    return year + '年' + month + '月'
  }

  @Builder
  titleBar() {
    Row() {
      Text($r('app.string.title_calendar'))
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start);
    }
    .height('7%')
    .width('100%')
    .padding({ 'left': '5%', right: '5%' })
  }

  @Builder
  segmentButton() {
    Column() {
      SegmentButton({
        tabOptions: this.buttons,
        activeButtonHeight: 35,
        buttonHeight: 40,
        buttonWidth: '90%',
        buttonRadius: 24,
        textFontColor: $r('sys.color.font_secondary'),
        buttonBgColor: $r('sys.color.interactive_pressed'),
        textActiveFontColor: $r('sys.color.font_primary'),
        textActiveBgColor: this.themeController.currentColorMode ===
        ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? $r('sys.color.comp_background_secondary') :
        $r('sys.color.comp_background_primary'),
        controller: this.segmentController
      })
        .height(50);
    }
    .height('12%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  timeSelector() {
    Row() {
      Text(this.buildHeaderText())
        .fontSize($r('app.integer.month_title_font_size'))
        .fontWeight(500)
        .textAlign(TextAlign.Start);
      SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
        .fontSize(15)
        .fontColor([$r('sys.color.ohos_id_color_foreground')])
        .margin({ left: 5 });
    }
    .padding({ left: '5%', right: '5%' })
    .height('6%')
    .width('100%')
    .onClick(() => {
      this.dateTimeController.open();
    })
  }

  changeMonth(selectedMonth: DateElement) {
    this.showYear = selectedMonth.year;
    this.showMonth = selectedMonth.month;
  }

  changeLunar() {
    this.isShowLunar = this.isSettingLunar()
  }

  isSettingLunar() {
    return DataPreferencesUtils.LUNAR_SETTING_ON ===
    DataPreferencesUtils.getSync(DataPreferencesUtils.LUNAR_SETTING, DataPreferencesUtils.LUNAR_SETTING_ON)
  }

  @Builder
  endNavigation() {
    Column() {
      Column() {
      }
      .borderRadius(2.5)
      .backgroundColor($r('sys.color.icon_fourth'))
      .width(50)
      .height(5)
    }
    .width('100%')
    .height(30)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 日期选择器弹窗
   */
  @Builder
  dateTimeDialog() {
    Column() {
      Row() {
        Text() {
          Span(CalendarUtil.buildDateStringByDate(this.selectedDateTime))
          Span(' ')
          Span(CalendarUtil.getWeekDescription(this.selectedDateTime))
        }
        .fontSize(20)
        .fontWeight(700)
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(70)

      // 日期选择器
      DatePicker({
        start: new Date('1970-1-1'),
        end: new Date('2100-1-1'),
        selected: this.selectedDateTime
      })
        .height(220)
        .expandSafeArea()
        .textStyle({
          font: {
            size: $r('sys.float.Subtitle_M'),
            weight: FontWeight.Normal
          },
          color: $r('sys.color.font_primary')
        })
        .selectedTextStyle({
          color: $r('sys.color.multi_color_04'),
          font: {
            size: $r('sys.float.Title_S'),
            weight: FontWeight.Bold
          }
        })
        .lunar(false)
        .onDateChange((value: Date) => {
          this.selectedDateTime = value
        })

      Row() {
        Row() {
          Text($r('app.string.text_cancel'))
            .fontColor($r('sys.color.font_tertiary'))
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
        .onClick(() => {
          this.dateTimeController.close();
        })

        Row() {
          Text($r('app.string.text_confirm'))
            .fontSize(18)
            .fontColor($r('sys.color.multi_color_04'))
            .fontWeight(FontWeight.Medium)
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
        .onClick(() => {
          this.showYear = new Date(this.selectedDateTime).getFullYear();
          this.showMonth = new Date(this.selectedDateTime).getMonth();
          const day = new Date(this.selectedDateTime).getDate();
          this.selectedDay = new DateElement(this.showYear, this.showMonth, day);
          this.dateTimeController.close();
        })
      }
      .width('100%')
      .height(60)
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(32)
    .height(350)
    .width('100%')
  }

  build() {
    Column() {
      // 标题
      this.titleBar()
      // 分段式按钮
      this.segmentButton()
      // // 时间选择器
      this.timeSelector()


      Column() {
        // 日历
        CalenderView({
          scheduleDates: this.scheduleDates,
          scaleNumber: this.scaleNum,
          viewType: this.viewType,
          selectedDay: this.selectedDay,
          showMonth: new DateElement(this.showYear, this.showMonth, this.selectedDay.day),
          isShowLunar: this.isShowLunar,
          onChangeDay: (day: DateElement) => {
            this.selectedDay = new DateElement(day.year, day.month, day.day);
            this.refreshTodoData();
          },
          onChangeMonth: (month: DateElement) => {
            this.selectedMonth = month;
            this.changeMonth(month);
            this.refreshTodoData();
          },
          onChangeViewType: (viewType: number) => {
            this.viewType = viewType;
          }
        })

        // 底部导航条
        this.endNavigation()
      }
      .padding({
        left: 10,
        right: 10
      })
      .justifyContent(FlexAlign.Start)
      .gesture(PanGesture({ fingers: 1, direction: PanDirection.Vertical, distance: 5 })
        .onActionEnd((e: GestureEvent) => {
          if (this.viewType === CommonConstants.MONTH_VIEW) {
            this.viewType = CommonConstants.WEEK_VIEW;
          } else {
            this.viewType = CommonConstants.MONTH_VIEW;
          }
          this.scaleNum = 1;
        })
        .onActionUpdate((e: GestureEvent) => {
          if (e.offsetY <= 20 && e.offsetY >= -20) {
            this.scaleNum = e.offsetY;
          }
        })
      )

      // 待办列表
      if (this.segmentController.activeIndex === 0 || this.segmentController.activeIndex === 1) {
        TodoSectionList({
          params: [
            {
              label: $r('app.string.title_today'),
              data: this.todayTodoItems,
              isShow: true,
            }
          ]
        })
          .layoutWeight(1)
      }

      // 日程卡片
      if (this.segmentController.activeIndex === 2) {
        Column() {
          Text('待办').width('100%').textAlign(TextAlign.Start).height(50).padding({ left: 20 })
          Column() {
            Scroll(this.controller) {
              Column() {
                Stack({ alignContent: Alignment.TopStart }) {
                  TimelineBar({
                    firstHour: TimeLineConstants.DEFAULT_FIRST_HOUR,
                    lastHour: TimeLineConstants.DEFAULT_LAST_HOUR
                  })
                  Column() {
                    ForEach(this.todayTodoItems, (item: TodoItem, index: number) => {
                      TodoCard({ item: item, color: this.chooseCardColor(item) })
                        .position({
                          x: LayoutUtil.getXPosition(this.todayTodoItems, index),
                          y: LayoutUtil.getYPosition(item)
                        })
                    }, (item: TodoItem) => JSON.stringify(item))
                  }
                }
              }
            }
          }
          .layoutWeight(1)
          .width('100%')
        }
        .layoutWeight(1)
        .transition(TransitionEffect.OPACITY
          .combine(TransitionEffect.scale({ x: 0.9, y: 0.9 }).animation({ curve: curves.springMotion() })))
      }
    }
    .width('100%')
    .height('100%')
    .padding({ top: px2vp(this.avoidArea.topRectHeight) + 10 })
    .backgroundColor($r('sys.color.background_secondary'))
    .justifyContent(FlexAlign.Start)
  }

  private chooseCardColor(item: TodoItem): ResourceColor | undefined {
    if (item.priorityType === PriorityEnum.NO) {
      return $r('app.color.card_gray')
    }
    if (item.priorityType === PriorityEnum.LOW) {
      return $r('app.color.card_green')
    }
    if (item.priorityType === PriorityEnum.MID) {
      return $r('app.color.card_orange')
    }
    if (item.priorityType === PriorityEnum.HIGH) {
      return $r('app.color.card_red')
    }
    return $r('app.color.card_gray')
  }
}