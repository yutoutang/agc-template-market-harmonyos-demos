import { i18n, intl } from '@kit.LocalizationKit';
import { configLG, configSM, FORMAT_MAP, LIST_CENTER_INDEX } from '../constant/CalendarConstant';
import { DayModel, MonthModel } from '../model/CalendarModel';

/**
 * 日期工具类
 */
export class DateUtils {
  /**
   * 用户偏好语言
   */
  static sysPreferredLanguage = i18n.System.getFirstPreferredLanguage();
  /**
   * 年份多语言格式
   */
  static dateFormat = new intl.DateTimeFormat(DateUtils.sysPreferredLanguage, { year: 'numeric' });
  /**
   * 月份多语言格式
   */
  static monthFormat = new intl.DateTimeFormat(DateUtils.sysPreferredLanguage, { month: 'short' });
  /**
   * 星期多语言格式
   */
  static weekFormat = new intl.DateTimeFormat(DateUtils.sysPreferredLanguage, { weekday: 'short' });

  /**
   * 获取本月视图中上个月数据
   * @param year
   * @param month
   * @param startDayOfWeek
   * @returns
   */
  static getLastMonth(year: number, month: number, startDayOfWeek: number): DayModel[] {
    const lastDate = new Date(year, month - 1, 0);
    const DAYS_OF_WEEK = 7;
    let daysNum = (lastDate.getDay() + 1) % DAYS_OF_WEEK;
    while (startDayOfWeek !== 0) {
      daysNum = daysNum === 0 ? DAYS_OF_WEEK - 1 : daysNum - 1;
      startDayOfWeek--;
    }
    const lastMonthData = [...new Array(daysNum)].map((item: number, index) => {
      return new DayModel(lastDate.getFullYear(), lastDate.getMonth() + 1, lastDate.getDate() - index, false);
    });

    return lastMonthData;
  };

  /**
   * 获取本月数据
   * @param year
   * @param month
   * @returns
   */
  static getCurrMonth(year: number, month: number): DayModel[] {
    const totalDays = new Date(year, month, 0).getDate();
    const monthData = [...new Array(totalDays)].map((item: number, index) => {
      return new DayModel(year, month, index + 1, true);
    });
    return monthData;
  };

  /**
   * 获取本月视图中包含的下月数据
   * @param year
   * @param month
   * @param startDayOfWeek
   * @returns
   */
  static getNextMonth(year: number, month: number, startDayOfWeek: number): DayModel[] {
    const firstDate = new Date(year, month, 1);
    const DAYS_OF_WEEK = 7;
    let daysNum = (DAYS_OF_WEEK - firstDate.getDay()) % DAYS_OF_WEEK;
    while (startDayOfWeek !== 0) {
      daysNum = (daysNum + 1) % DAYS_OF_WEEK;
      startDayOfWeek--;
    }
    const nextMonth = [...new Array(daysNum)].map((item: number, index) => {
      return new DayModel(firstDate.getFullYear(), firstDate.getMonth() + 1, index + 1, false);
    });

    return nextMonth;
  };

  /**
   * 获取月视图数据
   * @param year xxxx四位数字
   * @param month 1-12的数字
   * @param startDayOfWeek
   * @returns
   */
  static getMonthData(year: number, month: number, startDayOfWeek: number = 0): MonthModel {
    const monthData = DateUtils.getLastMonth(year, month, startDayOfWeek).reverse()
      .concat(DateUtils.getCurrMonth(year, month))
      .concat(DateUtils.getNextMonth(year, month, startDayOfWeek));
    return new MonthModel(year, month, monthData);
  };

  /**
   * 获取指定月份前后xx个月的数据
   * @param date
   * @param startYear
   * @param endYear
   * @param startDayOfWeek
   * @returns
   */
  static getRoundMonths(date: Date, startYear: number, endYear: number, startDayOfWeek: number) {
    const list: MonthModel[] = [];
    const month = DateUtils.transDate2DayModel(date);

    for (let index = -LIST_CENTER_INDEX; index <= LIST_CENTER_INDEX; index++) {
      const date = new Date(month.year, month.month - 1 + index);
      if (date.getFullYear() < startYear) {
        continue;
      }
      if (date.getFullYear() > endYear) {
        break;
      }
      const targetM = DateUtils.getMonthData(date.getFullYear(), date.getMonth() + 1, startDayOfWeek);
      list.push(targetM);
    }

    return list;
  };

