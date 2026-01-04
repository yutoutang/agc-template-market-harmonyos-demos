export class CommonConstants {
  static readonly TASK_MAX: number = 10;
  // 同时开启最大任务数
  static readonly TASK_PAUSE_MSG: number = -1;
  // 暂停
  static readonly TASK_RESUME_MSG: number = -2;
  // 继续下载
  static readonly TASK_NET_PAUSE_MSG: number = -3;
  // 网络异常
  static readonly TASK_NET_RESUME_MSG: number = -4;
  /**
   *  进度最大值
   */
  static readonly PROGRESS_MAX = 100;
}