import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { sensor } from '@kit.SensorServiceKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { emitter } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { HomeViewModel } from '../viewmodels/HomeViewModel';
import { MoveDataModel, TotalCountParam, TotalData } from 'module_moveratio';
import { NavHeaderBar } from 'lib_widget/Index';
import { CommonConstants, LinearColumnModifier, Logger, RouterMap, RouterUtils, UserInfoModel } from 'lib_common';
import { NavBar } from '../components/NavBar';
import { BMIPage } from 'module_bmiassess';
import { GlobalStore } from './DrinkPage';
import { TargetMainPage, TargetType } from 'module_target';
import { SevenDaysTotalModel, SportServiceApi } from 'lib_sport_api';
import { TargetReminderAgentHelper } from '../util/TargetReminderAgentHelper';

@Builder
export function homePageBuilder(stack: NavPathStack) {
  HomePage({ stack: stack })
}

// 定义一个eventId为1的事件，事件优先级为Low。
let event: emitter.InnerEvent = {
  eventId: 7,
  priority: emitter.EventPriority.LOW
};

@ObservedV2
export class GlobalGoalStore {
  @Trace distance: string = '1';
  @Trace steps: string = '1000';
  @Trace caloric: string = '50';

  getPersistenceName(): string {
    return 'GlobalGoalStore';
  }

  toJson(): string {
    return JSON.stringify({
      distance: this.distance,
      steps: this.steps,
      caloric: this.caloric
    });
  }

  fromJson(json: string): void {
    const obj = JSON.parse(json) as Partial<GlobalGoalStore>
    this.distance = obj.distance ?? '1'
    this.steps = obj.steps ?? '1000'
    this.caloric = obj.caloric ?? '50'
  }
}

@ObservedV2
export class CurrentDataStore {
  @Trace currentDistance: string = '0.0';
  @Trace currentSteps: string = '0';
  @Trace currentCaloric: string = '0.0';
}

@ComponentV2
struct HomePage {
  @Param stack: NavPathStack = new NavPathStack()
  @Local showSheetSteps: boolean = false;
  @Local showSheetDistance: boolean = false;
  @Local showSheetCalorie: boolean = false;
  @Local homeViewModel: HomeViewModel = new HomeViewModel();
  @Local modifier: LinearColumnModifier = new LinearColumnModifier($r('app.color.home_linear'));
  @Local totalCountData: TotalCountParam[] =
    [{
      icon: 'step_logo',
      title: '平均步数',
      count: '0',
      uint: 'step'
    },
      {
        icon: 'distance_logo',
        title: '平均距离',
        count: '0',
        uint: 'km'
      },
      {
        icon: 'calorie_logo',
        title: '平均卡路里',
        count: '0',
        uint: 'kcal'
      }]
  @Local store: GlobalStore = PersistenceV2.connect(GlobalStore, 'global', () => new GlobalStore())!;
  @Local storeGoal: GlobalGoalStore =
    PersistenceV2.connect(GlobalGoalStore, 'global_store', () => new GlobalGoalStore())!;
  @Local storeCurrentData: CurrentDataStore =
    AppStorageV2.connect(CurrentDataStore, 'global_current_data', () => new CurrentDataStore())!;
  @Local sheetHeight: number = 350;
  @Local distance: number = 0 // 距离
  @Local heat: number = 0 // 消耗
  defaultStep: number = -1 // 初始步数
  @Local steps: number = 0 // 当天订阅的步数（增量）
  @Local todayBaseSteps: number = 0 // 当天MockSportRecord中的totalStepCount
  @Local sevenDaysTotalModel: SevenDaysTotalModel = new SevenDaysTotalModel()
  @Provider('homeMoveDataModel') moveDataModel: MoveDataModel = new MoveDataModel()
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  private gradientColor: LinearGradient = new LinearGradient([{ color: '#FF6C36', offset: 0.5 },
    { color: '#FF923D', offset: 1.0 }])
  private lastStep = 0
  private lastDistance = 0
  private lastDeplete = 0
  private hourIntervalId: number | undefined = undefined

