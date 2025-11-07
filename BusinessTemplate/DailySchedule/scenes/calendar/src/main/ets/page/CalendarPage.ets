import { SegmentButton, SegmentController } from './component/SegmentButton';
import { TimelineBar } from './component/TimelineBar';
import { CalendarButtonType } from '../types/Types';
import { CalendarVM, MonthWeekCalendar, ViewTypeEnum, YearCalendar } from 'calendar_component';
import { LayoutUtil } from '../utils/LayoutUtil';
import { TimeLineConstants } from '../constant/CalendarConstant';
import { TodoDataManager, TodoSectionList } from '@ohos_agcit/daily_schedule_todo';
import { AvoidArea, TodoCard, TodoItem } from '@ohos_agcit/daily_schedule_component_lib';
import { AppStorageV2, curves } from '@kit.ArkUI';
import { ThemeController } from '@ohos_agcit/daily_schedule_common_lib';
import { DataPreferencesUtils } from '../utils/DataPreferencesUtils';
import { Utils } from '../utils/Utils';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { BreakpointType, GlobalInfoModel } from '@ohos_agcit/daily_schedule_utils';
import dayjs from 'dayjs';

@ComponentV2
export struct CalendarPage {
  buttons: string[] = ['年', '月', '周', '日'];
  dataManager: TodoDataManager = TodoDataManager.instance
  controller: Scroller = new Scroller()
  themeController: ThemeController = ThemeController.instance;
  vm: CalendarVM = CalendarVM.instance;
  // 避让区域
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  // 断点控制器 
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;
  // 分段式按钮控制器
  @Local segmentController: SegmentController = new SegmentController(0, this.onButtonChange.bind(this));
  // 视图模式按钮
  @Local viewButtonType: CalendarButtonType = CalendarButtonType.MONTH
  // 所有今日待办
  @Local allTodayTodoItems: TodoItem[] = []
  // 时间线中展示的今日待办
  @Local todayTodoItemsInTimeline: TodoItem[] = []
  // 是否展示农历
  @Local isShowLunar: boolean = true
  // 待办信息
  @Local todoData: Map<string, TodoItem[]> = new Map()

  aboutToAppear(): void {
    this.isShowLunar = this.isSettingLunar()
    this.segmentController.updateActiveIndex(1)
    this.refreshAllTodoCard();
    this.refreshTodayTodoData(new Date());
  }

  /**
   * 监听待办数据变化
   */
  @Monitor('dataManager.refreshNum')
  onTaskMapChange() {
    if (this.dataManager.refreshNum) {
      this.dataManager.refreshNum = 0
      this.refreshAllTodoCard();
      this.refreshTodayTodoData(this.vm.selectDate.toDate());
    }
  }

  /**
   * 监听视图模式变化
   */
  @Monitor('vm.viewType')
  onViewTypeChange() {
    if (this.vm.viewType === ViewTypeEnum.MONTH) {
      this.segmentController.updateActiveIndex(CalendarButtonType.MONTH)
      return;
    }
    if (this.vm.viewType === ViewTypeEnum.WEEK) {
      this.segmentController.updateActiveIndex(CalendarButtonType.WEEK)
      return;
    }
  }

  /**
   * 监听断点变化
   * @param index
   */
  @Monitor('globalInfo.currentBreakpoint')
  onCurrentBreakpointChange() {
    this.refreshTodayTodoData(this.vm.selectDate.toDate())
  }
  
  /**
   * 分段式按钮回调函数
   * @param index
   */
  onButtonChange(index: number) {
    console.log(String(index))
    if (this.segmentController.activeIndex === CalendarButtonType.YEAR &&
      this.vm.viewType !== ViewTypeEnum.YEAR) {
      getContext(this).eventHub.emit('viewTypeChange', ViewTypeEnum.YEAR);
      return
    }
    if (this.segmentController.activeIndex === CalendarButtonType.MONTH &&
      this.vm.viewType !== ViewTypeEnum.MONTH) {
      getContext(this).eventHub.emit('viewTypeChange', ViewTypeEnum.MONTH);
      return
    }
    if (this.segmentController.activeIndex === CalendarButtonType.WEEK &&
      this.vm.viewType !== ViewTypeEnum.WEEK) {
      getContext(this).eventHub.emit('viewTypeChange', ViewTypeEnum.WEEK);
      return
    }
    if (this.segmentController.activeIndex === CalendarButtonType.DAY &&
      this.vm.viewType !== ViewTypeEnum.DAY) {
      getContext(this).eventHub.emit('viewTypeChange', ViewTypeEnum.DAY);
      return
    }
  }

