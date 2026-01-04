import { MonthItemModel, SportItem, SportRecord } from '../database/SportRecord';
import { MockSportRecord } from './mockdata/MockSportRecord';
import { PreferenceUtil } from '../utils/PreferenceUtil';
import { SevenDaysTotalModel, ThreeRingModel } from '../observedmodels/CommentModel';
import { Utils } from '../utils/Utils';

class SportService {
  // 当天实时运动数据
  distance: number = 0 // 距离
  heat: number = 0 // 消耗
  steps: number = 0 // 步数
  currentDate: Date = new Date()

  /**
   * 每日运动目标设置
   *
   * @param distance
   * @param steps
   * @param caloric
   * @param timeLength
   */
  dailyRunningSetting(distance: number, steps: number, caloric: number, timeLength: number = 30) {
    let data = AppStorage.get(PreferenceUtil.ALL_RECORD_DATA_KEY) as SportRecord[]
    let result = data[0]
    result.totalTarget = {
      stepCount: steps,
      distance: distance * 1000,
      deplete: caloric,
      timeLength: timeLength
    }
    this.todaySportRecord(result)
  }

  /**
   * 获取运动记录
   * 按天获取
   *
   * @param dateTimes  某天的记录，格式：'2025/9/25'
   * @returns
   */
  querySportRecord(dateTimes: string[]): Promise<SportRecord[]> {
    return new Promise(resolve => {
      resolve(
        dateTimes.map(time => {
          let data = AppStorage.get(PreferenceUtil.ALL_RECORD_DATA_KEY) as SportRecord[]
          const find = data.find(record => `${record.year}/${record.month}/${record.day}` === time)
          if (find) {
            // 今日记录获取实时数据
            if (`${this.currentDate.getFullYear()}/${this.currentDate.getMonth() + 1}/${this.currentDate.getDate()}` ===
              time) {
              find.totalStepCount = this.steps
              find.totalDistance = this.distance * 1000
              find.totalDeplete = this.heat
            }
            return find
          }
          const times = time.split('/')
          return MockSportRecord.genEmptyRecord(Number(times[0]), Number(times[1]), Number(times[2])) as SportRecord
        })
      )
    })
  }

  saveTodaySportItem(point: SportItem) {
    if (!point) {
      return
    }
    let data = AppStorage.get(PreferenceUtil.ALL_RECORD_DATA_KEY) as SportRecord[]
    data[0].sportItemList.push(point)
    //处理运动时长
    let tempLength = point.timeLength
    let diff = 3600 - (point.minute * 60)
    if (diff >= tempLength) {
      data[0].hourSportTimeLength[point.hour] =
        data[0].hourSportTimeLength[point.hour] + Number((tempLength / 60).toFixed(2))
      data[0].totalSportTimeLength = data[0].totalSportTimeLength + Number((tempLength / 60).toFixed(2))
    } else {
      tempLength = tempLength - diff
      let index = 1
      for (index = 1; tempLength - 3600 >= 0; index++) {
        tempLength = tempLength - 3600
        data[0].hourSportTimeLength[point.hour + index] = data[0].hourSportTimeLength[point.hour + index] + 60
        data[0].totalSportTimeLength = data[0].totalSportTimeLength + 60
      }
      data[0].totalSportTimeLength = data[0].totalSportTimeLength + Number((tempLength / 60).toFixed(2))
      data[0].hourSportTimeLength[point.hour + index + 1] =
        data[0].hourSportTimeLength[point.hour + index + 1] + Number((tempLength / 60).toFixed(2))
    }
    AppStorage.setOrCreate(PreferenceUtil.ALL_RECORD_DATA_KEY, data)
    this.todaySportRecord(data[0])
  }

  createSportItem(month: ESObject) {
    let monthTemporary: MonthItemModel = month as MonthItemModel
    let item: SportItem = {
      type: monthTemporary.type,
      childType: monthTemporary.childType,
      hour: monthTemporary.hour,
      minute: monthTemporary.minute,
      distance: monthTemporary.distance,
      timeLength: monthTemporary.timeLength,
      deplete: monthTemporary.deplete,
      stepCount: monthTemporary.stepCount,
      locusPoints: monthTemporary.locusPoints,
      target: monthTemporary.target
    }
    let data = AppStorage.get(PreferenceUtil.ALL_RECORD_DATA_KEY) as SportRecord[]
    data[0].sportItemList.push(item)
    this.todaySportRecord(data[0])
  }

  updateSportRecord(deleteItem: MonthItemModel[]) {
    let sportRecordData = AppStorage.get(PreferenceUtil.ALL_RECORD_DATA_KEY) as SportRecord[]
    AppStorage.setOrCreate(PreferenceUtil.ALL_RECORD_DATA_KEY,
      this.clearMatchedLocusPoints(sportRecordData, deleteItem))
  }

  clearMatchedLocusPoints(
    originalArray: SportRecord[],
    parameter: MonthItemModel[]
  ): SportRecord[] {

    // 遍历原始数组中的每条记录
    originalArray.forEach(record => {
      // 遍历当前记录中的所有运动项目
      record.sportItemList.forEach(sportItem => {
        // 在parameter中查找匹配的项目
        const matchedItem = parameter.find(paramItem => {
          // 比较所有关键字段
          const basicMatch =
            sportItem.type === paramItem.type &&
              sportItem.childType === paramItem.childType &&
              sportItem.hour === paramItem.hour &&
              sportItem.minute === paramItem.minute &&
              sportItem.distance === paramItem.distance &&
              sportItem.timeLength === paramItem.timeLength &&
              sportItem.deplete === paramItem.deplete &&
              sportItem.stepCount === paramItem.stepCount &&
              record.year === paramItem.year &&
              record.month === paramItem.month &&
              record.day === paramItem.day;

          // 比较目标对象（处理undefined情况）
          const targetMatch =
            (!sportItem.target && !paramItem.target) ||
              (sportItem.target && paramItem.target &&
                JSON.stringify(sportItem.target) === JSON.stringify(paramItem.target));

          return basicMatch && targetMatch;
        });

        // 如果找到匹配项，清空轨迹点
        if (matchedItem) {
          sportItem.locusPoints = undefined;
        }
      });
    });

    return originalArray;
  }

