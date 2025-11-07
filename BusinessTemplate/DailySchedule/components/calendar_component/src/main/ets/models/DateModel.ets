import dayjs from 'dayjs'

export class DateModel {
  dayjsObj: dayjs.Dayjs // dayjs时间
  day: number // 天
  lunarDay: string // 农历
  isCurrentMonth: boolean // 是否当前月
  dateStr: string // 日期字符串

  constructor(dayjsObj: dayjs.Dayjs, day: number, lunarDay: string, isToMonth: boolean,
    dateStr: string) {
    this.dayjsObj = dayjsObj
    this.day = day
    this.lunarDay = lunarDay
    this.isCurrentMonth = isToMonth
    this.dateStr = dateStr
  }
}

export class FestivalSolar {
  name: string = ''
  date: string = ''
  daysLeft: number = 0
}


export class DateModelList extends Array<DateModel> {
}

export class YearData extends Array<DateModelList> {
}

export class CalendarHeaderItem {
  dateStr: string = ''
  lunarDay: string = ''
}