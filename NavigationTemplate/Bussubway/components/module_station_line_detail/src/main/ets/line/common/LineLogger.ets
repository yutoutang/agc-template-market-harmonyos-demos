import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 日志打印类
 */
export class LineLogger {
  private static domain: number = 0xff00;
  private static prefix: string = 'LineDetailModule';
  private static format: string = '%{public}s, %{public}s';

  public static debug(...args: string[]): void {
    hilog.debug(LineLogger.domain, LineLogger.prefix, LineLogger.format, args);
  }

  public static info(...args: string[]): void {
    hilog.info(LineLogger.domain, LineLogger.prefix, LineLogger.format, args);
  }

  public static warn(...args: string[]): void {
    hilog.warn(LineLogger.domain, LineLogger.prefix, LineLogger.format, args);
  }

  public static error(...args: string[]): void {
    hilog.error(LineLogger.domain, LineLogger.prefix, LineLogger.format, args);
  }
}
