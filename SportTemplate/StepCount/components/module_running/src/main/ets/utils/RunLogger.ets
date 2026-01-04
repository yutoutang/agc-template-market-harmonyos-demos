import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 日志打印类
 */
export class RunLogger {
  private static domain: number = 0xff00;
  private static format: string = '%{public}s, %{public}s';
  private static prefix: string = 'ComprehensiveNews';

  public static warn(...args: string[]): void {
    hilog.warn(RunLogger.domain, RunLogger.prefix, RunLogger.format, args);
  }

  public static info(...args: string[]): void {
    hilog.info(RunLogger.domain, RunLogger.prefix, RunLogger.format, args);
  }

  public static debug(...args: string[]): void {
    hilog.debug(RunLogger.domain, RunLogger.prefix, RunLogger.format, args);
  }

  public static error(...args: string[]): void {
    hilog.error(RunLogger.domain, RunLogger.prefix, RunLogger.format, args);
  }
}
