import { hilog } from '@kit.PerformanceAnalysisKit';

export class TranLogger {
  private static domain: number = 0xff00;
  private static tag: string = 'translator';
  private static format: string = '%{public}s, %{public}s';

  public static debug(...args: string[]): void {
    hilog.debug(TranLogger.domain, TranLogger.tag, TranLogger.format, args);
  }

  public static info(...args: string[]): void {
    hilog.info(TranLogger.domain, TranLogger.tag, TranLogger.format, args);
  }

  public static warn(...args: string[]): void {
    hilog.warn(TranLogger.domain, TranLogger.tag, TranLogger.format, args);
  }

  public static error(...args: string[]): void {
    hilog.error(TranLogger.domain, TranLogger.tag, TranLogger.format, args);
  }
}
