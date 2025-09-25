import { TodoItem } from '@ohos_agcit/daily_schedule_todo';

export class Utils {
  /**
   * 过滤指定日期的所有任务
   * @param allTasks
   * @param date
   * @returns
   */
  static filterTodayTasks(allTasks: TodoItem[], date: Date): TodoItem[] {
    return allTasks
      .filter(x => x.isFinished === false)
      .filter(x => {
        const planDate = x.planTime;
        return planDate.getFullYear() === date.getFullYear() &&
          planDate.getMonth() === date.getMonth() &&
          planDate.getDate() === date.getDate();
      })
  }
}