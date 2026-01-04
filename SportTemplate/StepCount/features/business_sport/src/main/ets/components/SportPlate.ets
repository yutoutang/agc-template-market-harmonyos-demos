import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { sensor } from '@kit.SensorServiceKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import {
  BroadCastUtils,
  CommonConstants,
  LinearColumnModifier,
  RouterMap,
  RouterUtils,
  RunningVoiceSetting,
  WindowModel
} from 'lib_common';
import { SportItemType, WalkType } from '../types/Types';
import { SportViewModel } from '../viewmodels/SportVM';
import { TargetMainPage } from 'module_target';
import { MotionType, SportItem, TargetType } from 'module_running/src/main/ets/viewmodels/RealTimeMotionVM';
import { executionStatus, TimeMainPage, TimerExerciseData } from 'module_timer';
import { ChildSportType, PreferenceUtil, SportServiceApi, SportType } from 'lib_sport_api';
import { Logger } from 'ui_base';


export interface RunningVoiceModel {
  step: number;
  finish: boolean;
}

@ComponentV2
export struct SportPlate {
  @Param sportTypeList: SportItemType[] = []
  @Param windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Param currentIndex: number = 1
  @Event currentIndexChange: (index: number, name: string) => void
  @Event operation: (isRoute: boolean) => void
  @Local mapImage: ResourceStr = $r('app.media.home_map_img')
  @Local currentWalkType: number = 0
  @Param vm: SportViewModel = new SportViewModel()
  @Param totalTypeDistance: number[] = []
  @Param continuousDays: number = 0
  @Local backColors: string[] = this.vm.walkBackColors
  stack: NavPathStack = new NavPathStack()
  @Local sheetHeight: number = 350;
  @Local isShow: boolean = false;
  @Consumer('isRunning') isRunning: executionStatus = executionStatus.over
  @Consumer('selectedIndex') selectedIndex: number = 0
  @Local target: string = '' // 目标类型
  @Local targetParameter: string = '' // 目标参数
  @Param sportTypes: SportType = SportType.WALKING
  @Local motionType: MotionType = MotionType.isFreedom
  @Local checkPermission: boolean = true
  // 计时运动语音播报相关
  @Local runningVoiceSetting: RunningVoiceSetting =
    AppStorageV2.connect(RunningVoiceSetting, 'runningVoiceSetting', () => new RunningVoiceSetting())!
  @Local runningVoiceModel: RunningVoiceModel[] = [
    { step: 30, finish: false },
    { step: 50, finish: false },
    { step: 80, finish: false },
    { step: 100, finish: false }
  ]
  //实时配速 步数 热量
  @Local allCount: number = 0
  @Local nowCount: number = 0
  @Local steps: number = 0
  @Local timer: number = 0
  @Local cll: number = 0
  @Local pace: string = '00\’00\’\’'
  @Local distance: number = 0
  @Local distanceMap: Map<number, number> = new Map();
  @Local progressValue: number = 0; // 当前进度百分比
  @Local hour: number = 0
  @Local minute: number = 0
  @Local second: number = 0
  private isSubscribed: boolean = false; // 是否已订阅传感器
  private previousSteps: number = 0; // 上一次的步数，用于计算增量
  private hasStarted: boolean = false; // 标记是否真正开始过运动
  private readonly DEFAULT_WEIGHT: number = 65; // 默认体重65kg
  private readonly CALORIES_PER_STEP: number = 0.04; // 每步约消耗0.04千卡（平均值）
  private readonly AVERAGE_STEP_LENGTH: number = 0.7; // 平均步长0.7米
  private defaultSteps: number = -1; // 步数标识符
  @Event isRunningChange: (status: executionStatus) => void =
    (status: executionStatus) => {
      // do nothing
    };
  @Event onSaveRecord: (recordData: TimerExerciseData) => void =
    (recordData: TimerExerciseData) => {
      // do nothing
    };
  @Event onProgressChange: (progress: number) => void =
    (progress: number) => {
      // do nothing
    };