  /**
   * 刷新待办数据
   */
  refreshTodayTodoData(date: Date) {
    this.allTodayTodoItems = Utils.filterTodayTasks(this.dataManager.allTasks, date)


    // 1. 按小时分组
    const groupedByHour = new Map<number, TodoItem[]>();

    this.allTodayTodoItems.forEach(item => {
      const hour = item.planTime.getHours();
      if (!groupedByHour.has(hour)) {
        groupedByHour.set(hour, []);
      }
      groupedByHour.get(hour)?.push(item);
    });

    // 2. 每组内按时间排序
    groupedByHour.forEach(items => {
      items.sort((a, b) => a.planTime.getTime() - b.planTime.getTime());
    });

    // 3. 取每组前N个并合并
    this.todayTodoItemsInTimeline = Array.from(groupedByHour.values())
      .flatMap(items => items.slice(0, new BreakpointType<number>({
        sm: 4,
        md: 8,
        lg: 12,
      }).getValue(this.globalInfo.currentBreakpoint)))
      .sort((a, b) => a.planTime.getTime() - b.planTime.getTime());
  }

  /**
   * 刷新卡片数据
   */
  refreshAllTodoCard() {
    this.todoData = Utils.getAllCard(this.dataManager.taskMap);
  }

  @Builder
  titleBar() {
    Row() {
      Text($r('app.string.title_calendar'))
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)
    }
    .height(35)
    .width('100%')
    .padding({ left: '5%', right: '5%' })
  }

  @Builder
  segmentButton() {
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
  }

  isSettingLunar() {
    return DataPreferencesUtils.LUNAR_SETTING_OFF !==
    DataPreferencesUtils.getSync(DataPreferencesUtils.LUNAR_SETTING, DataPreferencesUtils.LUNAR_SETTING_ON)
  }

  build() {
    Column() {
      // 标题
      this.titleBar()
      Blank().height(10)

      // 分段式按钮
      this.segmentButton()
      Blank().height(18)

      Column() {
        // 年视图
        YearCalendar({
          todoData: this.todoData,
          onClickMonth: (index) => {
            let newDate = new Date(this.vm.selectDate.year(), index, 1)
            this.vm.selectDate = dayjs(new Date(this.vm.selectDate.year(), index, 1));
            this.refreshTodayTodoData(newDate)
            this.segmentController.updateActiveIndex(1)
          }
        })
          .visibility(this.vm.viewType === ViewTypeEnum.YEAR ? Visibility.Visible : Visibility.None)

        // 月周视图
        MonthWeekCalendar({
          selectedStyle: 'circle',
          startWeekday: 'sunday',
          isShowLunar: this.isShowLunar,
          selectedColor: $r('sys.color.multi_color_04'),
          todoData: this.todoData,
          onChangeDay: (date: Date) => {
            this.refreshTodayTodoData(date)
          }
        })
          .visibility(this.vm.viewType !== ViewTypeEnum.YEAR ? Visibility.Visible : Visibility.None)
      }
      .padding({
        left: 16,
        right: 16
      })
      .justifyContent(FlexAlign.Start)

      // 待办列表
      if ((this.segmentController.activeIndex === CalendarButtonType.MONTH ||
        this.segmentController.activeIndex === CalendarButtonType.WEEK) &&
        this.vm.viewType !== ViewTypeEnum.MONTH_DETAIL) {
        TodoSectionList({
          params: [
            {
              label: $r('app.string.title_today'),
              data: this.allTodayTodoItems,
              isShow: true,
            }
          ]
        })
          .layoutWeight(1)
      }

      // 日程卡片
      if (this.segmentController.activeIndex === CalendarButtonType.DAY) {
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
                    ForEach(this.todayTodoItemsInTimeline, (item: TodoItem, index: number) => {
                      TodoCard({
                        title: item.title,
                        cardHeight: TimeLineConstants.TODO_CARD_HEIGHT,
                        cardWidth: TimeLineConstants.TODO_CARD_WIDTH,
                        color: Utils.chooseCardColor(item)
                      })
                        .position({
                          x: LayoutUtil.getXPosition(this.todayTodoItemsInTimeline, index),
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
    .padding({ top: px2vp(this.avoidArea.topRectHeight) })
    .backgroundColor($r('sys.color.background_secondary'))
    .justifyContent(FlexAlign.Start)
  }
}