  aboutToAppear(): void {
    SportServiceApi.dailyRunningSetting(Number(this.storeGoal.distance), Number(this.storeGoal.steps),
      Number(this.storeGoal.caloric))

    // 初始化当天基础步数
    let todayData = SportServiceApi.getAllData()[0]
    if (todayData) {
      this.todayBaseSteps = todayData.totalStepCount
      this.storeCurrentData.currentSteps = this.todayBaseSteps + ''
    }

    this.todayRunningData()
    this.sevenDaysTotalModel = SportServiceApi.sevenDayTotalData(true)
    SportServiceApi.dailyRunningSetting(Number(this.storeGoal.distance), Number(this.storeGoal.steps),
      Number(this.storeGoal.caloric))
    this.realTimeProcessing()
    try {
      emitter.on('checkPermissionEvent', () => {
        this.todayRunningData()
      })
      emitter.on('AbilityOnForegroundEvent', () => {
        this.todayRunningData()
      })
      emitter.on('AbilityOnBackgroundEvent', () => {
        // 先取消之前的订阅（如果有）
        try {
          sensor.off(sensor.SensorId.PEDOMETER)
        } catch (err) {
          // 忽略取消订阅的错误
        }
      })
    } catch (error) {
      Logger.error('HomePage', 'aboutToAppear error: ' + JSON.stringify(error))
    }
    this.startHourListener()

    // 拉起权限并回调提醒消息
    const
      context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    TargetReminderAgentHelper.getInstance().start(context)
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: $r('app.string.sport_pedometer'),
          isSubTitle: false,
        })
        Scroll() {
          Column() {

            Column({ space: 16 }) {
              // 数据总览
              TotalData({
                totalCountData: this.totalCountData, dataClick: () => {
                  // 判断是否登录
                  if (this.homeViewModel.userInfoModel.isLogin) {
                    RouterUtils.pushPathByName(RouterMap.ATTENDANCE_RECORD_PAGE)
                  } else {
                    RouterUtils.pushPathByName(RouterMap.HUAWEI_LOGIN_PAGE)
                  }
                }, isLogin: this.userInfoModel.isLogin
              })
            }
            .padding({
              left: CommonConstants.PADDING_PAGE,
              right: CommonConstants.PADDING_PAGE,
            })
            .margin({
              bottom: 16
            })

            Column() {
              Column({ space: 16 }) {
                // 今日数据
                Column() {
                  Stack({ alignContent: Alignment.End }) {
                    NavBar({
                      title: $r('app.string.today_data'),
                      typeface: 16,
                      fontLineHeight: 19,
                      fonthue: '#333',
                      paddingLeft: 0,
                      paddingRight: 0,
                    })
                    Row() {
                      Text($r('app.string.management_by_objectives'))
                        .fontColor('#FE6F00').fontSize(14)
                        .lineHeight(20)
                        .textAlign(TextAlign.Center)
                    }
                    .bindSheet($$this.showSheetSteps, this.myBuilder(), {
                      height: this.sheetHeight,
                      backgroundColor: '#fff5eded',
                      showClose: false,
                      preferType: SheetType.CENTER
                    })
                    .onClick(() => {
                      this.showSheetSteps = !this.showSheetSteps
                      this.sheetHeight = 350
                      let eventData: emitter.EventData = {
                        data: {
                          content: 'emitter',
                          id: 7,
                          isEmpty: false
                        }
                      };

                      // 发送eventId为1的事件，事件内容为eventData。
                      try {
                        emitter.emit(event, eventData);
                      } catch (error) {
                        Logger.error('HomePage', 'emitter emit error: ' + JSON.stringify(error))
                      }
                    })
                    .width(80)
                    .height(28)
                    .padding({ top: 4, bottom: 4, left: 12 })
                    .backgroundColor('#FEF5EC')
                    .borderRadius(14)
                    .offset({ x: -10 })
                  }

                  Row() {
                    Row({ space: 3 }) {
                      Text(`${this.storeCurrentData.currentSteps}`)
                        .fontSize(40)
                        .height(48)
                        .lineHeight(48)
                        .fontWeight(500)
                      Text(`/${this.storeGoal.steps}步`)
                        .height(48)
                        .lineHeight(48)
                        .fontColor('#999')
                    }.alignItems(VerticalAlign.Bottom)

                    Stack() {
                      Progress({
                        value: Number(this.storeCurrentData.currentSteps),
                        total: Number(this.storeGoal.steps),
                        type: ProgressType.Ring,
                      })
                        .width(60)
                        .height(60)
                        .style({ strokeWidth: 6 })
                        .color(this.gradientColor)// 设置进度颜色
                        .backgroundColor('#FFF6EF'); // 设置背景颜色

                      Image($r('app.media.foot_step'))
                        .size({ width: 35, height: 35 })
                    }
                    .margin({ top: 10, right: 20 })
                  }.width('100%').justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Bottom)

                  Row() {
                    Stack({ alignContent: Alignment.Bottom }) {
                      Column() {
                        Column() {
                          Text($r('app.string.today'))
                            .textAlign(TextAlign.Start)
                            .fontColor('#555')
                            .fontSize(12)
                            .lineHeight(17)
                            .width('100%')
                          Row() {
                            Text(this.storeCurrentData.currentDistance)
                              .fontColor('#333')
                              .fontSize(32)
                              .lineHeight(38)
                              .fontWeight(500)
                            Text($r('app.string.kilometr'))
                              .fontColor('#888')
                              .fontSize(12)
                              .lineHeight(38)
                          }.width('100%')
                          .alignItems(VerticalAlign.Bottom)
                        }.margin({ top: -50 })
                      }
                      .alignItems(HorizontalAlign.Start)
                      .justifyContent(FlexAlign.Center)
                      .width('48%')
                      .height(178)
                      .backgroundImage($r('app.media.distance_bg'))
                      .backgroundImageSize({
                        width: CommonConstants.FULL_PERCENT,
                        height: CommonConstants.FULL_PERCENT
                      })
                      .padding({ left: 13, right: 13, top: 11 })

                      Column() {
                        Text(`距离目标还剩:${this.homeViewModel.runningRemainderData(this.storeCurrentData.currentDistance,
                          this.storeGoal.distance)}km`)
                          .textAlign(TextAlign.Start)
                          .fontColor('#EC8A35')
                          .fontSize(10)
                          .lineHeight(14)
                          .width('100%')
                          .margin({ left: 1 })
                          .offset({ y: 25 })
                        Slider({
                          value: Number(this.storeCurrentData.currentDistance),
                          min: 0,
                          max: Number(this.storeGoal.distance),
                        })
                          .enabled(false)
                          .blockSize({ width: '5vp', height: '5vp' })
                          .trackThickness('4vp')
                          .width('108%')
                          .margin({ left: -4 })
                          .padding({ top: 0, bottom: 0 })
                          .trackColor($r('sys.color.comp_background_secondary'))
                          .selectedColor($r('sys.color.comp_background_emphasize'))
                          .offset({ y: 15 })
                      }
                      .alignItems(HorizontalAlign.Start)
                      .borderRadius({
                        topLeft: 0,
                        topRight: 0,
                        bottomLeft: 12,
                        bottomRight: 12
                      })
                      .padding({
                        top: 4,
                        bottom: 7,
                        left: 10,
                        right: 10
                      })
                      .width('48%')
                    }

                    Stack({ alignContent: Alignment.TopEnd }) {
                      Stack({ alignContent: Alignment.Bottom }) {
                        Column() {
                          Column() {
                            Text($r('app.string.today'))
                              .textAlign(TextAlign.Start)
                              .fontColor('#555')
                              .fontSize(12)
                              .lineHeight(17)
                              .width('100%')
                            Row() {
                              Text(this.storeCurrentData.currentCaloric)
                                .fontColor('#333')
                                .fontSize(32)
                                .lineHeight(38)
                                .fontWeight(500)
                              Text($r('app.string.calorie'))
                                .fontColor('#888')
                                .fontSize(12)
                                .lineHeight(38)
                            }.width('100%')
                            .alignItems(VerticalAlign.Bottom)
                          }.margin({ top: -50 })
                        }
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.Start)
                        .width('48%')
                        .height(178)
                        .backgroundImage($r('app.media.calorie_bg'))
                        .backgroundImageSize({
                          width: CommonConstants.FULL_PERCENT,
                          height: CommonConstants.FULL_PERCENT
                        })
                        .padding({ left: 13, right: 13, top: 11 })

                        Column({ space: 3 }) {
                          Text(`距离目标还剩:${this.homeViewModel.runningRemainderData(this.storeCurrentData.currentCaloric,
                            this.storeGoal.caloric)}kcal`)
                            .textAlign(TextAlign.Start)
                            .fontColor('#1A867B')
                            .fontSize(10)
                            .lineHeight(14)
                            .width('100%')
                            .margin({ left: 1 })
                            .offset({ y: 28 })
                          Slider({
                            value: Number(this.storeCurrentData.currentCaloric),
                            min: 0,
                            max: Number(this.storeGoal.caloric),
                          })
                            .enabled(false)
                            .blockSize({ width: '5vp', height: '5vp' })
                            .trackThickness('4vp')
                            .width('108%')
                            .padding({ top: 0, bottom: 0 })
                            .trackColor($r('sys.color.comp_background_secondary'))
                            .selectedColor($r('sys.color.comp_background_emphasize'))
                            .margin({ left: -4 })
                            .offset({ y: 15 })
                        }
                        .alignItems(HorizontalAlign.Start)
                        .borderRadius({
                          topLeft: 0,
                          topRight: 0,
                          bottomLeft: 12,
                          bottomRight: 12
                        })
                        .padding({
                          top: 4,
                          bottom: 7,
                          left: 10,
                          right: 10
                        })
                        .width('48%')
                      }

                      Text(`还差${this.homeViewModel.runningRemainderData(this.storeCurrentData.currentSteps,
                        this.storeGoal.steps)}步`)
                        .fontSize(12)
                        .fontColor('#999')
                        .lineHeight(16)
                        .offset({ x: -15, y: 12 })
                    }
                  }.justifyContent(FlexAlign.SpaceBetween).width('100%')
                }
                .padding({ left: 16, right: 16, top: 15 })
                .width('100%')
                .height(306)
                .borderRadius(12)
                .backgroundColor('#fff')
                .onClick(() => {
                  // 存储当天数据
                  let todayData = SportServiceApi.getAllData()[0]
                  if (todayData) {
                    SportServiceApi.todaySportRecord(todayData)
                  }
                  this.saveHourData()
                  // 跳转到步数详情页
                  RouterUtils.pushPathByName(RouterMap.STEP_COUNT_PAGE, null, () => {
                    // 返回时重新初始化订阅步数（从0开始）
                    this.todayRunningData()
                  })
                })

                Row() {
                  BMIPage({
                    isLogin: this.userInfoModel?.isLogin,
                    stack: this.stack,
                    onNeedLogin: () => {
                      // 未登录时跳转到登录页面
                      RouterUtils.pushPathByName(RouterMap.HUAWEI_LOGIN_PAGE)
                    }
                  })
                    .width('48%')
                  Stack() {
                    Image($r('app.media.daily_drink'))
                      .width('98%').height(190)
                      .objectFit(ImageFit.Fill)
                      .borderRadius(14)

                    Column() {
                      Stack({ alignContent: Alignment.BottomEnd }) {
                        NavBar({
                          title: $r('app.string.drink_water'),
                          typeface: 16,
                          fontLineHeight: 22,
                          fonthue: '#4F412E',
                          paddingLeft: 0,
                          paddingRight: 0,
                        }).position({ top: 0 })
                        Image($r('app.media.drink_more')).size({ width: 35, height: 35 })
                      }

                      Column() {
                        Text($r('app.string.today'))
                          .textAlign(TextAlign.Start)
                          .fontColor('#555')
                          .fontSize(12)
                          .lineHeight(17)
                        Row({ space: 5 }) {
                          Text(this.userInfoModel.isLogin ? this.store.drinkedWater?.toString() : '--')
                            .fontColor('#333')
                            .fontSize(32)
                            .lineHeight(38)
                            .fontWeight(500)
                          Text('ml').fontColor('#888').fontSize(12).lineHeight(38)
                        }.alignItems(VerticalAlign.Bottom)
                      }
                      .width('100%')
                      .alignItems(HorizontalAlign.Start)
                    }
                    .width('100%')
                    .height('100%')
                    .borderRadius(12)
                    .padding({ left: 13, right: 13, top: 12 })
                  }
                  .width('48%')
                  .height('190')
                  .onClick(() => {
                    RouterUtils.pushPathByName(RouterMap.DRINK_PAGE)
                  })
                }
                .width('100%')
                .height(190)
                .justifyContent(FlexAlign.SpaceBetween)
              }

              Column() {
                Text($r('app.string.all_sports_records'))
                  .textAlign(TextAlign.Center)
                  .fontColor('#888')
                  .fontSize(14)
                  .lineHeight(18)
              }
              .onClick(() => {
                RouterUtils.pushPathByName(RouterMap.ALL_SPORT_RECORDS_PAGE)
              })
              .alignItems(HorizontalAlign.Center)
              .margin({ top: 31 })
              .width(185)
              .height(27)
              .backgroundColor($r('sys.color.background_primary'))
              .borderRadius(14)
              .padding({ top: 5, bottom: 5 })
            }.padding({
              left: CommonConstants.PADDING_PAGE,
              right: CommonConstants.PADDING_PAGE,
            })
          }
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .enableScrollInteraction(true)
        .layoutWeight(1)
        .width(CommonConstants.FULL_PERCENT)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .backgroundColor(Color.Transparent)
        .padding({
          bottom: CommonConstants.PADDING_PAGE
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .layoutWeight(1)
      .attributeModifier(this.modifier)
      .linearGradient({
        repeating: false,
        direction: GradientDirection.Bottom,
        colors: [['#FFC385', 0], ['#FFE7CC', 0.5], ['#F1F3F5', 1]]
      })
    }
    .hideTitleBar(true)
  }

  aboutToDisappear(): void {
    // 停止订阅步数
    try {
      sensor.off(sensor.SensorId.PEDOMETER)
    } catch (error) {
      Logger.error('HomePage', 'aboutToDisappear sensor off error: ' + JSON.stringify(error))
    }
    this.defaultStep = -1
    // 存储当天数据
    let todayData = SportServiceApi.getAllData()[0]
    if (todayData) {
      SportServiceApi.todaySportRecord(todayData);
    }
    this.endHourListener()
  }

  // 获取今日运动数据
  todayRunningData() {
    // 先取消之前的订阅（如果有）
    try {
      sensor.off(sensor.SensorId.PEDOMETER)
    } catch (err) {
      // 忽略取消订阅的错误
    }

    // 获取今日步数
    let todayData = SportServiceApi.getAllData()[0]
    if (todayData) {
      this.todayBaseSteps = todayData.totalStepCount // 保存MockSportRecord中的步数
      this.heat = todayData.totalDeplete
      this.distance = todayData.totalDistance
    }

    // 重置订阅步数计数器（让订阅步数从0开始）
    this.steps = 0
    this.defaultStep = -1

    // 更新初始显示
    this.storeCurrentData.currentSteps = this.todayBaseSteps + ''

    // 订阅步数实时更新
    try {
      sensor.on(sensor.SensorId.PEDOMETER, (data: sensor.PedometerResponse) => {
        if (this.defaultStep === -1) {
          this.defaultStep = data.steps
          return
        }
        // 订阅的步数（增量）
        this.steps = data.steps - this.defaultStep

        // 总步数 = MockSportRecord中的步数 + 订阅增量
        const totalSteps = this.todayBaseSteps + this.steps
        SportServiceApi.steps = this.steps
        this.storeCurrentData.currentSteps = totalSteps + ''

        // 根据订阅步数计算距离和卡路里
        this.heat = Math.round(this.steps * 0.04)
        this.distance = Number((this.steps * 0.75 / 1000).toFixed(2));

        SportServiceApi.heat = this.heat
        SportServiceApi.distance = this.distance
        this.storeCurrentData.currentDistance = this.distance + ''
        this.storeCurrentData.currentCaloric = this.heat + ''
        // 实际计算近七日实际数据
        this.realTimeProcessing()
      }, { interval: 100000000 });
    } catch (err) {
      hilog.error(0x0000, 'today_running',
        `Failed to subscribeSteps. Code: ${err.code}, message: ${err.message}`);
    }
  }

  /**
   * 计算整点数据
   */
  startHourListener() {
    this.lastStep = Number(this.storeCurrentData.currentSteps)
    this.lastDistance = Number(this.storeCurrentData.currentDistance)
    this.lastDeplete = Number(this.storeCurrentData.currentCaloric)
    this.hourIntervalId = setInterval(() => {
      this.saveHourData()
    }, 1000 * 60)
  }

  saveHourData() {
    let lastHour = new Date().getHours()
    let tempLastStep = Number(this.storeCurrentData.currentSteps)
    let tempLastDistance = Number(this.storeCurrentData.currentDistance)
    let tempLastDeplete = Number(this.storeCurrentData.currentCaloric)
    SportServiceApi.saveHourSportRecord(lastHour, tempLastStep - this.lastStep,
      (tempLastDistance - this.lastDistance) * 1000, tempLastDeplete - this.lastDeplete)
    this.lastStep = tempLastStep
    this.lastDistance = tempLastDistance
    this.lastDeplete = tempLastDeplete
  }

  endHourListener() {
    clearInterval(this.hourIntervalId)
  }

  // 实际计算近七日实际数据
  realTimeProcessing() {
    this.totalCountData[0].count = Math.round((this.sevenDaysTotalModel.stepData[0] + this.steps) / 7) + '';
    this.totalCountData[1].count =
      Math.floor((this.sevenDaysTotalModel.distanceData[0] + this.distance) / 7000 * 10) / 10 + '';
    this.totalCountData[2].count = Math.round((this.sevenDaysTotalModel.caloriesData[0] + this.heat) / 7) + '';
    this.totalCountData = [...this.totalCountData]
    // 实时计算近七日三环数据
    this.moveDataModel.stepData[0] = Math.round((this.moveDataModel.stepData[1] + Number(this.storeGoal.steps)) / 7);
    this.moveDataModel.distanceData[0] =
      Math.floor((this.moveDataModel.distanceData[1] + Number(this.storeGoal.distance) / 7000 * 10) / 10);
    this.moveDataModel.caloriesData[0] =
      Math.round((this.moveDataModel.caloriesData[1] + Number(this.storeGoal.caloric)) / 7);
  }

  @Builder
  myBuilder() {
    TargetMainPage({
      isEveryDay: true, // 每天目标true，每次目标false
      changeSheetHeight: (sheetHeight: number) => { // 控制半模态高度
        this.sheetHeight = sheetHeight
      },
      parameterSet: (target: Resource | string, parameter: string) => { // 返回目标target和值parameter
        switch (target) {
          case TargetType.Distance:
            const distanceData = parameter.match(/(\d+(?:\.\d+)?)/)?.[0] ?? '';
            this.storeGoal.distance = distanceData
            break;
          case TargetType.Steps:
            const stepData = parameter.match(/\d+/g)?.[0] ?? '';
            this.storeGoal.steps = stepData
            break;
          case TargetType.Heat:
            const caloricData = parameter.match(/\d+/g)?.[0] ?? '';
            this.storeGoal.caloric = caloricData
            break;
        }
        SportServiceApi.dailyRunningSetting(Number(this.storeGoal.distance), Number(this.storeGoal.steps),
          Number(this.storeGoal.caloric))
        this.showSheetDistance = false
        this.showSheetSteps = false
        this.showSheetCalorie = false
        PersistenceV2.save(this.storeGoal.toJson());
      }
    })
  }
}