  // 订阅步数传感器，使用与RealTimeMotionComponent完全相同的方法
  subscribeSteps() {
    // 订阅步数实时更新
    try {
      sensor.on(sensor.SensorId.PEDOMETER, (data: sensor.PedometerResponse) => {
        let step: number = data.steps ?? 0
        // 与RealTimeMotionVM完全一致的逻辑
        if (this.isRunning === executionStatus.Pause) {
          this.defaultSteps = step
        } else {
          if (this.defaultSteps === -1) {
            this.defaultSteps = step
          } else {
            const increment = step - this.defaultSteps
            this.steps += increment
            this.defaultSteps = step
          }
        }
      });
    } catch (err) {
      hilog.error(0x0000, 'queryListInfo',
        `Failed to subscribeSteps. Code: ${err.code}, message: ${err.message}`);
    }
  }

  // 监听步数实时计算热量
  @Monitor('steps')
  estimateCalories() {
    // 基础热量计算：步数 × 每步基础消耗 × 体重系数
    // 体重系数 = 实际体重 / 标准体重(65kg)
    const weightFactor = this.DEFAULT_WEIGHT / this.DEFAULT_WEIGHT;
    const baseCalories = this.steps * this.CALORIES_PER_STEP;

    // 根据体重调整热量消耗
    const adjustedCalories = baseCalories * weightFactor;
    // 返回整数结果
    this.cll = Math.round(adjustedCalories);

  }

  // 启动计时运动的数据计算
  startTimerExercise() {
    // 订阅步数传感器，使用与RealTimeMotionComponent相同的方法（只订阅一次）
    if (!this.isSubscribed) {
      this.subscribeSteps();
      this.isSubscribed = true;
    }

    // 标记已真正开始运动
    this.hasStarted = true;

    //距离速度配置
    this.timer = setInterval(() => {
      // 清理距离map，使用与RealTimeMotionComponent相同的方法
      this.cleanupOldData();

      // 基于步数增量计算距离增量（与健走逻辑一致）
      const stepIncrement = this.steps - this.previousSteps;
      if (stepIncrement > 0) {
        const distanceIncrement = stepIncrement * this.AVERAGE_STEP_LENGTH; // 米
        this.addDistance(distanceIncrement);
        this.distance += distanceIncrement / 1000; // 转换为公里显示
        this.previousSteps = this.steps;
      }

      // 计算配速，使用与RealTimeMotionComponent相同的方法
      this.pace = this.calculatePace();

      // 通过emitter通知数据变化（距离、消耗、配速）
      try {
        emitter.emit('timeMainPageDataChange', {
          data: {
            distance: this.distance,
            cll: this.cll,
            pace: this.pace
          }
        });
      } catch (error) {
        Logger.error('SportPlate', 'emitter emit timeMainPageDataChange error: ' + JSON.stringify(error));
      }
    }, 1000)
  }

  // 暂停计时运动
  pauseTimerExercise() {
    clearInterval(this.timer)
    // 暂停时保持步数记录，不重置 previousSteps
  }

  // 结束计时运动
  stopTimerExercise(actualTimeLength: number, shouldSave: boolean) {
    // 避免重复保存：如果已经保存过，直接返回
    if (this.isRunning === executionStatus.over && actualTimeLength === 0) {
      // 如果运动已经结束且实际时长为0，说明可能是重复调用，直接返回
      return;
    }

    if (this.isRunning === executionStatus.Pause) {
      clearInterval(this.timer)
      // 暂停时保持步数记录，不重置 previousSteps
    }

    // 创建新的数组实例以确保触发响应式更新
    this.runningVoiceModel = [
      { step: 30, finish: false },
      { step: 50, finish: false },
      { step: 80, finish: false },
      { step: 100, finish: false }
    ]

    // 记录当前数据用于保存
    const savedDistance = this.distance;
    const savedSteps = this.steps;
    const savedCll = this.cll;

    // 重置运动数据
    clearInterval(this.timer)
    // 取消订阅步数传感器
    if (this.isSubscribed) {
      try {
        sensor.off(sensor.SensorId.PEDOMETER);
      } catch (error) {
        Logger.error('SportPlate', 'sensor off error: ' + JSON.stringify(error));
      }
      this.isSubscribed = false;
    }
    this.distance = 0
    this.cll = 0
    this.steps = 0
    this.pace = '00\'00\'\''
    this.defaultSteps = -1
    this.distanceMap.clear()
    this.previousSteps = 0
    this.hasStarted = false // 重置运动开始标志
    this.progressValue = 0 // 重置进度

    // 通过emitter通知数据重置
    try {
      emitter.emit('timeMainPageDataChange', {
        data: {
          distance: this.distance,
          cll: this.cll,
          pace: this.pace
        }
      });
    } catch (error) {
      Logger.error('SportPlate', 'emitter emit timeMainPageDataChange error: ' + JSON.stringify(error));
    }

    // 最后再保存记录（使用保存的数据）
    if (shouldSave) {
      this.saveTimerExerciseRecord(actualTimeLength, savedDistance, savedSteps, savedCll);
    }
  }