  /**
   * 获取指定月份若干月数据
   * @param month
   * @param startYear
   * @param startDayOfWeek
   * @returns
   */
  static getPreDataBySpecialMonth(month: MonthModel, startYear: number, startDayOfWeek: number) {
    const list: MonthModel[] = [];
    // 已经到达年月边界
    if (month.year === startYear && month.month === 1) {
      return list;
    }

    // 指定月份数量
    const monthNum = 12;
    for (let index = monthNum; index >= 1; index--) {
      const date = new Date(month.year, month.month - 1 - index);
      if (date.getFullYear() < startYear) {
        continue;
      }
      const targetM = DateUtils.getMonthData(date.getFullYear(), date.getMonth() + 1, startDayOfWeek);
      list.push(targetM);
    }

    return list;
  };

  /**
   * 获取指定月份后若干月数据
   * @param month
   * @param endYear
   * @param startDayOfWeek
   * @returns
   */
  static getNextDataBySpecialMonth(month: MonthModel, endYear: number, startDayOfWeek: number) {
    const list: MonthModel[] = [];
    // 已经到达年月边界
    if (month.year === endYear && month.month === 12) {
      return list;
    }

    // 指定月份数量
    const monthNum = 6;
    for (let index = 1; index <= monthNum; index++) {
      const date = new Date(month.year, month.month - 1 + index);
      if (date.getFullYear() > endYear) {
        break;
      }
      const targetM = DateUtils.getMonthData(date.getFullYear(), date.getMonth() + 1, startDayOfWeek);
      list.push(targetM);
    }

    return list;
  };

  /**
   * 判断是否本月第一天
   * @param day
   * @returns
   */
  static isFirstDayOfMonth(day: Date) {
    const lastDayMonth = new Date(day);
    lastDayMonth.setDate(day.getDate() - 1);
    return day.getMonth() !== lastDayMonth.getMonth();
  };

  /**
   * 判断是否本月最后一天
   * @param day
   * @returns
   */
  static isLastDayOfMonth(day: Date) {
    const nextDayMonth = new Date(day);
    nextDayMonth.setDate(day.getDate() + 1);
    return day.getMonth() !== nextDayMonth.getMonth();
  };

  /**
   * 使用系统国际化api格式时间
   * @param date
   * @param format
   * @returns
   */
  static formatTimeSys(date: Date, format: FORMAT_MAP) {
    let dateFormat =
      new intl.DateTimeFormat(DateUtils.sysPreferredLanguage, { timeStyle: 'medium', hourCycle: format });
    return dateFormat.format(date);
  };

  /**
   * 格式化日期
   * @param date
   * @returns xxxx/xx/xx
   */
  static formatDate(date: Date): string {
    return `${date.getFullYear()}/${DateUtils.padZero(date.getMonth() + 1)}/${DateUtils.padZero(date.getDate())}`;
  }

  /**
   * 格式化日期
   * @param date
   * @returns xx月xx日
   */
  static formatDate2(date: Date): string {
    return `${DateUtils.padZero(date.getMonth() + 1)}月${DateUtils.padZero(date.getDate())}日`;
  }

  /**
   * 格式化日期
   * @param date
   * @returns xxxx/xx/xx
   */
  static formatDate3(date: Date): string {
    return `${date.getFullYear()}/${date.getMonth() + 1}/${date.getDate()}`;
  }

  /**
   * 格式化时间
   * @param date
   * @returns xx:xx:xx
   */
  static formatTime(date: Date): string {
    return `${DateUtils.padZero(date.getHours())}:${DateUtils.padZero(date.getMinutes())}:${DateUtils.padZero(date.getSeconds())}`;
  };

  /**
   * 格式化日期时间
   * @param date
   * @returns xxxx/xx/xx xx:xx:xx
   */
  static formatDateTime(date: Date): string {
    return `${DateUtils.formatDate(date)} ${DateUtils.formatTime(date)}`;
  }

