import { emitter } from '@kit.BasicServicesKit';
import { BaseViewModel, ResUtil, RouterMap, RouterUtils } from 'lib_common';
import { SportRecord, SportServiceApi } from 'lib_sport_api';
import { CharDataModel, DateType } from 'module_datechart';
import { Logger } from 'ui_base';
import { SportCompareModel, SportStatistics } from '../model/SportCompareModel';
import { DateUtils } from '../util/DateUtils';

@ObservedV2
export class StepCountVM extends BaseViewModel {
  @Trace dateType: DateType = DateType.DAY
  @Trace curDate: Date = new Date()
  @Trace curRecords: SportRecord[] = []
  @Trace lastRecords: SportRecord[] = []
  @Trace selectData?: CharDataModel
  @Trace curStepCharModel: CharDataModel[] = []
  @Trace curTimeLengthCharModel: CharDataModel[] = []
  @Trace curDepleteCharModel: CharDataModel[] = []
  @Trace curDistanceCharModel: CharDataModel[] = []
  @Trace sportCompareModel: SportCompareModel = new SportCompareModel()
  @Trace selectedIndex: number = 0
  private routerName: RouterMap

  constructor(routerName: RouterMap) {
    super();
    this.routerName = routerName
  }

  @Monitor('dateType','curDate')
  changeDateTypeOrDate() {
    if (this.routerName === RouterMap.STEP_DETAIL_PAGE) {
      if (this.dateType === DateType.WEEK || this.dateType === DateType.MONTH) {
        RouterUtils.popToName(RouterMap.STEP_COUNT_PAGE)
        try {
          emitter.emit('switchDateType', { data: { dateType: this.dateType } })
        } catch (error) {
          Logger.error('StepCountVM', 'emitter emit switchDateType error')
        }
        return
      }
    }
    this.querySportRecord()
  }

  async querySportRecord(date?: Date) {
    this.sportCompareModel.compareType = this.dateType
    //查询当前数据
    if (date) {
      this.curDate = date
    }
    this.curRecords = await this._querySportRecord(this.curDate)

    //当前步数图表数据
    this.setCurStepCharModel()

    //当前时长图表数据
    this.seTimeLengthCharModel()

    //当前消耗图表数据
    this.setCurDepleteCharModel()

    //当前距离图表数据
    this.setDistanceCharModel()

    this.sportCompareModel.curSportStatistics = this.handleStatistics(this.curRecords)

    //查询上周或上月数据
    if (this.dateType === DateType.WEEK || this.dateType === DateType.MONTH) {
      // 设置年月
      await this.setYearMonth()
      //上次步数图表数据
      this.setLastStepCharModel()

      //上次时长图表数据
      this.setLastTimeLengthCharModel()

      //上次消耗图表数据
      this.setLastDepleteCharModel()

      // 设置其它数据
      this.setSportCompareModelOther()
    }

    const tempIndex = this.curStepCharModel.findIndex(item => item.date.getTime() === this.curDate.getTime())
    this.selectedIndex = tempIndex < 0 ? 0 : tempIndex
  }

  //当前步数图表数据
  setCurStepCharModel() {
    if (this.dateType === DateType.WEEK || this.dateType === DateType.MONTH) {
      this.curStepCharModel = this.curRecords.map((record) =>
      new CharDataModel(record.totalStepCount, new Date(`${record.year}/${record.month}/${record.day}`),
        `${record.month}月${record.day}日`)
      )
    } else {
      this.curStepCharModel = this.curRecords[0].hourStepCount.map((count, index) =>
      new CharDataModel(count,
        new Date(`${this.curRecords[0].year}/${this.curRecords[0].month}/${this.curRecords[0].day}`),
        `${index < 10 ? '0' : ''}${index}:00`)
      )
    }
  }

