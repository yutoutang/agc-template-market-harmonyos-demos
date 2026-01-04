/**
 * 通用方法类
 */
export class Utils {

  /**
   * 获取指定天数前的日期
   * @param count
   * @returns
   */
  public static previousDate(count: number): string {
    let date = new Date()
    date.setDate(date.getDate() + count)
    return date.getFullYear() + '/' + (date.getMonth() + 1) + '/' + date.getDate()
  }
}