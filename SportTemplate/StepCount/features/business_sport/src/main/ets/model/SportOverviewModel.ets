import { mapCommon } from '@kit.MapKit'
import { ChildSportType, SportItem, SportItemTarget, SportType, TargetType } from 'lib_sport_api'
import { DateUtils } from '../util/DateUtils'

@ObservedV2
export class YearOverviewModel {
  @Trace year: number = 0
  //单位 秒
  @Trace timeLength = 0
  @Trace count = 0
  @Trace deplete = 0
  @Trace monthOverview: MonthOverviewModel[] = []
}

@ObservedV2
export class MonthOverviewModel {
  @Trace month: number = 0
  //单位 秒
  @Trace timeLength = 0
  @Trace count = 0
  @Trace deplete = 0
  @Trace walkingDistance = 0
  @Trace joggingDistance = 0
  @Trace cyclingDistance = 0
  @Trace itemList: MonthItemModel[] = []
  @Trace expanded: boolean = false
}

@ObservedV2
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

  static getPace(model: MonthItemModel): number {
    return model.timeLength / (model.distance / 1000)
  }

  static getPaceStr(model?: MonthItemModel): string {
    let paceStr = '--′--″'
    if (model) {
      paceStr = DateUtils.formaterTimeLength2(MonthItemModel.getPace(model))
    }
    return paceStr
  }

  /**
   * 目标是否达成
   * @param model
   * @returns
   */
  static isTargetComplete(model: MonthItemModel): boolean | undefined {
    //有目标的运动类型
    if ((model.childType === ChildSportType.TARGET_WALKING || model.childType === ChildSportType.TARGET_JOGGING ||
      model.childType === ChildSportType.TARGET_CYCLING) && model.target) {
      if (model.target.targetType === TargetType.DISTANCE) {
        return model.distance >= model.target.value
      } else if (model.target.targetType === TargetType.DEPLETE) {
        return model.deplete >= model.target.value
      } else if (model.target.targetType === TargetType.TIME_LENGTH) {
        return model.timeLength >= model.target.value
      } else if (model.target.targetType === TargetType.PACE) {
        return MonthItemModel.getPace(model) <= model.target.value
      }
    }
    return undefined
  }

  static getChildSportTypeStr(sportType: ChildSportType): ResourceStr | undefined {
    if (sportType === ChildSportType.FREE_WALKING) {
      return $r('app.string.free_walking')
    } else if (sportType === ChildSportType.TARGET_WALKING) {
      return $r('app.string.target_walking')
    } else if (sportType === ChildSportType.DOG_WALKING) {
      return $r('app.string.dog_walking')
    } else if (sportType === ChildSportType.TARGET_JOGGING) {
      return $r('app.string.target_jogging')
    } else if (sportType === ChildSportType.FREE_JOGGING) {
      return $r('app.string.free_jogging')
    } else if (sportType === ChildSportType.FREE_CYCLING) {
      return $r('app.string.free_cycling')
    } else if (sportType === ChildSportType.TARGET_CYCLING) {
      return $r('app.string.target_cycling')
    } else if (sportType === ChildSportType.TIMING_SPORT) {
      return $r('app.string.timing_sport')
    } else {
      return undefined
    }
  }

  static getChildSportTypeStrOverall(sportType: ChildSportType): ResourceStr | undefined {
    if (sportType === ChildSportType.FREE_WALKING || sportType === ChildSportType.TARGET_WALKING ||
      sportType === ChildSportType.DOG_WALKING) {
      return $r('app.string.target_walk')
    } else if (sportType === ChildSportType.TARGET_JOGGING || sportType === ChildSportType.FREE_JOGGING) {
      return $r('app.string.target_running')
    } else if (sportType === ChildSportType.FREE_CYCLING || sportType === ChildSportType.TARGET_CYCLING) {
      return $r('app.string.target_cyc')
    } else {
      return undefined
    }
  }

  static getTargetProcessDesc(model: MonthItemModel): ResourceStr {
    if (model.target) {
      if (model.target.targetType === TargetType.DISTANCE) {
        return MonthItemModel.isTargetComplete(model) ?
          $r('app.string.distance_target_complete', (model.target.value / 1000).toFixed(1)) :
          $r('app.string.distance_target_not_complete', (model.target.value / 1000).toFixed(1))
      } else if (model.target.targetType === TargetType.DEPLETE) {
        return MonthItemModel.isTargetComplete(model) ?
          $r('app.string.deplete_target_complete', model.target.value) :
          $r('app.string.deplete_target_not_complete', model.target.value)
      } else if (model.target.targetType === TargetType.TIME_LENGTH) {
        return MonthItemModel.isTargetComplete(model) ?
          $r('app.string.time_length_target_complete', model.target.value / 60) :
          $r('app.string.time_length_target_not_complete', model.target.value / 60)
      } else if (model.target.targetType === TargetType.PACE) {
        return MonthItemModel.isTargetComplete(model) ?
          $r('app.string.pace_target_complete', DateUtils.formaterTimeLength2(model.target.value)) :
          $r('app.string.pace_target_not_complete', DateUtils.formaterTimeLength2(model.target.value))
      }
    }
    return ''
  }
}