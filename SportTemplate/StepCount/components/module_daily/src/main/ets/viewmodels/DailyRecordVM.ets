import { sportServiceApi } from '../services/SportServiceApi';
import { WeekDateModel, WeekModel } from '../model/WeekDateModel';
import { DateUtils } from '../utils/DateUtils';

@ObservedV2
export class DailyRecordVM {
  @Trace swiperData: number[] = []
  @Trace weekDateModel: WeekDateModel[] = []
  @Trace weekModel: WeekModel [] = []
  @Trace swiperIndex: number = 1
  @Trace dateIndex: number = 0 // 当前选中的周索引
  @Trace weekDateModelItem: WeekDateModel = new WeekDateModel()
  @Trace currentDate: Date = new Date()

  /**
   * 初始化和日历日期选择
   *
   * @param date
   */
  initDataList(date: Date) {
    this.weekModel = []
    this.swiperIndex = 1
    this.weekModel.push(new WeekModel(this.switchDate(date, 1)))
    this.weekModel.push(new WeekModel(this.switchDate(date, 0)))
    this.weekModel.push(new WeekModel(this.switchDate(date, 2)))
  }

  /**
   * 周面板数据切换调用
   */
  swiperChange() {
    if (this.swiperIndex === 0) {
      let date = this.weekModel[0].weekDateModel[this.dateIndex].date
      this.currentDate = date
      this.weekModel.unshift(new WeekModel(this.switchDate(date, 1)))
      this.swiperIndex = 1
    } else if (this.weekModel.length - 1 === this.swiperIndex) {
      let date = this.weekModel[this.weekModel.length - 1].weekDateModel[this.dateIndex].date
      this.currentDate = date
      this.weekModel.push(new WeekModel(this.switchDate(date, 2)))
    } else {
      this.currentDate = this.weekModel[this.swiperIndex].weekDateModel.find(weekDateModel => {
        return weekDateModel.selected
      })!.date
    }
  }

  /**
   * 查询指定日期的运行数据
   *
   * @param date
   */
  queryDateRunningData(date: Date) {
    let dateRunningData = new WeekDateModel()
    let data = sportServiceApi.queryThreeRingRecord(date)
    dateRunningData.stepData = data.stepData;
    dateRunningData.distanceData = data.distanceData;
    dateRunningData.caloriesData = data.caloriesData;
    return dateRunningData
  }

  /**
   * 周面板选择日期
   *
   * @param date
   */
  selectDate(date: Date, swiperIndex: number, itemIndex: number, weekModelData: WeekModel []) {
    this.dateIndex = itemIndex
    this.currentDate = date
    weekModelData.forEach((weekModel, sIndex) => {
      weekModel.weekDateModel.forEach((weekDateModel, index) => {
        if (itemIndex === index) {
          weekDateModel.selected = true
          if (sIndex === swiperIndex) {
            this.weekDateModelItem = weekDateModel
          }
        } else {
          weekDateModel.selected = false
        }
      })
    })
  }

  /**
   * 周面板数据切换
   * @param date 日期
   * @param type 0：当天所在周数据 1-前一周数据  2-后一周数据
   */
  private switchDate(date: Date, type: number) {
    this.dateIndex = date.getDay()
    let weekDateModelList: WeekDateModel[] = []
    for (let i = 0; i < 7; i++) {
      let weekDateModel = new WeekDateModel()
      let index: number = i - this.dateIndex
      if (type === 1) {
        index = i - 7 - this.dateIndex
      }
      if (type === 2) {
        index = i + 7 - this.dateIndex
      }
      let newDate = new Date(date);
      newDate.setDate(newDate.getDate() + index);
      weekDateModel.date = newDate
      weekDateModel.selected = weekDateModel.date.getDay() === this.dateIndex
      weekDateModel.week = DateUtils.getWeek(weekDateModel.date)
      weekDateModel.day = DateUtils.getDayWithZero(weekDateModel.date)
      let data = this.queryDateRunningData(weekDateModel.date)
      weekDateModel.stepData = data.stepData
      weekDateModel.distanceData = data.distanceData
      weekDateModel.caloriesData = data.caloriesData
      if (DateUtils.isSameDay(weekDateModel.date, this.currentDate) && weekDateModel.date.getDay() === this.dateIndex) {
        this.weekDateModelItem = weekDateModel
      }
      weekDateModelList.push(weekDateModel)
    }
    return weekDateModelList
  }
}