  /**
   * 不足两位数，补0
   * @param input
   * @returns
   */
  static padZero(input: number) {
    return input.toString().padStart(2, '0');
  };

  /**
   * 获取星期常量值
   * @returns
   */
  static getWeekLabelList() {
    // 定义一周7天
    const datesOfWeek = [
      new Date('2024-07-21'),
      new Date('2024-07-22'),
      new Date('2024-07-23'),
      new Date('2024-07-24'),
      new Date('2024-07-25'),
      new Date('2024-07-26'),
      new Date('2024-07-27'),
    ];

    return datesOfWeek.map((date) => DateUtils.weekFormat.format(date).toUpperCase().replace('周', ''));
  };

  /**
   * 获取指定一周起始日的星期常量值
   * @param startDayOfWeek
   * @returns
   */
  static getWeekLabels(startDayOfWeek: number = 0): string[] {
    const orders: number[] = [];
    let weekDays = 7;
    let initVal = startDayOfWeek;

    while (weekDays !== 0) {
      orders.push(initVal);
      initVal = (initVal + 1) % 7;
      weekDays--;
    }

    const weekLabels = DateUtils.getWeekLabelList();
    return orders.map((item: number) => {
      return weekLabels[item];
    });
  };

  /**
   * 系统格式化年，中文xxxx年，英文xxxx
   * @param year
   * @returns
   */
  static formatYear(year: string): string {
    return DateUtils.dateFormat.format(new Date(year));
  };

  /**
   * 获取所有年份的多语言常量
   * @param start
   * @param end
   * @returns
   */
  static getYearLabels(start: number, end: number): string[] {
    const list: string[] = [];
    for (let index = start; index <= end; index++) {
      list.push(DateUtils.formatYear(index.toString()));
    }
    return list;
  };

  /**
   * 通过系统api，获取12个月份的多语言常量
   * @returns
   */
  static getMonthLabels(): string[] {
    // 定义一年12月
    const monthsOfYear = [
      new Date('2024-01-01'),
      new Date('2024-02-01'),
      new Date('2024-03-01'),
      new Date('2024-04-01'),
      new Date('2024-05-01'),
      new Date('2024-06-01'),
      new Date('2024-07-01'),
      new Date('2024-08-01'),
      new Date('2024-09-01'),
      new Date('2024-10-01'),
      new Date('2024-11-01'),
      new Date('2024-12-01'),
    ];
    return monthsOfYear.map((date) => DateUtils.monthFormat.format(date));
  };

  /**
   * 设置当前视图所在月份
   * @param input 选择的日期
   * @param startYear 起始年份
   * @param endYear 结束年份
   * @returns
   */
  static correctSelectedDate(input: Date | null, startYear: number, endYear: number): Date {
    if (input) {
      return new Date(input);
    }

    // 默认先设置成系统日期
    let showDate: Date = new Date();

    // 选择日期早于起始年份
    if (showDate.getFullYear() < startYear) {
      return new Date(startYear, 0, 1, 0, 0, 0);
    }

    // 选择日期晚于结束年份
    if (showDate.getFullYear() > endYear) {
      return new Date(endYear, 11, 1, 0, 0, 0);
    }

    return showDate;
  }

  /**
   * 判断默认日期是否在范围内
   * @param input
   * @param startYear
   * @param endYear
   * @param allowStart
   * @param allowEnd
   * @param disabledDates
   * @returns
   */
  static isValidDefaultDate(input: Date | null, startYear: number, endYear: number, allowStart: DayModel | null,
    allowEnd: DayModel | null, disabledDates: Date[]): Boolean {
    if (!input) {
      return false;
    }
    const selected = new Date(input);
    selected.setHours(0, 0, 0, 0);

    // 早于起始年份
    if (selected.getFullYear() < startYear) {
      return false;
    }

    // 晚于结束年份
    if (selected.getFullYear() > endYear) {
      return false;
    }

    // 选择日期早于起始日期
    if (allowStart && selected.getTime() < allowStart.getTimestamp()) {
      return false;
    }

    // 选择日期晚于结束日期
    if (allowEnd && selected.getTime() > allowEnd.getTimestamp()) {
      return false;
    }

    // 在禁选日期范围内
    const disabled = disabledDates.map((date: Date) => {
      const nVal = new Date(date);
      nVal.setHours(0, 0, 0, 0);
      return nVal.getTime();
    })
    if (disabled.includes(selected.getTime())) {
      return false;
    }

    return true;
  }

