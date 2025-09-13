import { promptAction } from '@kit.ArkUI';
import { pasteboard } from '@kit.BasicServicesKit';

export function assign(target: Object, ...source: Object[]) {
  for (let s of source) {
    for (let key of Object.keys(s)) {
      const value = Reflect.get(s, key) as Object;
      Reflect.set(target, key, value);
    }
  }
}

/**
 * 剪贴板内容
 * @param text
 * @returns
 */
export function copyText(text: string) {
  // 创建剪贴板内容对象
  const pasteboardData = pasteboard.createData(
    pasteboard.MIMETYPE_TEXT_PLAIN,
    text,
  );
  // 获取系统剪贴板对象
  const systemPasteboard = pasteboard.getSystemPasteboard();
  systemPasteboard.setData(pasteboardData); // 将数据放入剪贴板
  systemPasteboard.getData().then((data) => {
    // 读取剪贴板内容
    if (data) {
      promptAction.showToast({
        message: '复制成功',
        alignment: Alignment.Center,
      });
    } else {
      promptAction.showToast({
        message: '复制失败',
        alignment: Alignment.Center,
      });
    }
  });
}

export function formatFullDate(date: Date): string {
  const pad = (n: number) => (n < 10 ? '0' + n : n.toString());

  const year = date.getFullYear();
  const month = pad(date.getMonth() + 1); // 月份是从0开始的，所以要加1
  const day = pad(date.getDate());
  const hours = pad(date.getHours());
  const minutes = pad(date.getMinutes());

  return `${year}年${month}月${day}日 ${hours}:${minutes}`;
}

export function formatTime(timestamp: number) {
  const absoluteTimestamp = Math.abs(timestamp);

  // 计算小时、分钟和秒
  const hours = Math.floor(absoluteTimestamp / 3600);
  const minutes = Math.floor((absoluteTimestamp % 3600) / 60);
  const seconds = Math.floor(absoluteTimestamp % 60);

  // 格式化为两位数
  const formattedHours = hours.toString().padStart(2, '0');
  const formattedMinutes = minutes.toString().padStart(2, '0');
  const formattedSeconds = seconds.toString().padStart(2, '0');

  // 处理负数情况
  if (timestamp < 0) {
    return `--`;
  }

  return `${formattedHours}:${formattedMinutes}:${formattedSeconds}`;
}