  saveHourSportRecord(hour: number, addStep: number, addDistance: number, addDeplete: number) {
    let data = AppStorage.get(PreferenceUtil.ALL_RECORD_DATA_KEY) as SportRecord[]
    data[0].hourStepCount[hour] = data[0].hourStepCount[hour] + addStep
    data[0].hourDistance[hour] = data[0].hourDistance[hour] + addDistance
    data[0].hourDeplete[hour] = data[0].hourDeplete[hour] + addDeplete
    AppStorage.setOrCreate(PreferenceUtil.ALL_RECORD_DATA_KEY, data)
  }

  /**
   * 默认添加/修改今天的运动记录
   *
   * @param record
   */
  todaySportRecord(record: SportRecord) {
    let date = new Date();
    record.year = date.getFullYear()
    record.month = date.getMonth() + 1
    record.day = date.getDate()
    let data = AppStorage.get(PreferenceUtil.ALL_RECORD_DATA_KEY) as SportRecord[]
    if (data[0].year + data[0].month + data[0].day === record.year + record.month + record.day) {
      // 存储当前实时运动数据
      record.totalDistance = data[0].totalDistance + this.distance * 1000
      record.totalStepCount = data[0].totalStepCount + this.steps
      record.totalDeplete = data[0].totalDeplete + this.heat
      data[0] = record
    } else {
      data.unshift(record)
    }
    AppStorage.setOrCreate(PreferenceUtil.ALL_RECORD_DATA_KEY, data)
  }

  // 初始化数据
  initData() {
    if (AppStorage.get(PreferenceUtil.RESTART_APP_SIGN)) {
      return
    }
    AppStorage.setOrCreate(PreferenceUtil.RESTART_APP_SIGN, true)
    // 模拟数据
    let sportRecord: SportRecord[] = MockSportRecord.records
    sportRecord.forEach((record, index) => {
      if (index < 6) {
        let newDate = new Date();
        newDate.setDate(newDate.getDate() - (index + 1));
        record.year = newDate.getFullYear();
        record.month = newDate.getMonth() + 1;
        record.day = newDate.getDate();
      }
    })

    // 初始化今天数据
    let todayRecord = MockSportRecord.genEmptyRecord(this.currentDate.getFullYear(), this.currentDate.getMonth() + 1,
      this.currentDate.getDate()) as SportRecord
    sportRecord.unshift(todayRecord)
    AppStorage.setOrCreate(PreferenceUtil.ALL_RECORD_DATA_KEY, sportRecord)
    // 初始化默认当日目标
    this.dailyRunningSetting(1, 1000, 50)
  }

  /**
   * 根据日期获取三环记录
   *
   * 模板模拟数据临时查询方式
   * @param date
   * @returns
   */
  queryThreeRingRecord(date: Date): ThreeRingModel {
    let data = AppStorage.get(PreferenceUtil.ALL_RECORD_DATA_KEY) as SportRecord[]
    let result = data.find(record => `${record.year}/${record.month}/${record.day}` ===
      `${date.getFullYear()}/${date.getMonth() + 1}/${date.getDate()}`)
    let threeRingModel: ThreeRingModel = new ThreeRingModel()
    if (result) {
      // 今日记录获取实时数据
      if (this.currentDate.getFullYear() + this.currentDate.getMonth() + 1 + this.currentDate.getDate() ===
        result.year + result.month + result.day) {
        result.totalStepCount = this.steps
        result.totalDistance = this.distance * 1000
        result.totalDeplete = this.heat
      }
      threeRingModel.stepData = [result.totalStepCount, result.totalTarget?.stepCount || 1000]
      threeRingModel.distanceData = [result.totalDistance, (result.totalTarget?.distance || 1000) / 1000]
      threeRingModel.caloriesData = [result.totalDeplete, result.totalTarget?.deplete || 1000]
    }
    return threeRingModel
  }

  /**
   * 获取所有运动数据
   *
   * @returns
   */
  getAllData(): SportRecord[] {
    return AppStorage.get(PreferenceUtil.ALL_RECORD_DATA_KEY) as SportRecord[]
  }

  /**
   * 连续打卡天数
   */
  continuousCheckIn(): number {
    let data = this.getAllData()
    let result = 1
    data.some((record, index) => {
      let date = Utils.previousDate(-index)
      if ((record.year + '/' + record.month + '/' + record.day) !== date) {
        result = index
        return true
      }
      return false
    })
    return result
  }

  /**
   * 近7天总数据
   *
   * @param six true 6天，false 7天
   */
  sevenDayTotalData(six: boolean = false): SevenDaysTotalModel {
    let result: SevenDaysTotalModel = new SevenDaysTotalModel()
    this.getAllData().forEach((record, index) => {
      if (index < 7) {
        if (six && index === 0) {
        } else {
          result.stepData[0] += record.totalStepCount
          result.stepData[1] += record.totalTarget?.stepCount || 1000
          result.distanceData[0] += record.totalDistance
          result.distanceData[1] += (record.totalTarget?.distance || 2000) / 1000
          result.caloriesData[0] += record.totalDeplete
          result.caloriesData[1] += record.totalTarget?.deplete || 50
        }
      }
    })
    return result
  }
}

const instance = new SportService();

export { instance as SportServiceApi };