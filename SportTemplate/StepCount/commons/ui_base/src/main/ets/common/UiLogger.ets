import hilog from '@ohos.hilog';

export class UiLogger {
  static readonly format: string = '%{public}s';
  static readonly domain: number = 0x0000;
  static readonly tag: string = '[UIComponent]';

  static error(...args: string[]) {
    hilog.error(UiLogger.domain, UiLogger.tag, UiLogger.format, args);
  }

  static info(...args: string[]) {
    hilog.info(UiLogger.domain, UiLogger.tag, UiLogger.format, args);
  }

}