  // 计算配速，使用与RealTimeMotionComponent完全相同的方法
  calculatePace(): string {
    // 数据不足时返回0（与RealTimeMotionComponent保持一致）
    if (this.distanceMap.size === 0 || this.distanceMap.size < 2) {
      return '00’00’’';
    }

    // 计算总距离（米）
    let totalDistance = 0;
    for (const distance of this.distanceMap.values()) {
      totalDistance += distance;
    }

    // 计算速度（米/秒）
    const speedMps = totalDistance / 10;

    // 如果速度为0或距离太小，返回默认值
    if (speedMps === 0 || totalDistance < 10) {
      return '00’00’’';
    }

    // 计算每公里需要的时间（秒）
    const timePerKmSeconds = 1000 / speedMps;

    // 转换为分钟和秒
    const minutes = Math.floor(timePerKmSeconds / 60).toFixed(2);
    const seconds = Math.floor(timePerKmSeconds % 60).toFixed(2);

    // 格式化为 '分'秒''/公里' 格式
    return `${minutes}'${seconds.toString().padStart(2, '0')}''`;
  }

  // 添加距离数据，使用与RealTimeMotionComponent相同的方法
  addDistance(distance: number): void {
    const currentTime = Date.now();
    // 添加新的距离数据
    this.distanceMap.set(currentTime, distance);
  }

  // 清理超过10秒的旧数据，使用与RealTimeMotionComponent相同的方法
  cleanupOldData(): void {
    const currentTime = Date.now();
    const tenSecondsAgo = currentTime - 10000; // 10秒前的时间戳

    // 遍历所有键，删除超过10秒的数据
    for (const timestamp of this.distanceMap.keys()) {
      if (timestamp < tenSecondsAgo) {
        this.distanceMap.delete(timestamp);
      }
    }
  }

  // 监听页面显示，查询权限状态
  @Monitor('selectedIndex')
  async onPageShowChange() {
    this.checkPermission = await LinearColumnModifier.checkPermissions(LinearColumnModifier.permissions)
  }

  // 保存计时运动记录
  saveTimerExerciseRecord(actualTimeLength: number, savedDistance: number, savedSteps: number, savedCll: number) {
    // 获取当前时间
    const now = new Date();
    const hour = now.getHours();
    const minute = now.getMinutes();

    // 设置SportServiceApi的实时数据（用于累加到totalStepCount、totalDistance、totalDeplete）
    // savedDistance 已经是公里单位，直接使用
    SportServiceApi.steps = savedSteps
    SportServiceApi.distance = savedDistance // 已经是公里
    SportServiceApi.heat = savedCll

    // 构造运动记录对象
    const sportItem: SportItem = {
      type: SportType.CLOCK_BASE_EXCERCISE,
      childType: ChildSportType.TIMING_SPORT,
      hour: hour,
      minute: minute,
      distance: Math.round(savedDistance * 1000), // 转换为米
      timeLength: actualTimeLength,
      deplete: savedCll,
      stepCount: savedSteps,
      locusPoints: []
    };

    // 保存运动记录（会自动累加到totalStepCount、totalDistance、totalDeplete）
    SportServiceApi.saveTodaySportItem(sportItem as ESObject);

    // 触发更新记录事件
    try {
      emitter.emit('updateRecord');
      promptAction.showToast({ message: '运动记录已保存' });
    } catch (error) {
      Logger.error('SportPlate', 'updateRecord error: ' + JSON.stringify(error));
    }
  }

