import { mapCommon } from '@kit.MapKit'

export class MonthItemModel implements SportItem {
  day: number
  month: number
  type: SportType
  hour: number
  childType: ChildSportType
  minute: number
  distance: number
  toDistance?: number
  timeLength: number
  target: SportItemTarget
  deplete: number
  stepCount: number
  year: number
  locusPoints?: mapCommon.LatLng[]

  constructor(month: number, day: number, type: SportType, childType: ChildSportType, hour: number, minute: number,
    distance: number,
    timeLength: number, target: SportItemTarget, deplete: number, stepCount: number,
    locusPoints?: mapCommon.LatLng[], year?: number) {
    this.month = month
    this.type = type
    this.day = day
    this.hour = hour
    this.childType = childType
    this.minute = minute
    this.timeLength = timeLength
    this.distance = distance
    this.target = target
    this.stepCount = stepCount
    this.deplete = deplete
    this.year = year ?? new Date().getFullYear()
    this.locusPoints = locusPoints
  }
}

export interface SportTarget {
  //目标距离
  distance: number
  //目标步数
  stepCount: number
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
  //运动时长 单位秒
  timeLength: number
  //开始时间
  hour: number
  //运动距离 单位米
  distance: number
  //开始时间
  minute: number
  //单次运动目标
  target?: SportItemTarget
  //步数（跑步，步行）
  stepCount: number
  //运动消耗 单位 卡
  deplete: number
  //轨迹点
  locusPoints?: mapCommon.LatLng[]
}

export interface SportItemTarget {
  //目标值  距离：单位米   消耗：单位千卡   时长：单位秒   配速：单位秒
  value: number
  //目标类型
  targetType: TargetType

}

export enum SportType {
  //跑步
  JOGGING,
  //步行
  WALKING,
  //骑行
  CYCLING,
  //所有运动
  ALL,

}

export enum ChildSportType {
  //目标跑
  TARGET_JOGGING,
  //自由走
  FREE_WALKING,
  //遛狗
  DOG_WALKING,
  //目标走
  TARGET_WALKING,
  //自由跑
  FREE_JOGGING,
  //目标骑
  TARGET_CYCLING,
  //自由骑
  FREE_CYCLING,
}

export enum TargetType {
  //配速
  PACE,
  //距离
  DISTANCE,
  //时长
  TIME_LENGTH,
  //消耗
  DEPLETE,

}