  //当前时长图表数据
  seTimeLengthCharModel() {
    if (this.dateType === DateType.WEEK || this.dateType === DateType.MONTH) {
      this.curTimeLengthCharModel = this.curRecords.map((record) =>
      new CharDataModel(record.totalSportTimeLength, new Date(`${record.year}/${record.month}/${record.day}`),
        `${record.month}月${record.day}日`)
      )
    } else {
      this.curTimeLengthCharModel = this.curRecords[0].hourSportTimeLength.map((count, index) =>
      new CharDataModel(count,
        new Date(`${this.curRecords[0].year}/${this.curRecords[0].month}/${this.curRecords[0].day}`),
        `${index < 10 ? '0' : ''}${index}:00`)
      )
    }
  }

  // 当前消耗图表数据
  setCurDepleteCharModel() {
    if (this.dateType === DateType.WEEK || this.dateType === DateType.MONTH) {
      this.curDepleteCharModel = this.curRecords.map((record) =>
      new CharDataModel(record.totalDeplete, new Date(`${record.year}/${record.month}/${record.day}`),
        `${record.month}月${record.day}日`)
      )
    } else {
      this.curDepleteCharModel = this.curRecords[0].hourDeplete.map((count, index) =>
      new CharDataModel(count,
        new Date(`${this.curRecords[0].year}/${this.curRecords[0].month}/${this.curRecords[0].day}`),
        `${index < 10 ? '0' : ''}${index}:00`)
      )
    }
  }

  // 当前距离图表数据
  setDistanceCharModel() {
    if (this.dateType === DateType.WEEK || this.dateType === DateType.MONTH) {
      this.curDistanceCharModel = this.curRecords.map((record) =>
      new CharDataModel(record.totalDistance, new Date(`${record.year}/${record.month}/${record.day}`),
        `${record.month}月${record.day}日`)
      )
    } else {
      this.curDistanceCharModel = this.curRecords[0].hourDistance.map((count, index) =>
      new CharDataModel(count,
        new Date(`${this.curRecords[0].year}/${this.curRecords[0].month}/${this.curRecords[0].day}`),
        `${index < 10 ? '0' : ''}${index}:00`)
      )
    }
  }

  // 设置年月
  async setYearMonth() {
    const lastDate = new Date(this.curDate)
    if (this.dateType === DateType.WEEK) {
      lastDate.setDate(lastDate.getDate() - 7)
    } else {
      lastDate.setMonth(lastDate.getMonth() - 1)
    }
    this.lastRecords = await this._querySportRecord(lastDate)

  }

  //上次步数图表数据
  setLastStepCharModel() {
    if (this.dateType === DateType.WEEK || this.dateType === DateType.MONTH) {
      this.sportCompareModel.lastStepCharModel = this.lastRecords.map((record) =>
      new CharDataModel(record.totalStepCount, new Date(`${record.year}/${record.month}/${record.day}`),
        `${record.month}月${record.day}日`)
      )
    } else {
      this.sportCompareModel.lastStepCharModel = this.lastRecords[0].hourStepCount.map((count, index) =>
      new CharDataModel(count,
        new Date(`${this.lastRecords[0].year}/${this.lastRecords[0].month}/${this.lastRecords[0].day}`),
        `${index < 10 ? '0' : ''}${index}:00`)
      )
    }
  }

  // 上次时长图表数据
  setLastTimeLengthCharModel() {
    if (this.dateType === DateType.WEEK || this.dateType === DateType.MONTH) {
      this.sportCompareModel.lastTimeLengthCharModel = this.lastRecords.map((record) =>
      new CharDataModel(record.totalSportTimeLength, new Date(`${record.year}/${record.month}/${record.day}`),
        `${record.month}月${record.day}日`)
      )
    } else {
      this.sportCompareModel.lastTimeLengthCharModel = this.lastRecords[0].hourSportTimeLength.map((count, index) =>
      new CharDataModel(count,
        new Date(`${this.lastRecords[0].year}/${this.lastRecords[0].month}/${this.lastRecords[0].day}`),
        `${index < 10 ? '0' : ''}${index}:00`)
      )
    }
  }

