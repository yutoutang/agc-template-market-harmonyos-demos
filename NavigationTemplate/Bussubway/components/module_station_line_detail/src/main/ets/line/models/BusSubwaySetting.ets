/**
 * 全局设置
 */
@ObservedV2
export class BusSubwaySetting {
  // 到站提醒
  @Trace warnType: number = 0; // 提醒类型：0-提前分钟数，1-提前站点
  @Trace warnValue: number = 1; // 提醒数值：1-5
  @Trace accessType: number = 0; // 交通方式选择：0-地铁，1-公交
  @Trace speedType: number = 1; // 刷新频率选择：0-10秒，1-30秒，2-1分钟
  @Trace isArrivalReminder: boolean = true; // 刷新频率选择：0-10秒，1-30秒，2-1分钟
}