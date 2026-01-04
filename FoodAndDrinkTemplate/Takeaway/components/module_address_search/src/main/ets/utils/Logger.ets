import { hilog } from '@kit.PerformanceAnalysisKit';

export class Logger {
  private static _domain: number = 0xff00;
  private static _prefix: string = 'AddressSearch';
  private static _format: string = '%{public}s, %{public}s';

  public static info(...args: string[]): void {
    hilog.info(Logger._domain, Logger._prefix, Logger._format, args);
  }

  public static error(...args: string[]): void {
    hilog.error(Logger._domain, Logger._prefix, Logger._format, args);
  }
}