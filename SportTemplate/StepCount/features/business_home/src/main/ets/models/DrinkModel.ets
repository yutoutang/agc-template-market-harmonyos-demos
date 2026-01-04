import { common } from '@kit.AbilityKit';
import { PreferenceUtils } from 'lib_common';
import { DrinkVM } from '../viewmodels/DrinkVM';

@ObservedV2
export class DrinkWarnParam {
  id: number = 0;
  time: string = '';
  isOpen: boolean = false;
  prompt ?: string
  reminderId ?: number
}

export interface DelDialogProps {
  time: string,
  title: string,
  subtitle: string,
  confirm: () => void,
  cancel: () => void
}

export interface DrinkParam {
  time: string,
  ml: number,
}

export enum DataType {
  DRINK_WARN_TIME,
  DRINK_DRINK_TIME,
  DRINK_DRINK_RECORD,
}

@ObservedV2
export class DrinkModel {
  static readonly DRINK_DATA_STORE = 'drink_data_store'
  static store: PreferenceUtils = PreferenceUtils.getInstance(getContext() as common.UIAbilityContext, DataType[0])
  @Trace static drinkTime: DrinkParam[] =
    [{ time: '00:00', ml: 0 }, { time: '01:00', ml: 0 }, { time: '02:00', ml: 0 }, { time: '03:00', ml: 0 },
      { time: '04:00', ml: 0 }, { time: '05:00', ml: 0 }, { time: '06:00', ml: 0 }, { time: '07:00', ml: 0 },
      { time: '08:00', ml: 0 }, { time: '09:00', ml: 0 }, { time: '10:00', ml: 0 }, { time: '11:00', ml: 0 },
      { time: '12:00', ml: 0 }, { time: '13:00', ml: 0 }, { time: '14:00', ml: 0 }, { time: '15:00', ml: 0 },
      { time: '16:00', ml: 0 }, { time: '17:00', ml: 0 }, { time: '18:00', ml: 0 }, { time: '19:00', ml: 0 },
      { time: '20:00', ml: 0 }, { time: '21:00', ml: 0 }, { time: '22:00', ml: 0 }, { time: '23:00', ml: 0 },]
  static initDrinkTime: DrinkParam[] =
    [{ time: '00:00', ml: 0 }, { time: '01:00', ml: 0 }, { time: '02:00', ml: 0 }, { time: '03:00', ml: 0 },
      { time: '04:00', ml: 0 }, { time: '05:00', ml: 0 }, { time: '06:00', ml: 0 }, { time: '07:00', ml: 0 },
      { time: '08:00', ml: 0 }, { time: '09:00', ml: 0 }, { time: '10:00', ml: 0 }, { time: '11:00', ml: 0 },
      { time: '12:00', ml: 0 }, { time: '13:00', ml: 0 }, { time: '14:00', ml: 0 }, { time: '15:00', ml: 0 },
      { time: '16:00', ml: 0 }, { time: '17:00', ml: 0 }, { time: '18:00', ml: 0 }, { time: '19:00', ml: 0 },
      { time: '20:00', ml: 0 }, { time: '21:00', ml: 0 }, { time: '22:00', ml: 0 }, { time: '23:00', ml: 0 },]
  static drinkRecord: DrinkParam[] = []

  static drinkStorage(data?: DrinkParam[], date?: string) {
    const dateKey = date || DrinkVM.dateToStr(new Date())
    if (data) {
      DrinkModel.store.put('drink_data', data)
      DrinkVM.saveDrinkRecord(DrinkModel.drinkRecord, 1)
    }
    return DrinkVM.drinkStorage.get(dateKey, []) as DrinkParam[]
  }

  static drinkTimeStorage(data?: DrinkParam[], date?: string) {
    const dateKey = date || DrinkVM.dateToStr(new Date())
    if (data) {
      DrinkModel.store.put('drink_time', data)
      DrinkVM.saveDrinkRecord(DrinkModel.drinkTime, 2)
    }
    return DrinkVM.drinkTimeStorage.get(dateKey, DrinkModel.initDrinkTime) as DrinkParam[]
  }

  static addDrink(time: string, water: number) {
    const today = DrinkVM.dateToStr(new Date())
    DrinkModel.drinkRecord.push({ time: time, ml: water })
    DrinkModel.drinkTime.forEach(item => {
      if (item.time === DrinkModel.getCurrentHour00(time)) {
        item.ml += water
      }
    })
    DrinkModel.drinkRecord = DrinkModel.drinkStorage(DrinkModel.drinkRecord, today)
    DrinkModel.drinkTime = DrinkModel.drinkTimeStorage(DrinkModel.drinkTime, today)
  }

  static delDrink(time: string, water: number) {
    const today = DrinkVM.dateToStr(new Date())
    DrinkModel.drinkRecord.push({ time: time, ml: -water })
    DrinkModel.drinkTime.forEach(item => {
      if (item.time === DrinkModel.getCurrentHour00(time)) {
        item.ml -= water
      }
    })
    DrinkModel.drinkRecord = DrinkModel.drinkStorage(DrinkModel.drinkRecord, today)
    DrinkModel.drinkTime = DrinkModel.drinkTimeStorage(DrinkModel.drinkTime, today)
  }

  static getCurrentHour00(time: string): string {
    return time.slice(0, 2) + ':00'
  }
}

// 喝水记录
export class DrinkRecordModel {
  drinkedWater: number = 0; // 需要共享的字符串
  lackWater: number = 0;
  drinkGoal: number = 2000;
  myDrinkCup: number = 2000
  s: number[] = []
}