  /**
   * 多日期去重
   * @param arr
   */
  static removeDuplicate(arr: Date[]) {
    let len = arr.length;
    for (let i = 0; i < len; i++) {
      for (let j = i + 1; j < len; j++) {
        if (arr[i].getTime() === arr[j].getTime()) {
          arr.splice(j, 1);
          len--;
          j--;
        }
      }
    }
  }

  /**
   * 获取相应断点下的配置
   * @param breakpoint
   * @returns
   */
  static getConfigByBreakpoint(breakpoint: string) {
    if (breakpoint === 'sm' || breakpoint === 'md') {
      return configSM;
    }
    return configLG;
  }

  /**
   * 将Date格式转换为DayModel格式
   * @param date
   * @returns
   */
  static transDate2DayModel(date: Date): DayModel {
    return new DayModel(date.getFullYear(), date.getMonth() + 1, date.getDate(), false);
  };

  /**
   * month数据key-value赋值
   * @param current
   * @param target
   */
  static assignMonth(current: MonthModel, target: MonthModel) {
    current.year = target.year;
    current.month = target.month;
    current.data = target.data;
  }

  /**
   * 获取某天所在的月份信息
   */
  static getMonthInfo(date: Date): [number, number] {
    return [date.getFullYear(), date.getMonth() + 1]
  }

  /**
   * 获取某天所在的周信息(周日到周六)
   */
  static getWeekRange(date: Date): [Date, Date] {
    const weekDay = date.getDay();
    const start = new Date(date);
    start.setDate(date.getDate() - weekDay);
    const end = new Date(date);
    end.setDate(date.getDate() + (6 - weekDay));
    return [start, end]
  }

  /**
   * 获取某天所在的周信息(周一到周日)
   */
  static getWeekRange2(date: Date): [Date, Date] {
    const weekDay = date.getDay();
    const start = new Date(date);
    start.setDate(date.getDate() - weekDay + 1);
    const end = new Date(date);
    end.setDate(date.getDate() + (7 - weekDay));
    return [start, end]
  }

  /**
   * 获取某天所在的月信息
   */
  static getMonthRange(date: Date): [Date, Date] {
    const totalDays = new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate();
    const start = new Date(date);
    start.setDate(1);
    const end = new Date(date);
    end.setDate(totalDays);
    return [start, end]
  }

  /**
   *  获取两个日期之间的所有日期
   */
  static getDateBetween(startDate: Date, endDate: Date): Date[] {
    const dates: Date[] = []
    const tempDate = new Date(startDate)
    while (tempDate <= endDate) {
      dates.push(new Date(tempDate))
      tempDate.setDate(tempDate.getDate() + 1)
    }
    return dates
  }

  static formaterTimeLength(timeLength: number, colonSplit: boolean = true) {
    const hour = Math.floor((timeLength / (60 * 60)))
    const minute = Math.floor(((timeLength - (hour * 60 * 60)) / 60))
    const second = timeLength - (hour * 60 * 60) - (minute * 60)
    if (colonSplit) {
      return DateUtils.padZero(hour) + ':' + DateUtils.padZero(minute) + ':' + DateUtils.padZero(second)
    }
    return DateUtils.padZero(hour) + '时' + DateUtils.padZero(minute) + '分' + DateUtils.padZero(second) + '秒'
  }

  static formaterTimeLength2(timeLength: number) {
    if (timeLength && /^\d+(\.\d+)?$/.test(JSON.stringify(timeLength))) {
      const hour = Math.floor((timeLength / (60 * 60)))
      const minute = Math.floor(((timeLength - (hour * 60 * 60)) / 60))
      const second = timeLength - (hour * 60 * 60) - (minute * 60)
      return DateUtils.padZero(minute) + '′' + DateUtils.padZero(Math.floor(parseFloat(String(second)))) + '″'
    } else {
      return '00′00″'
    }

  }
}
