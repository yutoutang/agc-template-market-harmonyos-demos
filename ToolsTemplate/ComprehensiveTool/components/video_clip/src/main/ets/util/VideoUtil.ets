export class VideoUtil {
  /**
   * 视频时长转换
   * @param microseconds
   * @returns
   */
  static formatUsToMinSec(microseconds: number): string {
    // 处理负数情况，取绝对值
    const us = Math.abs(microseconds);
    // 微秒转秒（1秒 = 1,000,000微秒），向下取整
    const totalSeconds = Math.floor(us / 1000000);
    // 计算分钟和剩余秒数
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    // 数字补零处理（确保两位数）
    const padZero = (num: number): string => num.toString().padStart(2, '0');
    // 拼接成 "XX分:XX秒" 格式
    return ` ${padZero(minutes)}:${padZero(seconds)}`;
  }

  /**
   * 将byte转换为MB
   * @param byteSize
   * @returns
   */
  static formatFileSize(bytes: number): string {
    if (bytes <= 0) {
      return '0 B';
    }
    const units = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(1024));
    return `${(bytes / Math.pow(1024, i)).toFixed(2)} ${units[i]}`;
  }
}