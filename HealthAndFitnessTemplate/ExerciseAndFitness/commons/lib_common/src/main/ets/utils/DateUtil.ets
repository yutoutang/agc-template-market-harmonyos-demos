export class DateUtil {
  static formatDate(
    date: Date,
    split: string = '-',
    myWeekday?: string,
    myTimeStyle?: string
  ): string {
    let result = '';

    // 格式化日期 (YYYY-MM-DD)
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    result = `${year}${split}${month}${split}${day}`;

    // 添加星期
    if (myWeekday) {
      const weekdays = ['日', '一', '二', '三', '四', '五', '六'];
      const weekday = weekdays[date.getDay()];
      result += ` 周${weekday}`;
    }

    // 添加时间
    if (myTimeStyle) {
      const hour = String(date.getHours()).padStart(2, '0');
      const minute = String(date.getMinutes()).padStart(2, '0');
      const second = String(date.getSeconds()).padStart(2, '0');

      if (myTimeStyle === 'short') {
        result += ` ${hour}:${minute}`;
      } else if (myTimeStyle === 'long') {
        result += ` ${hour}:${minute}:${second}`;
      } else {
        result += ` ${hour}:${minute}:${second}`;
      }
    }

    return result;
  }

  static parseDateString(dateTimeStr: string): Date {
    const timeStrs:string[] = dateTimeStr.split(' ')
    const dateNumbers: number[] = timeStrs[0].split('-').map(Number);
    let date: Date = new Date(dateNumbers[0], dateNumbers[1] - 1, dateNumbers[2]);
    if (timeStrs.length > 1) {
      const timeNumbers: number[] = timeStrs[1].split(':').map(Number);
      date.setHours(timeNumbers[0], timeNumbers[1]);
      if (timeNumbers.length > 2) {
        date.setSeconds(timeNumbers[2])
      }
    }
    return date
  }
}