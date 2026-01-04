import { BaseViewModel } from 'lib_common';
import { SportItem, SportRecord, SportServiceApi, SportType } from 'lib_sport_api';
import { MonthItemModel, MonthOverviewModel, YearOverviewModel } from '../model/SportOverviewModel';
import { DateUtils } from '../util/DateUtils';

@ObservedV2
export class AllSportRecordsVM extends BaseViewModel {
  @Trace
  curSportType: SportType = SportType.ALL
  @Trace
  year: number = new Date().getFullYear()
  @Trace
  overviewModel: YearOverviewModel = new YearOverviewModel()
  @Trace
  motionDataMap: Map<number, MonthItemModel[]> = new Map()
  @Trace
  currentType: MonthItemModel[] = []
  @Trace
  totalTypeDistance: number[] = []
  @Trace continuousDays: number = 0

  @Monitor('year','curSportType')
  async queryYearOverview() {
    const dateTimes = this.getRangAllDateStr([new Date(`${this.year}/1/1`),
      this.year === new Date().getFullYear() ? new Date() : new Date(`${this.year}/12/31`)])
    const yearRecord = await SportServiceApi.querySportRecord(dateTimes)
    yearRecord.reverse()

    //归类数据
    this.overviewModel = new YearOverviewModel()
    this.overviewModel.year = this.year
    for (let index = this.year === new Date().getFullYear() ? new Date().getMonth() + 1 : 12; index >= 1; index--) {
      this.overviewModel.monthOverview.push(this.handleMonthDate(index,
        yearRecord.filter(record => record.month === index), this.curSportType))
    }
    let tempTimeLength = 0
    let tempCount = 0
    let tempDeplete = 0
    this.overviewModel.monthOverview.forEach(month => {
      tempTimeLength += month.timeLength
      tempCount += month.count
      tempDeplete += month.deplete
    })
    this.overviewModel.timeLength = tempTimeLength
    this.overviewModel.count = tempCount
    this.overviewModel.deplete = tempDeplete
  }

  async queryAllExercise() {
    const dateTimes = this.getRangAllDateStr([new Date('2024/5/1'), new Date()])
    const yearRecord = await SportServiceApi.querySportRecord(dateTimes)
    yearRecord.reverse()
    this.motionDataMap = new Map()
    const today = new Date()
    const todayKey = `${today.getFullYear()}-${today.getMonth() + 1}-${today.getDate()}`
    // 创建日期集合用于快速查找
    const dateSet = new Set<string>()
    yearRecord.forEach((recordItem: SportRecord) => {
      if (recordItem.sportItemList.length !== 0) {
        recordItem.sportItemList.forEach((item: SportItem) => {
          let single =
            new MonthItemModel(recordItem.month, recordItem.day, item.type, item.childType, item.hour, item.minute,
              item.distance, item.timeLength, item.target, item.deplete, item.stepCount, item.locusPoints,
              recordItem.year)

          const targetType = item.type ?? 0;
          if (this.motionDataMap.has(targetType)) {
            this.motionDataMap.get(targetType)?.push(single)
          } else {
            this.motionDataMap.set(targetType, [single]);
          }
        })
      }
      if (recordItem.sportItemList.length !== 0) {
        dateSet.add(`${recordItem.year}-${recordItem.month}-${recordItem.day}`)
      }
    })

    // 检查今天是否有数据
    const hasTodayData = dateSet.has(todayKey)

    // 从昨天开始计算连续天数
    let continuousDays = 0
    let checkDate = new Date(today)

    for (let i = 1; i <= 365; i++) { // 最多检查一年
      checkDate.setDate(checkDate.getDate() - 1) // 往前一天
      const checkKey = `${checkDate.getFullYear()}-${checkDate.getMonth() + 1}-${checkDate.getDate()}`

      if (dateSet.has(checkKey)) {
        continuousDays++
      } else {
        break // 遇到没有数据的天就停止
      }
    }
    if (hasTodayData) {
      continuousDays++
    }
    this.continuousDays = continuousDays
    this.currentType = (this.motionDataMap.get(1) ?? []).slice(0, 5)

    // 初始化totalTypeDistance数组，确保索引与SportType枚举值对应
    this.totalTypeDistance = [0, 0, 0, 0, 0] // 对应ALL, WALKING, JOGGING, CYCLING, CLOCK_BASE_EXCERCISE

    this.motionDataMap.forEach((monthItems: MonthItemModel[], monthKey: number) => {
      // 累加当前月份所有项目的 distance
      const totalDistance = monthItems.reduce((sum, item) => {
        return sum + (item.distance || 0);
      }, 0);

      // 将结果添加到对应索引位置
      this.totalTypeDistance[monthKey] = totalDistance
    });

  }

  /**
   * 统计每月数据
   * @param month
   * @param records
   * @returns
   */
  handleMonthDate(month: number, records: SportRecord[], type: SportType = SportType.ALL): MonthOverviewModel {
    const monthOverviewModel = new MonthOverviewModel()
    monthOverviewModel.month = month

    let tempWalkingDistance = 0
    let tempJoggingDistance = 0
    let tempCyclingDistance = 0
    let tempTimeLength = 0
    let tempCount = 0
    let tempDeplete = 0
    records.forEach(record => record.sportItemList.forEach(item => {

      if (item.type === type || type === SportType.ALL) {
        if (item.type === SportType.WALKING) {
          tempWalkingDistance += item.distance
        } else if (item.type === SportType.JOGGING) {
          tempJoggingDistance += item.distance
        } else if (item.type === SportType.CYCLING) {
          tempCyclingDistance += item.distance
        }

        tempTimeLength += item.timeLength
        tempCount++
        tempDeplete += item.deplete
      }

      monthOverviewModel.itemList.push(new MonthItemModel(month, record.day, item.type, item.childType, item.hour,
        item.minute,
        item.distance, item.timeLength, item.target, item.deplete, item.stepCount, item.locusPoints))
    }))
    monthOverviewModel.walkingDistance = tempWalkingDistance
    monthOverviewModel.joggingDistance = tempJoggingDistance
    monthOverviewModel.cyclingDistance = tempCyclingDistance
    monthOverviewModel.timeLength = tempTimeLength
    monthOverviewModel.count = tempCount
    monthOverviewModel.deplete = tempDeplete
    return monthOverviewModel
  }

  getRangAllDateStr(range: [Date, Date]): string[] {
    return DateUtils.getDateBetween(range[0], range[1]).map(date => DateUtils.formatDate3(date))
  }
}