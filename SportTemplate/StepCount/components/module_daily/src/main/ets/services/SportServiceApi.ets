import { SportRecord } from '../models/SportRecord';
import { ThreeRingModel } from '../models/ThreeRingModel';
import { PreferenceUtil } from '../utils/PreferenceUtil';

class SportService {
  // 当天实时运动数据
  distance: number = 0 // 距离
  heat: number = 0 // 消耗
  steps: number = 0 // 步数
  currentDate: Date = new Date()

  /**
   * 查询指定日期的三环数据
   *
   * @param date
   */
  queryThreeRingRecord(date: Date): ThreeRingModel {
    let data = AppStorage.get(PreferenceUtil.ALL_RECORD_DATA_KEY) as SportRecord[]
    if (data) {
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
    } else {
      return new ThreeRingModel()
    }
  }
}

export const sportServiceApi = new SportService();