  //上次消耗图表数据
  setLastDepleteCharModel() {
    if (this.dateType === DateType.WEEK || this.dateType === DateType.MONTH) {
      this.sportCompareModel.lastDepleteCharModel = this.lastRecords.map((record) =>
      new CharDataModel(record.totalDeplete, new Date(`${record.year}/${record.month}/${record.day}`),
        `${record.month}月${record.day}日`)
      )
    } else {
      this.sportCompareModel.lastDepleteCharModel = this.lastRecords[0].hourDeplete.map((count, index) =>
      new CharDataModel(count,
        new Date(`${this.lastRecords[0].year}/${this.lastRecords[0].month}/${this.lastRecords[0].day}`),
        `${index < 10 ? '0' : ''}${index}:00`)
      )
    }
  }

  // 设置sportCompareModel值
  setSportCompareModelOther() {
    this.sportCompareModel.lastSportStatistics = this.handleStatistics(this.lastRecords)

    this.sportCompareModel.stepTrendTitle = this.getStepTrendTitle()
    this.sportCompareModel.stepTrendDesc = this.getStepTrendDesc()
    this.sportCompareModel.stepCompleteTitle = this.getStepCompleteTitle()
    this.sportCompareModel.stepCompleteDesc = this.getStepCompleteDesc()
    this.sportCompareModel.sportDistanceTitle = this.getSportDistanceTitle()
    this.sportCompareModel.sportDistanceDesc = this.getSportDistanceDesc()
    this.sportCompareModel.sportTimeLengthTitle = this.getSportTimeLengthTitle()
    this.sportCompareModel.sportDepleteTitle = this.getSportDepleteTitle()
    this.sportCompareModel.curDateStr = this.getCompareDateStr(true)
    this.sportCompareModel.lastDateStr = this.getCompareDateStr(false)

    this.sportCompareModel.stepDesc = this.getStepDesc()
    this.sportCompareModel.stepDescInfo = this.getStepDescInfo()
    this.sportCompareModel.timeLengthDesc = this.getTimeLengthDesc()
    this.sportCompareModel.timeLengthDescInfo = this.getTimeLengthDescInfo()
    this.sportCompareModel.depleteDesc = this.getDepleteDesc()
    this.sportCompareModel.depleteDescInfo = this.getDepleteDescInfo()
  }

  handleStatistics(records: SportRecord[]): SportStatistics {
    const statistics = new SportStatistics()
    //总步数
    let tempStepCount = 0
    records.forEach(value => tempStepCount += value.totalStepCount)
    statistics.totalStepCount = tempStepCount
    //平均步数
    statistics.averageStepCount = Number((tempStepCount / records.length).toFixed(0))
    //总消耗
    let tempDeplete = 0
    records.forEach(value => tempDeplete += value.totalDeplete)
    statistics.totalDeplete = tempDeplete
    //总距离
    let tempDistance = 0
    records.forEach(value => tempDistance += value.totalDistance)
    statistics.totalDistance = tempDistance
    //平均距离
    statistics.averageDistance = tempDistance / records.length
    //总运动时长
    let tempSportTimeLength = 0
    records.forEach(value => tempSportTimeLength += value.totalSportTimeLength)
    statistics.totalSportTimeLength = tempSportTimeLength
    //步数达标
    let tempStepComplete = 0
    records.forEach(value => {
      if (value.totalTarget?.stepCount && value.totalStepCount >= value.totalTarget?.stepCount) {
        tempStepComplete++
      }
    })
    statistics.stepComplete = tempStepComplete
    //总次数
    let totalCount = 0
    records.forEach(value => totalCount += value.sportItemList.length)
    statistics.totalCount = totalCount
    return statistics
  }

  getRangAllDateStr(range: [Date, Date]): string[] {
    return DateUtils.getDateBetween(range[0], range[1]).map(date => DateUtils.formatDate3(date))
  }