  async aboutToAppear(): Promise<void> {
    let sportPermission = PreferenceUtil.getInstance().get(PreferenceUtil.OPEN_SPORT_PERMISSION)
    if (sportPermission !== undefined && !PreferenceUtil.getInstance().get(PreferenceUtil.OPEN_SPORT_PERMISSION)) {
      this.checkPermission = await LinearColumnModifier.checkPermissions(LinearColumnModifier.permissions)
    }
    // 监听其它事件
    this.onOtherEvent()

    // 监听计时结束事件
    this.onTimeMainPageTimerOver();

    // 监听计时进度变化事件
    this.onTimeMainPageTimerProgress();

    // 监听时间变化事件
    this.onTimeMainPageTimeChange();
  }

  // 监听其它事件
  onOtherEvent() {
    try { // 检查开启权限事件
      emitter.on('checkPermissionEvent', async () => {
        this.checkPermission = await LinearColumnModifier.checkPermissions(LinearColumnModifier.permissions)
      })
      // 检查用户系统开启权限事件
      emitter.on('AbilityOnForegroundEvent', async () => {
        let sportPermission = PreferenceUtil.getInstance().get(PreferenceUtil.OPEN_SPORT_PERMISSION)
        if (sportPermission !== undefined && !PreferenceUtil.getInstance().get(PreferenceUtil.OPEN_SPORT_PERMISSION)) {
          this.checkPermission = await LinearColumnModifier.checkPermissions(LinearColumnModifier.permissions)
        }
      })
      // 运动类型选择双向事件
      emitter.on('SportPlateMotionTypeIndexEvent', (data) => {
        if (data.data) {
          this.currentWalkType = data.data.index as number
        }
      })
      // 监听timeMainPage数据变化事件
      emitter.on('timeMainPageDataChange', (data) => {
        if (data?.data) {
          this.distance = data.data.distance ?? this.distance
          this.cll = data.data.cll ?? this.cll
          this.pace = data.data.pace ?? this.pace
        }
      })

      // 监听计时开始事件
      emitter.on('timeMainPageTimerStart', () => {
        this.startTimerExercise();
      })

      // 监听计时暂停事件
      emitter.on('timeMainPageTimerPause', () => {
        this.pauseTimerExercise();
      })
    } catch (error) {
      Logger.error('SportPlate', 'onOtherEvent error: ' + JSON.stringify(error));
    }
  }

  // 监听计时结束事件
  onTimeMainPageTimerOver(): void {
    try {
      emitter.on('timeMainPageTimerOver', (data) => {
        if (data?.data) {
          const actualTimeLength: number = data.data.actualTimeLength ?? 0;
          const shouldSave: boolean = data.data.shouldSave ?? false;
          // 手动结束时，只要实际运动时长大于0且已经真正开始过运动，就应该保存
          // 倒计时自然结束时，timeMainPage 已经正确计算了 shouldSave，直接使用即可
          const finalShouldSave = shouldSave || (actualTimeLength > 0 && this.hasStarted);
          this.stopTimerExercise(actualTimeLength, finalShouldSave);
        }
      })
    } catch (error) {
      Logger.error('SportPlate', 'emitter on timeMainPageTimerOver error: ' + JSON.stringify(error));
    }
  }

  // 监听计时进度变化事件
  onTimeMainPageTimerProgress(): void {
    try {
      emitter.on('timeMainPageTimerProgress', (data) => {
        if (data?.data) {
          this.allCount = data.data.allCount ?? this.allCount;
          this.nowCount = data.data.nowCount ?? this.nowCount;
          this.progressValue = data.data.progressValue ?? this.progressValue;
          // 如果运动已经结束，不触发进度更新和播报
          if (this.isRunning !== executionStatus.over) {
            // 通知父组件进度变化（用于语音播报）
            this.onProgressChange(this.progressValue);
          }
        }
      })
    } catch (error) {
      Logger.error('SportPlate', 'emitter on timeMainPageTimerProgress error: ' + JSON.stringify(error));
    }
  }

