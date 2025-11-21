import { hilog } from '@kit.PerformanceAnalysisKit';

export class Logger {
  private static flag: string = 'credentials_photo';
  private static domain: number = 0xff00;
  private static format: string = '%{public}s, %{public}s';

  public static info(...args: string[]): void {
    hilog.info(Logger.domain, Logger.flag, Logger.format, args);
  }

  public static error(...args: string[]): void {
    hilog.error(Logger.domain, Logger.flag, Logger.format, args);
  }
}