  getStepDesc(): ResourceStr {
    return this.sportCompareModel.curSportStatistics.totalStepCount + ResUtil.getStringSync($r('app.string.step_unit'))
  }

  getStepDescInfo(): ResourceStr {
    const stepDiff = this.sportCompareModel.curSportStatistics.totalStepCount -
    this.sportCompareModel.lastSportStatistics.totalStepCount
    let stepPer: string | undefined = undefined
    try {
      stepPer = Math.abs(stepDiff / this.sportCompareModel.lastSportStatistics.totalStepCount * 100).toFixed()
    } catch (e) {
      stepPer = undefined
    } finally {
      if (stepPer === 'Infinity' || stepPer === '-Infinity' || stepPer === 'NaN') {
        stepPer = undefined
      }
    }
    return $r('app.string.step_desc', this.getCompareDateStr(true),
      this.sportCompareModel.curSportStatistics.stepComplete,
      this.getCompareDateStr(false),
      stepDiff >= 0 ? ResUtil.getStringSync($r('app.string.add')) : ResUtil.getStringSync($r('app.string.decrease')),
      Math.abs(stepDiff),
      stepPer ? ResUtil.getStringSync($r('app.string.step_desc_per'),
        [ResUtil.getStringSync(stepDiff >= 0 ? $r('app.string.up') : $r('app.string.down')), stepPer]) : ''
    )
  }

  getTimeLengthDesc(): ResourceStr {
    return DateUtils.formaterTimeLength(this.sportCompareModel.curSportStatistics.totalSportTimeLength, false)
  }

  getTimeLengthDescInfo(): ResourceStr {
    const timeLengthDiff = Math.floor((this.sportCompareModel.curSportStatistics.totalSportTimeLength -
    this.sportCompareModel.lastSportStatistics.totalSportTimeLength) / 60 * 10) / 10;
    let averageTimeLength: string | undefined = undefined
    try {
      averageTimeLength = Math.floor((this.sportCompareModel.curSportStatistics.totalSportTimeLength /
      this.sportCompareModel.curSportStatistics.totalCount) / 60 * 10) / 10 + '';
    } catch (e) {
      averageTimeLength = undefined
    } finally {
      if (averageTimeLength === 'Infinity' || averageTimeLength === '-Infinity' || averageTimeLength === 'NaN') {
        averageTimeLength = undefined
      }
    }
    return $r('app.string.time_length_desc', this.getCompareDateStr(false),
      ResUtil.getStringSync(timeLengthDiff >= 0 ? $r('app.string.add_new') : $r('app.string.decrease_new')),
      Math.abs(timeLengthDiff),
      averageTimeLength ? ResUtil.getStringSync($r('app.string.time_length_desc_ave'), [averageTimeLength]) : ''
    )
  }

  getDepleteDesc(): ResourceStr {
    return this.sportCompareModel.curSportStatistics.totalDeplete + ResUtil.getStringSync($r('app.string.deplete_unit'))
  }

  getDepleteDescInfo(): ResourceStr {
    const depleteDiff =
      this.sportCompareModel.curSportStatistics.totalDeplete - this.sportCompareModel.lastSportStatistics.totalDeplete
    return $r('app.string.chart_deplete_desc', this.getCompareDateStr(false),
      ResUtil.getStringSync(depleteDiff >= 0 ? $r('app.string.add_new') : $r('app.string.decrease_new')),
      Math.abs(depleteDiff)
    )
  }

  getStepTrendTitle(): ResourceStr {
    const diff = this.sportCompareModel.curSportStatistics.averageStepCount -
    this.sportCompareModel.lastSportStatistics.averageStepCount
    if (diff < 0) {
      return $r('app.string.average_step_decrease', Math.abs(diff))
    } else {
      return $r('app.string.average_step_add', diff)
    }
  }

