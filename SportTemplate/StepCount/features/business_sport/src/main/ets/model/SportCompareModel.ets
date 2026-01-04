import { CharDataModel, DateType } from 'module_datechart';

@ObservedV2
export class SportStatistics {
  @Trace
  totalStepCount: number = 0
  @Trace
  averageStepCount: number = 0
  @Trace
  totalDeplete: number = 0
  @Trace
  totalDistance: number = 0
  @Trace
  averageDistance: number = 0
  @Trace
  totalSportTimeLength: number = 0
  @Trace
  stepComplete: number = 0
  @Trace
  totalCount: number = 0
}

@ObservedV2
export class SportCompareModel {
  @Trace
  compareType: DateType = DateType.WEEK
  @Trace lastStepCharModel: CharDataModel[] = []
  @Trace lastTimeLengthCharModel: CharDataModel[] = []
  @Trace lastDepleteCharModel: CharDataModel[] = []
  @Trace
  lastSportRecord = new SportStatistics()
  @Trace
  curSportStatistics = new SportStatistics()
  @Trace
  lastSportStatistics = new SportStatistics()
  @Trace
  stepTrendTitle: ResourceStr = ''
  @Trace
  stepTrendDesc: ResourceStr = ''
  @Trace
  stepCompleteTitle: ResourceStr = ''
  @Trace
  stepCompleteDesc: ResourceStr = ''
  @Trace
  sportDistanceTitle: ResourceStr = ''
  @Trace
  sportDistanceDesc: ResourceStr = ''
  @Trace
  sportTimeLengthTitle: ResourceStr = ''
  @Trace
  sportDepleteTitle: ResourceStr = ''
  @Trace
  curDateStr: ResourceStr = ''
  @Trace
  lastDateStr: ResourceStr = ''
  @Trace
  stepDesc: ResourceStr = ''
  @Trace
  stepDescInfo: ResourceStr = ''
  @Trace
  timeLengthDesc: ResourceStr = ''
  @Trace
  timeLengthDescInfo: ResourceStr = ''
  @Trace
  depleteDesc: ResourceStr = ''
  @Trace
  depleteDescInfo: ResourceStr = ''
}