  // 监听时间变化事件
  onTimeMainPageTimeChange(): void {
    try {
      emitter.on('timeMainPageTimeChange', (data) => {
        if (data?.data) {
          this.allCount = data.data.allCount ?? this.allCount;
          this.nowCount = data.data.nowCount ?? this.nowCount;
        }
      })
    } catch (error) {
      Logger.error('SportPlate', 'emitter on timeMainPageTimeChange error: ' + JSON.stringify(error));
    }
  }

  aboutToDisappear(): void {
    try { // 取消emitter监听
      emitter.off('timeMainPageDataChange');
      emitter.off('timeMainPageTimerStart');
      emitter.off('timeMainPageTimerPause');
      emitter.off('timeMainPageTimerOver');
      emitter.off('timeMainPageTimerProgress');
      emitter.off('timeMainPageTimeChange');
      // 组件销毁时取消订阅
      if (this.isSubscribed) {
        sensor.off(sensor.SensorId.PEDOMETER);
        this.isSubscribed = false;
      }
      if (this.timer) {
        clearInterval(this.timer);
      }
    } catch (error) {
      Logger.error('SportPlate', 'aboutToDisappear error: ' + JSON.stringify(error));
    }
  }

  // 目标设置
  @Builder
  myBuilder() {
    TargetMainPage({
      isEveryDay: false, // 每天目标true，每次目标false
      changeSheetHeight: (sheetHeight: number) => { // 控制半模态高度
        this.sheetHeight = sheetHeight
      },
      parameterSet: (target: string, parameter: string) => { // 返回目标target和值parameter
        this.isShow = false
        this.target = target
        this.targetParameter = parameter
      }
    })
  }

  build() {
    Column({ space: this.sportTypeList[this.currentIndex].name === '计时运动' ? 0 : CommonConstants.SPACE_SM }) {
      this.ContentBuilder()
    }
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor(Color.Transparent)
    .padding({
      left: CommonConstants.PADDING_PAGE,
      right: CommonConstants.PADDING_PAGE,
      top: this.windowModel.windowTopPadding + CommonConstants.PADDING_PAGE,
      bottom: CommonConstants.PADDING_PAGE
    })
    .bindSheet($$this.isShow, this.myBuilder(), {
      height: this.sheetHeight,
      backgroundColor: '#fff5eded',
      showClose: true,
      preferType: SheetType.CENTER
    })
  }

  @Builder
  ContentBuilder() {
    if (this.sportTypeList[this.currentIndex].name === '计时运动') {
      // 运动-计时
      this.PaceBuilder()
    } else {
      // 运动-累计
      this.AccumulatedBuilder()
      // 运动-GO
      this.SportTypeBuilder()
      this.RecordingBuilder()
    }
  }

  // 计时运动
  @Builder
  PaceBuilder() {
    // 计时运动
    TimeMainPage({
      isRunningChange: (status: executionStatus) => {
        this.isRunning = status
      },
      onProgressChange: (progress: number) => {
        // 语音播报逻辑（与RealTimeMotionPage一致）
        if (this.runningVoiceSetting.clockBaseVoiceOn && progress > 10) {
          for (let i = 0; i < this.runningVoiceModel.length; i++) {
            if (progress >= this.runningVoiceModel[i].step && !this.runningVoiceModel[i].finish) {
              // 创建新的数组实例（深拷贝每个对象）以确保触发响应式更新
              const newModel = this.runningVoiceModel.map((item, index) => {
                if (index === i) {
                  return { step: item.step, finish: true } as RunningVoiceModel
                }
                return { step: item.step, finish: item.finish } as RunningVoiceModel
              })
              this.runningVoiceModel = newModel

              // 特殊处理100%的播报
              if (this.runningVoiceModel[i].step === 100) {
                BroadCastUtils.speak('已完成目标')
              } else {
                BroadCastUtils.speak(`已完成目标的${this.runningVoiceModel[i].step}`)
              }
              break
            }
          }
        }
      }
    })
      .margin({ top: -40 })
      .bindSheet($$this.isShow, this.myBuilder(), {
        height: this.sheetHeight,
        backgroundColor: '#fff5eded',
        showClose: true,
        preferType: SheetType.CENTER
      })

    // 配速模块
    Row() {
      Column() {
        Text(this.distance.toFixed(2))
          .fontSize(32)
        Text('公里')
          .margin({ top: 10 })
          .fontColor('#888888')
          .fontSize(12)
      }

      Column() {
        Text(String(Math.round(this.cll)))
          .fontSize(32)
        Text('消耗（千卡）')
          .margin({ top: 10 })
          .fontColor('#888888')
          .fontSize(12)
      }

      Column() {
        Text(String(this.pace))
          .fontSize(32)
        Text('实时配速')
          .margin({ top: 10 })
          .fontColor('#888888')
          .fontSize(12)
      }
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceAround)
    .visibility(this.isRunning === executionStatus.over ? Visibility.None : Visibility.Visible)
    .height(130)
    .backgroundColor(Color.White)
    .borderRadius(7)
    .width('97%')
    .margin({
      top: 60
    })
  }