  getStepTrendDesc(): ResourceStr {
    if (this.dateType === DateType.WEEK) {
      return $r('app.string.week_step_count_desc', this.sportCompareModel.curSportStatistics.totalStepCount,
        this.sportCompareModel.curSportStatistics.averageStepCount)
    }
    return $r('app.string.month_step_count_desc', this.sportCompareModel.curSportStatistics.totalStepCount,
      this.sportCompareModel.curSportStatistics.averageStepCount)
  }

  getStepCompleteTitle(): ResourceStr {
    const diff = this.sportCompareModel.curSportStatistics.stepComplete -
    this.sportCompareModel.lastSportStatistics.stepComplete
    if (diff < 0) {
      return $r('app.string.step_complete_decrease', Math.abs(diff))
    } else {
      return $r('app.string.step_complete_add', diff)
    }
  }

  getStepCompleteDesc(): ResourceStr {
    if (this.dateType === DateType.WEEK) {
      return $r('app.string.week_step_complete', this.sportCompareModel.curSportStatistics.stepComplete)
    }
    return $r('app.string.month_step_complete', this.sportCompareModel.curSportStatistics.stepComplete)
  }

  getSportDistanceTitle(): ResourceStr {
    const diff = this.sportCompareModel.curSportStatistics.totalDistance -
    this.sportCompareModel.lastSportStatistics.totalDistance
    if (diff < 0) {
      return $r('app.string.sport_distance_decrease', Math.abs(diff) / 1000)
    } else {
      return $r('app.string.sport_distance_add', diff / 1000)
    }
  }

  getSportDistanceDesc(): ResourceStr {
    if (this.dateType === DateType.WEEK) {
      return $r('app.string.week_sport_distance', this.sportCompareModel.curSportStatistics.totalDistance / 1000,
        this.sportCompareModel.curSportStatistics.averageDistance / 1000)
    }
    return $r('app.string.month_sport_distance', this.sportCompareModel.curSportStatistics.totalDistance / 1000,
      this.sportCompareModel.curSportStatistics.averageDistance / 1000)
  }

  getSportTimeLengthTitle(): ResourceStr {
    const diff = this.sportCompareModel.curSportStatistics.totalSportTimeLength -
    this.sportCompareModel.lastSportStatistics.totalSportTimeLength
    if (diff < 0) {
      return $r('app.string.sport_time_length_decrease', Math.abs(diff))
    } else {
      return $r('app.string.sport_time_length_add', diff)
    }
  }

  getSportDepleteTitle(): ResourceStr {
    const diff = this.sportCompareModel.curSportStatistics.totalDeplete -
    this.sportCompareModel.lastSportStatistics.totalDeplete
    if (diff < 0) {
      return $r('app.string.sport_deplete_decrease', Math.abs(diff))
    } else {
      return $r('app.string.sport_deplete_add', diff)
    }
  }

  getCompareDateStr(isCur: boolean): ResourceStr {
    if (this.dateType === DateType.WEEK) {
      return isCur ? $r('app.string.cur_week') : $r('app.string.last_week')
    } else if (this.dateType === DateType.MONTH) {
      return isCur ? $r('app.string.cur_month') : $r('app.string.last_month')
    }
    return isCur ? $r('app.string.cur_day') : $r('app.string.last_day')
  }

  private _querySportRecord(curDate: Date): Promise<SportRecord[]> {
    let dateTimes: string[] = []
    if (this.dateType === DateType.WEEK) {
      const weekRange = DateUtils.getWeekRange2(curDate)
      dateTimes = this.getRangAllDateStr(weekRange)
    } else if (this.dateType === DateType.MONTH) {
      const weekRange = DateUtils.getMonthRange(curDate)
      dateTimes = this.getRangAllDateStr(weekRange)
    } else {
      dateTimes = [DateUtils.formatDate3(curDate)]
    }
    return SportServiceApi.querySportRecord(dateTimes)
  }
}