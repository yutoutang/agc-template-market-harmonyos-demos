import { hilog } from '@kit.PerformanceAnalysisKit';
import { sensor } from '@kit.SensorServiceKit';
import { mapCommon } from '@kit.MapKit';

export enum MoveState {
  startMove,
  stopMove,
  pauseMove
}

export enum MotionType {
  isFreedom = '自由',
  target = '目标',
  walkDog = '遛狗'
}

export enum TargetType {
  //距离
  DISTANCE = '距离',
  //消耗
  DEPLETE = '热量',
  //时长
  TIME_LENGTH = '时长',
  //配速
  PACE = '配速'
}

export interface SportItemTarget {
  //目标类型
  targetType: TargetType
  //目标值  距离：单位米   消耗：单位千卡   时长：单位秒   配速：单位秒
  value: number
}

export enum SportType {
  //所有运动
  ALL,
  //步行
  WALKING,
  //跑步
  JOGGING,
  //骑行
  CYCLING,
  //计时运动
  CLOCK_BASE_EXCERCISE
}

export enum ChildSportType {
  //自由走
  FREE_WALKING,
  //目标走
  TARGET_WALKING,
  //遛狗
  DOG_WALKING,
  //自由跑
  FREE_JOGGING,
  //目标跑
  TARGET_JOGGING,
  //自由骑
  FREE_CYCLING,
  //目标骑
  TARGET_CYCLING,
  //计时运动
  TIMING_SPORT
}

export interface SportItem {
  //运动类型
  type: SportType
  //运动子类型
  childType: ChildSportType
  //开始时间
  hour: number
  //开始时间
  minute: number
  //运动距离 单位米
  distance: number
  //运动时长 单位秒
  timeLength: number
  //单次运动目标
  target?: SportItemTarget
  //运动消耗 单位 卡
  deplete: number
  //步数（跑步，步行）
  stepCount: number
  //轨迹点
  locusPoints?: mapCommon.LatLng[]
}

@ObservedV2
export class RealTimeMotionVM {
  @Trace distanceMap: Map<number, number> = new Map();
  @Trace sportType: SportType = SportType.WALKING
  @Trace motion: MotionType = MotionType.target // 目标类型
  @Trace distance: number = 0 // 距离
  @Trace distanceKM: string = '0.00' // 距离km
  @Trace heat: number = 0 // 消耗
  @Trace steps: number = 0 // 步数
  @Trace duration: number = 0 // 时长
  @Trace durationMS: string = '00:00' // 时长
  @Trace pace: string = '00' // 配速
  @Trace move: MoveState = MoveState.pauseMove
  @Trace targetType: TargetType = TargetType.DISTANCE
  @Trace parameter: number = 0
  @Trace parameterDesc: string = ''
  @Trace progressValue: string = ''
  @Trace showAll: boolean = true;
  showCard: boolean = true; // 是否显示卡片信息
  private readonly DEFAULT_WEIGHT: number = 65; // 默认体重65kg
  private readonly CALORIES_PER_STEP: number = 0.04; // 每步约消耗0.04千卡（平均值）
  private readonly avgSpeed: number = 20; // 平均速度20km/h
  private readonly metValue: number = 6.8; // 公路骑行MET值（已废弃，改用功率公式）
  private defaultSteps: number = -1; // 步数标识符
  private timer: number = -1

  constructor(sportType: SportType, targetType: TargetType, parameter: string, motion: string) {
    this.sportType = sportType
    this.targetType = targetType
    this.parameterDesc = parameter
    this.motion = motion as MotionType
    this.parameter = this.extractNumber(parameter)
  }

  // 监听步数实时计算热量
  @Monitor('move')
  moveStateMonitor() {
    if (this.move === MoveState.startMove) {
      this.startExercising()
    } else if (this.move === MoveState.pauseMove) {
      this.pauseExercising()
    } else {
      this.endExercising()
    }
  }

  secondsToMinutesSeconds(): void {
    // 确保 duration 是非负数
    const duration = Math.max(0, this.duration);

    // 计算分钟和秒
    const minutes = Math.floor(duration / 60);
    const seconds = Math.floor(duration % 60);
    // 格式化为 MM:SS
    this.durationMS = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }

  // 监听步数实时计算热量
  @Monitor('steps')
  estimateCalories() {
    // 根据运动类型选择每步消耗热量
    // 跑步：0.06千卡/步，健走和计时运动：0.04千卡/步
    const caloriesPerStep = this.sportType === SportType.JOGGING ? 0.06 : this.CALORIES_PER_STEP;

    // 基础热量计算：步数 × 每步基础消耗 × 体重系数
    // 体重系数 = 实际体重 / 标准体重(65kg)
    const weightFactor = this.DEFAULT_WEIGHT / this.DEFAULT_WEIGHT;
    const baseCalories = this.steps * caloriesPerStep;

    // 根据体重调整热量消耗
    const adjustedCalories = baseCalories * weightFactor;
    // 返回整数结果
    this.heat = Math.round(adjustedCalories);
  }

  extractNumber(input: string): number {
    const match = input.match(/^\d+(\.\d+)?/);
    return match ? Number(match[0]) : 0;
  }

  /**
   * 清理超过10秒的旧数据
   * @param currentTime 当前时间戳
   */
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

  addDistance(distance: number): void {
    this.distance += distance;
    this.metersToKm();
    const currentTime = Date.now();
    // 添加新的距离数据
    this.distanceMap.set(currentTime, distance);
  }

