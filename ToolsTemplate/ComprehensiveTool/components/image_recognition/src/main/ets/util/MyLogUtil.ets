import { hilog } from '@kit.PerformanceAnalysisKit';

export class MyLog {
  private static flag: string = 'image_recognition';
  private static domain: number = 0xff00;
  private static format: string = '%{public}s, %{public}s';

  public static info(...args: string[]): void {
    hilog.info(MyLog.domain, MyLog.flag, MyLog.format, args);
  }

  public static error(...args: string[]): void {
    hilog.error(MyLog.domain, MyLog.flag, MyLog.format, args);
  }
}