  // 运动-累计总距离
  @Builder
  AccumulatedBuilder() {
    Column() {
      Row() {
        Text(String((this.totalTypeDistance[this.currentIndex] / 1000).toFixed(1)))
          .fontWeight(FontWeight.Medium)
          .fontSize(55)
          .lineHeight(64)
          .fontColor('#542001')
        Text($r('app.string.KM'))
          .fontSize(16)
          .lineHeight(64)
          .fontColor('#A6542001')
      }.width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Bottom)
      .margin({ top: -20 })

      Text('累计总距离')
        .fontSize(14)
        .lineHeight(20)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.color_542001'))
        .width(CommonConstants.FULL_PERCENT)
        .textAlign(TextAlign.Center)
    }
  }

  /**
   * 运动-GO
   */
  @Builder
  SportTypeBuilder() {
    Stack() {
      // 地图背景
      Column() {
        Image(this.mapImage)
          .width('100%')
          .objectFit(ImageFit.Fill)
      }.width('100%')

      Column() {
        Row() {
          // 左侧：连续打卡天数
          Text() {
            Span($r('app.string.clock'))
              .fontSize(11)
              .lineHeight(16)
              .fontColor('#666666')
            Span(this.continuousDays + '')
              .fontSize(12)
              .lineHeight(16)
              .fontColor('#000000')
            Span('天')
              .fontSize(6)
              .lineHeight(6)
              .fontColor('#666666')
          }
          .padding({
            left: 5,
            right: 5,
            top: 4,
            bottom: 4
          })

          // 右侧：运动类型
          Row({ space: 2 }) {
            ForEach(this.vm.walkTypeList[this.currentIndex - 1], (walkItem: WalkType, index) => {
              Text(walkItem.name)
                .borderRadius(CommonConstants.RADIUS_XL)
                .padding({
                  left: 16,
                  right: 16,
                  top: 5,
                  bottom: 5
                })
                .fontColor('#333')
                .fontSize(11)
                .lineHeight(13)
                .opacity(walkItem.itemIndex === this.currentWalkType ? 1 : 0.6)
                .backgroundColor(this.currentWalkType === walkItem.itemIndex ? '#fff' : '#7dffffff')
                .onClick(() => {
                  this.currentWalkType = index
                  this.motionType =
                    index === 1 ? MotionType.target : index === 0 ? MotionType.isFreedom : MotionType.walkDog

                })
            }, (item: WalkType, index: number) => item.name)
          }
          .padding(3)
          .backgroundColor('#7dffffff')
          .border({ width: 1, color: '#f4f4f4', radius: 25 })
        }.width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ top: 13, left: 11, right: 4 })

        // 开启位置权限按钮
        Column({ space: 5 }) {
          Row({ space: 10 }) {
            Text($r('app.string.open_location_rights'))
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
            Image($r('app.media.arrow_right_black'))
              .size({ width: 18, height: 18 })
          }.width('100%').justifyContent(FlexAlign.Center)

          Row() {
            Text($r('app.string.visit_your_location_infomation'))
              .fontColor($r('app.color.color_666666'))
              .fontSize(10)
              .textAlign(TextAlign.Center)
              .lineHeight(12)
          }.width('80%')
        }
        .width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.Center)
        .margin({ top: 20 })
        .visibility(this.checkPermission ? Visibility.Visible : Visibility.Hidden)
        .onClick(() => {
          AppStorage.setOrCreate('applyLocationRightsParams', { 'type': '1' } as ESObject)
          RouterUtils.pushPathByName(RouterMap.APPLY_LOCATION_RIGHTS)
        })

        // 目标设置入口
        Row() {
          Text(this.targetParameter === '' ? $r('app.string.target_set') :
            $r('app.string.targets', this.targetParameter))
            .fontColor('#888')
            .backgroundColor(Color.White)
            .fontSize(12)
            .border({ width: 1, color: '#f4f4f4', radius: 25 })
            .width('100vp')
            .height('30vp')
            .textAlign(TextAlign.Center)
            .visibility(this.currentWalkType === 1 ? Visibility.Visible : Visibility.None)
            .onClick(() => {
              this.isShow = true
            })

        }.margin({ top: 10 })

        // 进入开始运动入口GO
        Image($r('app.media.walking_go'))
          .position({ bottom: -12, left: '50%' })
          .translate({ x: '-50%' })
          .width(73)
          .onClick(() => {
            if (this.currentWalkType === 1 && this.target === '') {
              promptAction.showToast({ message: '请配置目标' })
              return
            }
            const valueToTargetType: Record<string, TargetType> = {
              '距离': TargetType.DISTANCE,
              '热量': TargetType.DEPLETE,
              '时长': TargetType.TIME_LENGTH,
              '配速': TargetType.PACE
            };

            // 调整设置权限页面
            if (this.checkPermission) {
              AppStorage.setOrCreate('applyLocationRightsParams', {
                'type': '2',
                'sportType': this.sportTypes,
                'target': this.target !== '' ? valueToTargetType[this.target] : '',
                'params': this.targetParameter,
                'motionTypeIndex': this.currentWalkType,
                'motionType': this.motionType
              } as ESObject)
              RouterUtils.pushPathByName(RouterMap.APPLY_LOCATION_RIGHTS)
              return
            }

            RouterUtils.pushPathByName(RouterMap.REAL_TIME_MOTION_PAGE,
              {
                'sportType': this.sportTypes,
                'target': this.target !== '' ? valueToTargetType[this.target] : '',
                'params': this.targetParameter,
                'motionType': this.motionType
              } as ESObject, (value: PopInfo) => {
                if (value.result) {
                  SportServiceApi.saveTodaySportItem(value.result as ESObject)
                  this.operation(false)
                }
              })
          })
          .zIndex(2)

        //查看路线入口
        Row() {
          Row({ space: 3 }) {
            Image($r('app.media.route')).width(11)
            Text($r('app.string.route'))
              .fontColor('#333')
              .fontSize(11)
              .lineHeight(13)
          }
          .borderRadius(12.5)
          .backgroundColor('#fff')
          .padding({
            left: 10,
            right: 8,
            top: 6,
            bottom: 6
          })
          .onClick(() => {
            this.operation(true)
          })
        }.width('100%')
        .padding({ right: 8 })
        .justifyContent(FlexAlign.End)
        .margin({ bottom: 20 })
      }.width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .aspectRatio(4 / 3)
      .position({ y: CommonConstants.POSITION_TOP_ZERO })
    }.width(CommonConstants.FULL_PERCENT)
  }

  @Builder
  RecordingBuilder() {
    Row() {
      Text(`${this.sportTypeList[this.currentIndex].name}记录`)// 请替换为你的图片资源
        .fontColor('#e6000000')
        .lineHeight(22)
        .fontWeight(FontWeight.Bold)

      Text('全部记录')// 请替换为你的图片资源
        .fontColor('#e6666666')
        .fontSize(12)
        .lineHeight(17)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%') // 关键：外层Row必须设置宽度
    .onClick(() => {
      RouterUtils.pushPathByName(RouterMap.ALL_SPORT_RECORDS_PAGE)
    })
  }
}

