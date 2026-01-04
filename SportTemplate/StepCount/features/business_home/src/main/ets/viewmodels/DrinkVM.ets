import { common } from '@kit.AbilityKit'
import { PersistenceV2 } from '@kit.ArkUI'
import { BaseViewModel, PreferenceUtils } from 'lib_common'
import { GlobalStore } from '../pages/DrinkPage'
import { DrinkModel, DrinkParam, DrinkRecordModel } from '../models/DrinkModel'

const drinkTime: DrinkParam[] =
  [{ time: '00:00', ml: 0 }, { time: '01:00', ml: 0 }, { time: '02:00', ml: 0 }, { time: '03:00', ml: 0 },
    { time: '04:00', ml: 0 }, { time: '05:00', ml: 0 }, { time: '06:00', ml: 0 }, { time: '07:00', ml: 0 },
    { time: '08:00', ml: 0 }, { time: '09:00', ml: 0 }, { time: '10:00', ml: 0 }, { time: '11:00', ml: 0 },
    { time: '12:00', ml: 0 }, { time: '13:00', ml: 0 }, { time: '14:00', ml: 0 }, { time: '15:00', ml: 0 },
    { time: '16:00', ml: 0 }, { time: '17:00', ml: 0 }, { time: '18:00', ml: 0 }, { time: '19:00', ml: 0 },
    { time: '20:00', ml: 0 }, { time: '21:00', ml: 0 }, { time: '22:00', ml: 0 }, { time: '23:00', ml: 0 },]

/**
 * 喝水相关逻辑
 */
@ObservedV2
export class DrinkVM extends BaseViewModel {
  static drinkRecordStore: PreferenceUtils =
    PreferenceUtils.getInstance(getContext() as common.UIAbilityContext, 'drink_main_store')
  static drinkStorage: PreferenceUtils =
    PreferenceUtils.getInstance(getContext() as common.UIAbilityContext, 'drink_storage')
  static drinkTimeStorage: PreferenceUtils =
    PreferenceUtils.getInstance(getContext() as common.UIAbilityContext, 'drink_time_storage')
  @Trace isToday: boolean = true
  // 当前选择日期 2023/02/04
  @Trace currentDateStr: string = ''
  currentDate: Date = new Date()
  @Trace store: DrinkRecordModel = new DrinkRecordModel()
  @Trace drinkData: DrinkParam[] = []
  @Trace drinkTimeData: DrinkParam[] = []
  @Trace percent: number = 0.4
  @Trace sliderWidth: number = 0 // 父容器宽，onAreaChange 获取

  // 保存今天记录
  static saveRecord() {
    let store: GlobalStore = PersistenceV2.connect(GlobalStore, 'global', () => new GlobalStore())!;
    let data: DrinkRecordModel = new DrinkRecordModel()
    data.drinkedWater = store.drinkedWater
    data.lackWater = store.lackWater
    data.drinkGoal = store.drinkGoal
    data.myDrinkCup = store.myDrinkCup
    data.s = store.s
    DrinkVM.drinkRecordStore.put(DrinkVM.dateToStr(new Date()), data)
  }

  /**
   * 保存喝水和喝水时间记录
   * @param record
   * @param type 1-喝水 2-喝水时间
   */
  static saveDrinkRecord(record: DrinkParam[], type: number) {
    if (type === 1) {
      DrinkVM.drinkStorage.put(DrinkVM.dateToStr(new Date()), record)
    } else if (type === 2) {
      DrinkVM.drinkTimeStorage.put(DrinkVM.dateToStr(new Date()), record)
    }
  }

  static dateToStr(targetDate: Date) {
    const year = targetDate.getFullYear();
    const month = String(targetDate.getMonth() + 1).padStart(2, '0');
    const day = String(targetDate.getDate()).padStart(2, '0');
    return `${year}/${month}/${day}`;
  }

  init() {
    this.calcPercent()
    this.currentDateStr = DrinkVM.dateToStr(new Date())
  }

  // 计算进度条
  calcPercent() {
    this.percent = Number(this.div(this.store.drinkedWater, this.store.drinkGoal))
    this.store.lackWater = this.store.drinkGoal - this.store.drinkedWater
  }

  div(a: number, b: number): string {
    const v = Math.round((a / b) * 10) / 10; // 保留一位
    return v % 1 === 0 ? String(Math.trunc(v)) : v.toFixed(1);
  }

  dateRecord(date: string): DrinkRecordModel {
    let data = DrinkVM.drinkRecordStore.get(date)
    if (data) {
      return data as DrinkRecordModel
    }
    return new DrinkRecordModel()
  }

  // 切换日期
  changeDate(isLeft: boolean) {
    if (!isLeft && this.currentDateStr === DrinkVM.dateToStr(new Date())) {
      return
    }
    let date = new Date(this.currentDate)
    date.setDate(date.getDate() + (isLeft ? -1 : 1))
    this.currentDateStr = DrinkVM.dateToStr(date)
    this.currentDate = date
    this.isToday = this.currentDateStr === DrinkVM.dateToStr(new Date())
    if (!this.isToday) { //
      this.store = this.dateRecord(this.currentDateStr) as DrinkRecordModel
      this.calcPercent()
      this.drinkData = DrinkVM.drinkStorage.get(this.currentDateStr, []) as DrinkParam[]
      this.drinkTimeData = DrinkVM.drinkTimeStorage.get(this.currentDateStr, drinkTime) as DrinkParam[]
    } else {
      // 切换回今天时，重新加载今天的数据到 DrinkModel
      DrinkModel.drinkRecord = DrinkVM.drinkStorage.get(this.currentDateStr, []) as DrinkParam[]
      DrinkModel.drinkTime = DrinkVM.drinkTimeStorage.get(this.currentDateStr, drinkTime) as DrinkParam[]
    }
  }
}