  metersToKm() {
    const km = this.distance / 1000;
    this.distanceKM = km.toFixed(2);
  }

  /**
   * 计算最近10秒内的总距离并转换成分每公里 (min/km)
   * @returns 分每公里值
   */
  calculatePace(): string {
    if (this.distanceMap.size === 0) {
      return '0′00′′';
    }

    // 计算总距离（米）
    let totalDistance = 0;
    for (const distance of this.distanceMap.values()) {
      totalDistance += distance;
    }

    // 计算速度（米/秒）
    const speedMps = totalDistance / 10;

    // 如果速度为0，返回默认值
    if (speedMps === 0) {
      return '0\'00\'\'';
    }

    // 计算每公里需要的时间（秒）
    const timePerKmSeconds = 1000 / speedMps;

    // 转换为分钟和秒
    const minutes = Math.floor(timePerKmSeconds / 60);
    const seconds = Math.floor(timePerKmSeconds % 60);

    // 格式化为 "分'秒''/公里" 格式
    return `${minutes}'${seconds.toString().padStart(2, '0')}''`;
  }

  /**
   * 骑行热量计算（基于功率公式）
   * 使用公式：130瓦 × 时间(小时) × 3.6 = 大卡
   * 速度：20km/h
   */
  calculateCyclingCalories() {
    // 计算实际运动时长（小时）
    // duration 是实际运动时长（秒），需要转换为小时
    const durationHours = this.duration / 3600;

    // 计算热量消耗：130瓦 × 时间(小时) × 3.6 = 大卡
    const calories = 130 * durationHours * 3.6;

    this.heat = Math.round(calories);
  }

  //  开始运动
  startExercising() {
    if (this.sportType !== SportType.CYCLING) {
      this.subscribeSteps(); // 订阅步数
    }
    this.timer = setInterval(() => {
      this.cleanupOldData(); // 清理距离map
      this.pace = this.calculatePace(); // 计算配速
      this.duration += 1; // 时长每秒＋1
      this.secondsToMinutesSeconds();
      if (this.sportType === SportType.CYCLING) {
        this.calculateCyclingCalories();
      }
      if (this.motion === MotionType.target) {
        this.verificationProgress();
      }
    }, 1000)
  }

  parameterTransition(): number {
    let value: number = 0
    switch (this.targetType) {
      case TargetType.TIME_LENGTH:
        value = this.parameter * 60
        break;
      case TargetType.DEPLETE:
        value = this.parameter
        break;
      case TargetType.DISTANCE:
        value = this.parameter * 1000
        break;
      default:
        break
    }
    return value
  }

  getChildSport(): ChildSportType {
    let value: ChildSportType = ChildSportType.FREE_WALKING
    switch (this.sportType) {
      case SportType.WALKING:
        if (this.motion === MotionType.isFreedom) {
          value = ChildSportType.FREE_WALKING
        } else if (this.motion === MotionType.target) {
          value = ChildSportType.TARGET_WALKING
        } else {
          value = ChildSportType.DOG_WALKING
        }
        break;
      case SportType.JOGGING:
        if (this.motion === MotionType.isFreedom) {
          value = ChildSportType.FREE_JOGGING
        } else {
          value = ChildSportType.TARGET_JOGGING
        }
        break;
      case SportType.CYCLING:
        if (this.motion === MotionType.isFreedom) {
          value = ChildSportType.FREE_CYCLING
        } else {
          value = ChildSportType.TARGET_CYCLING
        }
        break;
      default:
        break
    }
    return value
  }

  // 校验当前运动参数是否达标，达标结束运动
  verificationProgress() {
    let currentValue: number;
    let totalParameter: number = this.parameterTransition()
    switch (this.targetType) {
      case TargetType.DISTANCE:
        currentValue = this.distance;
        this.calculatePercentage(this.distance, totalParameter);
        break;
      case TargetType.TIME_LENGTH:
        currentValue = this.duration;
        this.calculatePercentage(this.duration, totalParameter);
        break;
      case TargetType.DEPLETE:
        currentValue = this.heat;
        this.calculatePercentage(this.heat, totalParameter);
        break;
      default:
        return; // 或者处理未知类型
    }

    if (currentValue >= totalParameter) {
      this.pauseExercising();
    }
  }

  calculatePercentage(current: number, total: number): void {
    // 处理除零情况
    if (total === 0) {
      this.progressValue = '0';
      return;
    }

    // 计算百分比并限制最大值为100
    const percentage = Math.min(100, (current / total) * 100);

    // 取整数部分
    this.progressValue = Math.floor(percentage).toString();
  }

  // 暂停运动
  pauseExercising() {
    clearInterval(this.timer) // 关掉循环
    this.move = MoveState.pauseMove
  }

  // 结束运动
  endExercising() {
    this.move = MoveState.stopMove
  }

  subscribeSteps() {
    // 订阅步数实时更新
    try {
      sensor.on(sensor.SensorId.PEDOMETER, (data: sensor.PedometerResponse) => {
        let step: number = data.steps ?? 0
        if (this.move === MoveState.pauseMove) {
          this.defaultSteps = step
        } else {
          if (this.defaultSteps === -1) {
            this.defaultSteps = step
          } else {
            this.steps += step - this.defaultSteps
            this.defaultSteps = step
          }
        }
      }, { interval: 100000000 });
    } catch (err) {
      hilog.error(0x0000, 'queryListInfo',
        `Failed to subscribeSteps. Code: ${err.code}, message: ${err.message}`);
    }
  }
}
