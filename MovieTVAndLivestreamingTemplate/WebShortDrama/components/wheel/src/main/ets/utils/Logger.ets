
import { hilog } from '@kit.PerformanceAnalysisKit'

class Logger {
  private domain: number
  private prefix: string
  private format: string = '%{public}s, %{public}s'

  /**
   * 构造函数
   *
   * @param prefix 标识日志标签
   * @param domain 服务域，是一个从 0x0 到 0xFFFFF 的十六进制整数
   */
  constructor(prefix: string = 'MyApp', domain: number = 0xFF00) {
    this.prefix = prefix
    this.domain = domain
  }

  /**
   * 输出调试信息
   *
   * @param args 调试信息参数
   */
  debug(...args: string[]): void {
    hilog.debug(this.domain, this.prefix, this.format, args)
  }

  /**
   * 输出信息
   *
   * @param args 信息参数
   */
  info(...args: string[]): void {
    hilog.info(this.domain, this.prefix, this.format, args)
  }

  /**
   * 输出警告信息
   *
   * @param args 警告信息参数
   */
  warn(...args: string[]): void {
    hilog.warn(this.domain, this.prefix, this.format, args)
  }

  /**
   * 输出错误信息
   *
   * @param args 错误信息参数
   */
  error(...args: string[]): void {
    hilog.error(this.domain, this.prefix, this.format, args)
  }
}

export default new Logger('[CanvasComponent]', 0xFF00)