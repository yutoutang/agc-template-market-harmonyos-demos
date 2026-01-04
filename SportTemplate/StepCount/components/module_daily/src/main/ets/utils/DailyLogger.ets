import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 日志打印类
 */
export class DailyLogger {
  private static prefix: string = 'module_daily';
  private static domain: number = 0xff00;
  private static format: string = '%{public}s, %{public}s';

  public static debug(...value: string[]): void {
    hilog.debug(DailyLogger.domain, DailyLogger.prefix, DailyLogger.format, value);
  }
  
  public static warn(...value: string[]): void {
    hilog.warn(DailyLogger.domain, DailyLogger.prefix, DailyLogger.format, value);
  }

  public static error(...value: string[]): void {
    hilog.error(DailyLogger.domain, DailyLogger.prefix, DailyLogger.format, value);
  }

  public static info(...value: string[]): void {
    hilog.info(DailyLogger.domain, DailyLogger.prefix, DailyLogger.format, value);
  }
}



