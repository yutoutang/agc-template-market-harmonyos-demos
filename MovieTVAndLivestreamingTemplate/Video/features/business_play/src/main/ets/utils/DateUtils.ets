/**
 * 将秒数转换为时间字符串，小时为0时显示mm:ss，否则显示hh:mm:ss
 * @param seconds 要转换的秒数
 * @returns 格式化后的时间字符串
 */
export function formatSecondsToTime(seconds: number): string {
  // 处理负数情况
  if (seconds < 0) {
    throw new Error('秒数不能为负数');
  }

  // 计算小时、分钟和剩余秒数
  const hours = Math.floor(seconds / 3600);
  const remainingSecondsAfterHours = seconds % 3600;
  const minutes = Math.floor(remainingSecondsAfterHours / 60);
  const remainingSeconds = remainingSecondsAfterHours % 60;

  // 为每个部分添加前导零，确保是两位数
  const formattedHours = String(hours).padStart(2, '0');
  const formattedMinutes = String(minutes).padStart(2, '0');
  const formattedSeconds = String(remainingSeconds).padStart(2, '0');

  // 根据小时是否为0返回不同格式
  if (hours === 0) {
    return `${formattedMinutes}:${formattedSeconds}`;
  } else {
    return `${formattedHours}:${formattedMinutes}:${formattedSeconds}`;
  }
}