import { Constant } from '../constants/Constant';

export class CommonUtil {
  static padWithZeros(num: number) {
    if (num) {
      return num.toString().padStart(2, '0');
    }
    return '00';
  }

  static verifyPhoneNo(phone: string) {
    const phoneReg = /^1(3|4|5|7|8|9)\d{9}$/;
    return phoneReg.test(phone);
  }

  static verifyCardNo(cardNo: string) {
    const cardNoReg = /^[1-9]\d{5}(18|19|20)\d{2}((0[1-9])|(1[0-2]))(([0-2][1-9])|10|20|30|31)\d{3}[0-9Xx]$/;
    return cardNoReg.test(cardNo);
  }

  static getInitDates(currentYear: number, currentMonth: number, currentDay: number) {
    let currentMaxDay = new Date(currentYear, currentMonth, 0).getDate();
    let currentDate = new Date(currentYear, currentMonth, currentDay);
    let nextDate = new Date(0, 0, 0);
    let afterNextDay = new Date(0, 0, 0);
    if (currentDay === currentMaxDay) {
      if (currentMonth === Constant.LAST_MONTH) { //为12月，下一天为下一年
        nextDate = new Date(currentYear + 1, Constant.FIRST, Constant.FIRST);
        afterNextDay = new Date(currentYear + 1, Constant.FIRST, Constant.FIRST + 1);
      } else {
        nextDate = new Date(currentYear, currentMonth + 1, Constant.FIRST);
        nextDate = new Date(currentYear, currentMonth + 1, Constant.FIRST + 1);
      }
    } else {
      nextDate = new Date(currentYear, currentMonth, currentDay + 1);
      afterNextDay = new Date(currentYear, currentMonth, currentDay + 2);
    }
    return [currentDate, nextDate, afterNextDay];
  }

  static getFormatTime(date: Date) {
    let currentMonth = date.getMonth() + 1; // 获取当前月份，getMonth()获得的值是0~11，实际月份需要+1
    let currentDay = date.getDate(); // 获取当前日
    let currentYear = date.getFullYear();
    let currentHour = date.getHours();
    let currentMinutes = date.getMinutes();
    let currentSeconds = date.getSeconds();
    return `${currentYear}-${CommonUtil.padWithZeros(currentMonth)}-${CommonUtil.padWithZeros(currentDay)} ${CommonUtil.padWithZeros(currentHour)}:${CommonUtil.padWithZeros(currentMinutes)}:${CommonUtil.padWithZeros(currentSeconds)}`;
  }

  static getFormatDate(date: Date) {
    let currentMonth = date.getMonth() + 1; // 获取当前月份，getMonth()获得的值是0~11，实际月份需要+1
    let currentDay = date.getDate(); // 获取当前日
    let currentYear = date.getFullYear();
    return `${currentYear}-${CommonUtil.padWithZeros(currentMonth)}-${CommonUtil.padWithZeros(currentDay)}`;
  }

  static getValidEndTime(startDate: Date) {
    return `${startDate.getFullYear()}-${CommonUtil.padWithZeros(startDate.getMonth() +
      1)}-${CommonUtil.padWithZeros(startDate.getDate())}`;
  }
}