import { emitter } from '@kit.BasicServicesKit';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { CommonConstants, LinearColumnModifier, RouterMap, RouterUtils, WindowModel } from 'lib_common';
import { SportItemType } from '../types/Types';
import { MySportType, SportViewModel } from '../viewmodels/SportVM';
import { SportPlate } from '../components/SportPlate';
import { AllSportRecordsVM } from '../viewmodels/AllSportRecordsVM';
import { SportItem, SportServiceApi, SportType, TargetType, TargetTypeStr } from 'lib_sport_api';
import { MonthItemModel } from '../model/SportOverviewModel';
import { DateUtils } from '../util/DateUtils';
import { TargetMainPage } from 'module_target';
import { executionStatus } from 'module_timer';
import { ControlType, MotionType, RunningControlComponent } from 'module_running';
import { CustomDialogShort } from 'module_trajectory';
import { Logger } from 'ui_base';

@Builder
export function SportPageBuilder() {
  SportPage()
}

@ComponentV2
struct SportPage {
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local vm: SportViewModel = new SportViewModel()
  @Local currentIndex: number = 1
  @Local currentName: MySportType = MySportType.CYCLING
  @Local modifier: LinearColumnModifier = new LinearColumnModifier($r('app.color.home_linear'));
  @Local allSportRecordsVM: AllSportRecordsVM = new AllSportRecordsVM()
  @Local totalTypeDistance: number[] = []
  @Local continuousDays: number = 0
  @Local sheetHeight: number = 350;
  @Local translateHeight: number = CommonConstants.SPORT_HISTORY
  @Provider() isRunning: executionStatus = executionStatus.over
  @Provider() isSelectTime: boolean = false
  @Provider() showTimeover: boolean = false
  @Local sportTypes: SportType = SportType.WALKING
  @Local isLock: boolean = false
  @Local pause: boolean = false // 暂停状态
  shortDialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomDialogShort({
      cancel: () => {
        this.shortDialogController?.close()
      },
      confirm: () => {
        this.shortDialogController?.close()
        try {
          emitter.emit('resetButtonStatus')
        } catch (error) {
          Logger.error('emitter emit resetButtonStatus error')
        }
        this.isRunning = executionStatus.over
        this.isSelectTime = false
        this.pause = false
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    customStyle: false,
    cornerRadius: 20,
    width: 300,
    height: 150
  })

  @Monitor('isRunning')
  onIsRunningChange() {
    // 当倒计时自然结束时，isRunning 会变为 over，此时需要重置按钮状态
    if (this.isRunning === executionStatus.over && this.currentName === MySportType.TIMED_EXERCISE) {
      try {
        emitter.emit('resetButtonStatus')
      } catch (error) {
        Logger.error('emitter emit resetButtonStatus error')
      }
      this.pause = false
      this.isSelectTime = false
    }
  }

  async aboutToAppear(): Promise<void> {
    await this.allSportRecordsVM.queryAllExercise()
    this.totalTypeDistance = this.allSportRecordsVM.totalTypeDistance
    this.continuousDays = this.allSportRecordsVM.continuousDays
    try {
      emitter.on('updateRecord', async () => {
        await this.allSportRecordsVM.queryAllExercise()
        this.totalTypeDistance = this.allSportRecordsVM.totalTypeDistance
        this.continuousDays = this.allSportRecordsVM.continuousDays
        // 修复：使用正确的sportTypeIndex
        let sportTypeIndex = this.currentIndex
        if (this.currentIndex === 0) {
          sportTypeIndex = 4
        }
        this.allSportRecordsVM.currentType = this.allSportRecordsVM.motionDataMap.get(sportTypeIndex) ?? []
      })
    } catch (error) {
      Logger.error('emitter on updateRecord error')
    }
  }

  aboutToDisappear(): void {
    try {
      emitter.off('updateRecord')
    } catch (error) {
      Logger.error('emitter off updateRecord error')
    }
  }

  getItemIcon(sportType: SportType): Resource | undefined {
    if (sportType === SportType.WALKING) {
      return $r('app.media.ic_walking')
    } else if (sportType === SportType.JOGGING) {
      return $r('app.media.ic_jogging')
    } else if (sportType === SportType.CYCLING) {
      return $r('app.media.ic_cycling')
    } else if (sportType === SportType.CLOCK_BASE_EXCERCISE) {
      return $r('app.media.ic_clock_base_exercise')
    } else {
      return undefined
    }
  }

  currentIndexChange(index: number, name: string) {
    if (this.showTimeover) {
      return
    }
    this.currentIndex = index
    this.currentName = name as MySportType
    // 根据运动类型名称映射到正确的SportType枚举值
    let sportTypeIndex = this.currentIndex
    if (this.currentIndex === 0) {
      sportTypeIndex = 4 // SportType.CLOCK_BASE_EXCERCISE
      this.translateHeight = CommonConstants.SPORT_PLATE_H_TIME
    } else {
      sportTypeIndex = this.currentIndex // 其他类型：健走=1, 跑步=2, 骑行=3
      this.translateHeight = CommonConstants.SPORT_HISTORY
    }
    this.allSportRecordsVM.currentType = this.allSportRecordsVM.motionDataMap.get(sportTypeIndex) ?? []
  }

  async onOperation(isRoute: boolean) {
    if (isRoute) {
      if (this.vm.watchOperation()) {
        return
      }
      this.allSportRecordsVM.currentType = this.allSportRecordsVM.motionDataMap.get(this.currentIndex) ?? []

      let param: Object = {
        'singleData': this.allSportRecordsVM.currentType,
        'allData': Array.from(this.allSportRecordsVM.motionDataMap.values()).flat()
      } as ESObject

      RouterUtils.pushPathByName(RouterMap.Route_Map_PAGE, param, (value: PopInfo) => {
        this.onPop(value)
      })
    } else {
      await this.allSportRecordsVM.queryAllExercise()
      // 修复：使用正确的sportTypeIndex
      let sportTypeIndex = this.currentIndex
      if (this.currentIndex === 0) {
        sportTypeIndex = 4 // SportType.CLOCK_BASE_EXCERCISE
      }
      this.allSportRecordsVM.currentType = this.allSportRecordsVM.motionDataMap.get(sportTypeIndex) ?? []
    }
  }

  // 监听返回
  onPop(value: PopInfo) {
    const result = value.result as Record<string, Object>
    let popInfo = result.result as SportItem
    let params: string = ''
    if (popInfo.target) {
      if (popInfo.target.targetType === TargetType.DISTANCE) {
        params = (popInfo.target.value / 1000).toString() + SportViewModel.defaultDistance
      } else if (popInfo.target?.targetType === TargetType.TIME_LENGTH) {
        params = (popInfo.target.value / 60).toString() + SportViewModel.defaultDuration
      } else if (popInfo.target?.targetType === TargetType.DEPLETE) {
        params = popInfo.target.value.toString() + SportViewModel.defaultHeat
      } else {
        params = popInfo.target.value.toString() + SportViewModel.defaultPace
      }
    }
    let motionType: MotionType = this.vm.motionTypeConvert(popInfo.childType)
    const values = Object.values(TargetTypeStr);

    let param2: Object = {
      'sportType': popInfo.type,
      'target': values[popInfo.target?.targetType ?? 0],
      'params': params,
      'motionType': motionType,
      'locusPoints': popInfo.locusPoints
    } as ESObject

    RouterUtils.pushPathByName(RouterMap.REAL_TIME_MOTION_PAGE, param2, (value: PopInfo) => {
      try {
        SportServiceApi.saveTodaySportItem(value.result as ESObject)
      } catch (e) {
      }
    })
  }

  // 按钮点击
  buttonClick(controlType: ControlType) {
    if (controlType === ControlType.Setting) {
      RouterUtils.pushPathByName(RouterMap.SETTING_VOICE_TIP_PAGE)
    }
    if (controlType === ControlType.Begin) {
      this.isRunning = executionStatus.Start
      this.pause = false
      if (this.isSelectTime) {
        this.showTimeover = true
      }
    }
    if (controlType === ControlType.Start) {
      this.isRunning = executionStatus.Start
      this.pause = false

    }
    if (controlType === ControlType.Pause) {
      this.isRunning = executionStatus.Pause
      this.pause = true
    }
    if (controlType === ControlType.End) {
      try {
        emitter.emit('resetButtonStatus')
      } catch (error) {
        Logger.error('emitter emit resetButtonStatus error')
      }
      this.isRunning = executionStatus.over
      this.isSelectTime = false
      this.pause = false
    }
  }

  /**
   * 处理Tab点击事件
   * @param index 点击的索引
   * @param sportItem 运动项数据
   */
  private handleTabClick(index: number, sportItem: SportItemType): void {
    if (this.isRunning !== executionStatus.over) {
      promptAction.showToast({ message: '请先结束计时运动' });
      return;
    }

    this.currentIndex = index;
    this.currentIndexChange(index, sportItem.name);
    this.sportTypes = this.getSportTypeByIndex(index);
  }

  /**
   * 根据索引获取运动类型
   * @param index 索引值
   * @returns 对应的SportType枚举值
   */
  private getSportTypeByIndex(index: number): SportType {
    switch (index) {
      case 1:
        return SportType.WALKING;
      case 2:
        return SportType.JOGGING;
      case 3:
        return SportType.CYCLING;
      default:
        return SportType.CLOCK_BASE_EXCERCISE;
    }
  }

  /**
   * 判断当前是否为计时运动类型
   * @returns boolean 是否为计时运动
   */
  private isTimedSport(): boolean {
    if (this.currentIndex < 0 || this.currentIndex >= this.vm.sportTypeList.length) {
      return false;
    }
    return this.vm.sportTypeList[this.currentIndex].name === '计时运动';
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部栏
        this.topBarBuilder()

        //顶部tab
        this.tabBuilder()

        // 运动记录
        this.recordBuilder()
      }
      .width(CommonConstants.FULL_PERCENT)
      .layoutWeight(1)
      .backgroundColor('#F1F3F5')
      .attributeModifier(this.modifier)
      .linearGradient({
        direction: this.isTimedSport() ? GradientDirection.Left : GradientDirection.Bottom,
        repeating: false,
        colors: this.isTimedSport() ?
          [['#E6E7ED', 0], ['#F7F8FA', 0.3], ['#F7F8FA', 1]] :
          [['#FFC385', 0], ['#FFE7CC', 0.3], ['#F1F3F5', 1]]
      })
    }
    .hideTitleBar(true)
  }

  // 运动记录
  @Builder
  recordBuilder() {
    Scroll() {
      Column() {
        // 计时运动面板
        this.sportPlateBuilder()

        // 运动记录
        Column() {
          Column({ space: CommonConstants.SPACE_SM }) {
            if (this.currentName === MySportType.TIMED_EXERCISE) {
              // 计时运动
              this.countSportBuilder()
            } else {
              // 非计时运动
              this.noCountSportBuilder()
            }
          }
          .width(CommonConstants.FULL_PERCENT)
          .height('auto')
          .borderRadius({ topLeft: 10, topRight: 10 })
        }
        .backgroundColor(Color.Transparent)
        .width(CommonConstants.FULL_PERCENT)
        .padding({ left: 15, right: 15 })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height('auto')
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .enableScrollInteraction(true)
    .layoutWeight(1)
    .width(CommonConstants.FULL_PERCENT)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  // 非计时运动
  @Builder
  noCountSportBuilder() {
    List({ space: 12 }) {
      ForEach(this.allSportRecordsVM.currentType, (item: MonthItemModel) => {
        this.cardItemBuilder(item)
      }, (item: MonthItemModel, index: number) => JSON.stringify(item))
    }
    .nestedScroll({
      scrollForward: NestedScrollMode.SELF_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
    .scrollBar(BarState.Off)
    .padding({ bottom: 20 })
    .enableScrollInteraction(false)
    .width(CommonConstants.FULL_PERCENT)
    .height('auto')
  }

  /**
   *  记录卡片
   * @param item 记录数据
   */
  @Builder
  cardItemBuilder(item: MonthItemModel) {
    ListItem() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Row() {
          // 左侧图标
          Image(this.getItemIcon(item.type))
            .width($r('app.float.vp_70'))

          // 中间内容
          this.cardItemInfoColumn(item)

          // 右侧箭头
          Image($r('app.media.arrow_right'))
            .width($r('app.float.vp_12'))
            .margin({ left: $r('app.float.vp_8') })
        }
        .width('100%')
        .height($r('app.float.vp_100'))
        .backgroundColor(Color.White)
        .padding({ left: $r('app.float.vp_14'), right: $r('app.float.vp_12') })
        .borderRadius(15)
        .height(110)
      }
    }.onClick(() => {
      RouterUtils.pushPathByName(RouterMap.SPORT_RECORD_DETAIL_PAGE, item)
    })
  }

  /**
   * 卡片信息
   * @param item 月份数据模型
   */
  @Builder
  private cardItemInfoColumn(item: MonthItemModel) {
    Column() {
      // 头部
      this.cardItemHeaderRow(item)
      // 距离
      this.cardItemDistanceText(item)
      // 统计
      this.cardItemStatsRow(item)
    }
    .layoutWeight(1)
    .margin({
      top: $r('app.float.vp_15'),
      bottom: $r('app.float.vp_12'),
      left: $r('app.float.vp_18')
    })
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 记录卡片时间
   * @param item 月份数据模型
   */
  @Builder
  private cardItemHeaderRow(item: MonthItemModel) {
    Row() {
      Text(MonthItemModel.getChildSportTypeStr(item.childType))
        .fontColor($r('app.color.color_999999'))
        .fontSize($r('app.float.fp_14'))
        .constraintSize({ minWidth: $r('app.float.vp_18') })

      Text(item.year + '-' + item.month + '-' + item.day)
        .fontColor($r('app.color.color_999999'))
        .fontSize($r('app.float.fp_14'))
        .margin({ left: $r('app.float.vp_7') })
    }
    .justifyContent(FlexAlign.Start)
    .width(CommonConstants.FULL_PERCENT)
  }

  /**
   * 构建距离行
   * @param item 月份数据模型
   */
  @Builder
  private cardItemDistanceText(item: MonthItemModel) {
    Text() {
      Span((Math.floor((item?.distance ?? 0) / 100) / 10).toFixed(1))
        .fontColor($r('app.color.color_333333'))
        .fontSize($r('app.float.fp_36'))
      Span($r('app.string.distance_unitKM'))
    }
    .fontColor($r('app.color.color_888888'))
    .fontSize($r('app.float.fp_16'))
    .width(CommonConstants.FULL_PERCENT)
  }

  /**
   * 构建统计行数据
   * @param item 月份数据模型
   */
  @Builder
  private cardItemStatsRow(item: MonthItemModel) {
    Row() {
      Image($r('app.media.time'))
        .LineImage()
        .margin({ left: 0 })
      Text(DateUtils.formaterTimeLength(item.timeLength).split(':').slice(1).join(':'))
        .fontColor($r('app.color.color_999999'))
        .fontSize($r('app.float.fp_10'))
        .margin({ left: $r('app.float.vp_2') })
      Line()
        .LineStyles()
      Image($r('app.media.speed'))
        .LineImage()
      Text(DateUtils.formaterTimeLength2(item.timeLength / (item.distance / 1000)))
        .fontColor($r('app.color.color_999999'))
        .fontSize($r('app.float.fp_10'))
        .margin({ left: $r('app.float.vp_2') })
      Line()
        .LineStyles()
      Image($r('app.media.hot'))
        .LineImage()
      Text() {
        Span(String(item.deplete))
        Span($r('app.string.deplete_unit'))
      }
      .fontColor($r('app.color.color_999999'))
      .fontSize($r('app.float.fp_10'))
      .margin({ left: $r('app.float.vp_2'), right: 0 })
    }
    .height($r('app.float.vp_20'))
    .padding({ left: $r('app.float.vp_8'), right: $r('app.float.vp_8') })
    .backgroundColor($r('app.color.color_F2F4FF'))
    .borderRadius(6)
  }

  // 计时运动
  @Builder
  countSportBuilder() {
    // 计时运动记录
    this.timeSportRecordList()
  }

  // 计时运动面板
  @Builder
  sportPlateBuilder() {
    SportPlate({
      sportTypeList: this.vm.sportTypeList,
      windowModel: this.windowModel,
      sportTypes: this.sportTypes,
      currentIndex: this.currentIndex,
      vm: this.vm,
      totalTypeDistance: this.totalTypeDistance,
      continuousDays: this.continuousDays,
      currentIndexChange: (index: number, name: string) => {
        this.currentIndexChange(index, name)
      },
      operation: async (isRoute: boolean) => {
        this.onOperation(isRoute)
      }
    })

    if (this.currentName === MySportType.TIMED_EXERCISE) {
      this.runningControlbtnBuilder()
    }
  }

  // 计时运动操作按钮
  @Builder
  runningControlbtnBuilder() {
    Column() {
      RunningControlComponent({
        buttonClick: (controlType: ControlType) => {
          if (controlType === ControlType.Lock) {
            this.isLock = true
          } else {
            this.isLock = false
          }
          this.buttonClick?.(controlType)
        },
        showStartButton: true
      })
        .onTouchIntercept((data) => {
          return HitTestMode.Transparent;
        })
        .margin({
          top: 20,
          bottom: 50
        })
    }
    .padding({ left: 15, right: 15 })

  }

  // 计时运动记录列表
  @Builder
  timeSportRecordList() {
    List({ space: 12 }) {
      ForEach(this.allSportRecordsVM.currentType, (item: MonthItemModel) => {
        ListItem() {
          this.itemBuilder(item)
        }.onClick(() => {
          RouterUtils.pushPathByName(RouterMap.SPORT_RECORD_DETAIL_PAGE, item)
        })
      }, (item: MonthItemModel, index: number) => JSON.stringify(item))
    }
    .scrollBar(BarState.Off)
    .padding({ bottom: 20 })
    .height('auto')
    .nestedScroll({
      scrollForward: NestedScrollMode.SELF_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
  }

  // 计时运动记录item
  @Builder
  itemBuilder(item: MonthItemModel) {
    Stack({ alignContent: Alignment.TopEnd }) {
      Row({ space: 13 }) {
        Image(this.getItemIcon(item.type))
          .width($r('app.float.vp_70'))
        Column({ space: 7 }) {
          Row() {
            Text(MonthItemModel.getChildSportTypeStr(item.childType))
              .fontColor($r('app.color.color_888888'))
              .fontSize($r('app.float.fp_12'))
              .constraintSize({ minWidth: $r('app.float.vp_18') })

            Text(item.month + '月' + item.day + '日')
              .fontColor($r('app.color.color_888888'))
              .fontSize($r('app.float.fp_12'))
          }.justifyContent(FlexAlign.SpaceBetween)
          .width(CommonConstants.FULL_PERCENT)
          .alignItems(VerticalAlign.Top)
          .height($r('app.float.vp_17'))

          Row() {
            Text((DateUtils.formaterTimeLength(item.timeLength).split(':').slice(1).join(':')) +
              '分钟')
              .fontSize($r('app.float.vp_20'))
              .fontColor($r('app.color.color_333333'))
            Text(Math.floor(item.distance / 1000 * 10) / 10 + '公里')
              .fontSize($r('app.float.vp_20'))
              .margin({ left: $r('app.float.vp_20') })
              .fontColor($r('app.color.color_333333'))
          }
          .height($r('app.float.vp_28'))
        }
        .layoutWeight(1)
        .height('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ top: $r('app.float.vp_16'), bottom: $r('app.float.vp_12') })
      }
      .width('100%')
      .height($r('app.float.vp_100'))
      .backgroundColor(Color.White)
      .padding({ left: $r('app.float.vp_14'), right: $r('app.float.vp_12') })
      .borderRadius(15)
    }
  }

  //顶部tab
  @Builder
  tabBuilder() {
    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
      ForEach(this.vm.sportTypeList, (sportItem: SportItemType, index) => {
        Column({ space: CommonConstants.SPACE_XXS }) {
          Text(sportItem.name)
            .lineHeight(CommonConstants.LINE_HEIGHT_XL)
            .fontWeight(sportItem.itemIndex === this.currentIndex ? FontWeight.Bolder : FontWeight.Normal)
            .fontSize(sportItem.itemIndex === this.currentIndex ? CommonConstants.FONTSIZE_XXL :
              CommonConstants.FONTSIZE_M)
        }
        .height(CommonConstants.BOXH_XL)
        .alignItems(HorizontalAlign.End)
        .onClick(() => {
          this.handleTabClick(index, sportItem)
        })
      }, (item: SportItemType, index: number) => item.name + '_' + item.itemIndex)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding(CommonConstants.PADDING_SM)
    .backgroundColor(Color.Transparent)
  }

  //顶部状态栏
  @Builder
  topBarBuilder() {
    Column() {
    }.height(this.windowModel.windowTopPadding)
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor(Color.Transparent)
  }

  @Builder
  myBuilder() {
    TargetMainPage({
      isEveryDay: false, // 每天目标true，每次目标false
      changeSheetHeight: (sheetHeight: number) => { // 控制半模态高度
        this.sheetHeight = sheetHeight
      },
      parameterSet: (target: string, parameter: string) => { // 返回目标target和值parameter
        promptAction.showToast({ message: 'target:' + target + ',parameter:' + parameter })
      }
    })
  }

  @Styles
  LineStyles(){
    .backgroundColor($r('app.color.color_DCDEE9'))
    .height($r('app.float.vp_8'))
    .width($r('app.float.vp_1'))
    .margin({ left: $r('app.float.vp_10') })
  }

  @Styles
  LineImage(){
    .width($r('app.float.vp_8'))
    .margin({ left: $r('app.float.vp_10') })
  }

  @Styles
  pressedStyle(){
    .aspectRatio(1)
    .draggable(false)
    .stateStyles({
      normal: { .backgroundColor(Color.Transparent)
      },
      pressed: { .backgroundColor($r('sys.color.interactive_pressed'))
      },
    })
  }
}
