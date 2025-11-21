import dayjs from 'dayjs'
import { Lunar } from 'lunar';
import { TodayYiJi } from '../models/CommonModel';
import { weekdayMap } from '../utils/CalculateDate';


@ObservedV2
export class CalendarVM {
  @Trace selectDate: dayjs.Dayjs = dayjs()
  @Trace todayYiJi: TodayYiJi  = new TodayYiJi()
  @Trace todayYinLi: string = ''

  private static _instance: CalendarVM

  public static get instance() {
    if (!CalendarVM._instance) {
      CalendarVM._instance = new CalendarVM()
    }
    return CalendarVM._instance
  }

  public async getCurDateList() {
    this.selectDate = dayjs();
    this.getTodayYiJi()
  }

  public getCurDate() {
    return this.selectDate.format('YYYY.MM.DD')
  }

  public getTodayYiJi() {
    const todayLunar = Lunar.fromDate(new Date(this.selectDate.format('YYYY-MM-DD')));
    // 获取今日宜和忌
    const yi = todayLunar.getDayYi();
    const ji = todayLunar.getDayJi();
    this.todayYiJi = {
      yi,
      ji,
    }
  }

  public getDateLabel() {
    return this.selectDate.format('YYYY年MM月')
  }

  public getDateAllLabel() {
    return this.selectDate.format('YYYY-MM-DD')
  }

  public getCurSolarDate(date?: Date) {
    let currentDate = date ? dayjs(date).format('YYYY.MM.DD') : this.selectDate.format('YYYY.MM.DD')
    const lunar = Lunar.fromDate(new Date(currentDate));
    const lunarDate = lunar.toString()
    const weekday = weekdayMap[new Date().getDay()]
    return `${currentDate} ${weekday} ${lunarDate}`
  }

  public getLunarDateLabel() {
    let d = Lunar.fromDate(this.selectDate.toDate())
    return d.getMonthInChinese() + '月' + d.getDayInChinese()
  }

}

export default CalendarVM