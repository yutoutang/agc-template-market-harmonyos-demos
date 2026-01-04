/**
 * 全局设置
 */
@ObservedV2
export class MapSettingModel {
  // Setting
  static readonly SETTING_SPEED: number[] = [10, 30, 60]
  // 到站提醒
  @Trace warnType: number = 0; // 提醒类型：0-提前分钟数，1-提前站点
  @Trace warnValue: number = 1; // 提醒数值：1-5
  @Trace speedType: number = 1; // 刷新频率选择：0-10秒，1-30秒，2-1分钟
  @Trace isArrivalReminder: boolean = false; // 是否开启到站提醒
}