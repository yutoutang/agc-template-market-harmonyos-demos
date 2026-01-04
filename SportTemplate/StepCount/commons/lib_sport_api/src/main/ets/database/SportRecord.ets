import { mapCommon } from '@kit.MapKit'

/**
 * 每天运动记录
 */
export interface SportRecord {
  //年
  year: number
  //月
  month: number
  //日
  day: number
  //当日目标
  totalTarget: SportTarget | null
  //当日总步数
  totalStepCount: number
  //当日总距离 单位 米
  totalDistance: number
  //当日总消耗
  totalDeplete: number
  //当日总锻炼时长
  totalSportTimeLength: number
  //每小时步数
  hourStepCount: number[]
  //每小时距离
  hourDistance: number[]
  //每小时消耗
  hourDeplete: number[]
  //每小时锻炼时长
  hourSportTimeLength: number[]
  //当日所有运动记录
  sportItemList: SportItem[]
}

export enum TargetTypeStr {
  //距离
  DISTANCE = '距离',
  //消耗
  DEPLETE = '热量',
  //时长
  TIME_LENGTH = '时长',
  //配速
  PACE = '配速'
}

export class MonthItemModel implements SportItem {
  month: number
  day: number
  type: SportType
  childType: ChildSportType
  hour: number
  minute: number
  distance: number
  timeLength: number
  target: SportItemTarget | undefined
  deplete: number
  stepCount: number
  locusPoints?: mapCommon.LatLng[]
  year: number

  constructor(month: number, day: number, type: SportType, childType: ChildSportType, hour: number, minute: number,
    distance: number,
    timeLength: number, target: SportItemTarget | undefined, deplete: number, stepCount: number,
    locusPoints?: mapCommon.LatLng[], year?: number) {
    this.month = month
    this.day = day
    this.type = type
    this.childType = childType
    this.hour = hour
    this.minute = minute
    this.distance = distance
    this.timeLength = timeLength
    this.target = target
    this.deplete = deplete
    this.stepCount = stepCount
    this.locusPoints = locusPoints
    this.year = year ?? new Date().getFullYear()
  }
}

export interface SportTarget {
  //目标步数
  stepCount: number
  //目标距离
  distance: number
  //目标消耗
  deplete: number
  //目标时长
  timeLength: number
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

export enum TargetType {
  //距离
  DISTANCE,
  //消耗
  DEPLETE,
  //时长
  TIME_LENGTH,
  //配速
  PACE
}