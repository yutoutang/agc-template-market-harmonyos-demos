export class DateUtils {
  /**
   * 星期数组
   */
  static weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

  /**
   *  判断两个日期是否是同一天
   * @param date1
   * @param date2
   * @returns
   */
  static isSameDay(date1: Date, date2: Date) {
    if (!date1 || !date2) {
      return false;
    }

    const d1 = new Date(date1);
    const d2 = new Date(date2);
    return d1.getFullYear() === d2.getFullYear() &&
      d1.getMonth() === d2.getMonth() &&
      d1.getDate() === d2.getDate();
  }

  /**
   * 获取日期的星期
   *
   * @param date
   * @returns
   */
  static getWeek(date: Date) {
    const inputDate = new Date(date);
    const dayIndex = inputDate.getDay();
    return DateUtils.weekdays[dayIndex];
  }

  /**
   * 获取日期的补零的日
   * @param date
   * @returns
   */
  static getDayWithZero(date: Date) {
    const inputDate = new Date(date);
    return String(inputDate.getDate()).padStart(2, '0');
  }
}
