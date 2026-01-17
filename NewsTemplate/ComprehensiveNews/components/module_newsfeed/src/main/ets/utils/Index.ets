import dayjs from 'dayjs';
import relativeTime from 'dayjs/plugin/relativeTime';
import isToday from 'dayjs/plugin/isToday';
import isYesterday from 'dayjs/plugin/isYesterday';
import { GlobalContextUtils } from 'lib_common';
import { Size } from './Model'

dayjs.extend(relativeTime);
dayjs.extend(isToday);
dayjs.extend(isYesterday);

export function extractDimension(url: string, dimension: string) {
  // 创建正则表达式对象
  const regExp = new RegExp(`${dimension}=\\d+`);
  // 使用 exec 方法进行匹配，返回第一个匹配结果
  const match = regExp.exec(url);
  if (match) {
    // 获取匹配到的完整字符串
    const dimensionString = match[0];
    // 从匹配结果中提取数字部分
    const value = parseInt(dimensionString.slice(dimension.length + 1), 10);
    return GlobalContextUtils.globalUIContext.px2vp(value);
  }
  return null;
}

export function calculateDimensions(url: string | undefined): Size {
  if (!url) {
    return new Size(0, 0)
  }
  // 调用 extractDimension 函数提取宽度和高度
  let width = extractDimension(url, 'w');
  let height = extractDimension(url, 'h');

  // 如果提取的宽度或高度为 null，则使用 0 作为默认值
  width = width !== null ? width : 0;
  height = height !== null ? height : 0;

  // 计算宽高比
  const aspectRatio = width / height;

  if (aspectRatio < 1) {
    width = 220
    height = width / (2 / 3);
  } else if (aspectRatio === 1) {
    width = 280
    height = width;
  } else if (aspectRatio > 1) {
    width = 327
    height = width / 1.5;
  } else {
    if (url.includes('.mp4')) {
      width = 327
      height = width / 1.5;
    } else {
      width = 220
      height = width / (2 / 3);
    }
  }
  return new Size(width, height);
}

/*
 * 获取时间周期
 * */
export function getDateDiff(dateTimeStamp: number): string {
  if (!dateTimeStamp || dateTimeStamp <= 0) {
    return '';
  }
  const now = dayjs();
  const target = dayjs(dateTimeStamp);
  if (target.isAfter(now)) {
    return '';
  }
  const diffSeconds = now.diff(target, 'second');
  if (diffSeconds < 60) {
    return '刚刚';
  }
  const diffMinutes = now.diff(target, 'minute');
  if (diffMinutes < 60) {
    return `${diffMinutes}分钟前`;
  }
  const diffHours = now.diff(target, 'hour');
  if (diffHours < 24) {
    return `${diffHours}小时前`;
  }
  if (target.isYesterday()) {
    return '昨天';
  }
  if (target.isSame(now.subtract(2, 'day'), 'day')) {
    return '前天';
  }
  if (target.isAfter(now.subtract(7, 'day'))) {
    const diffDays = now.diff(target, 'day');
    return `${diffDays}天前`;
  }
  return target.format('YYYY-MM-DD');
}

export function formatToK(number: number) {
  if (Math.abs(number) < 1000) {
    return String(number);
  }
  const valueInK = (number / 1000).toFixed(1);
  return valueInK.replace(/\.0$/, '') + 'k';
}


/*
 * 获取ColumnsTemplate
 * */
export function getColumnsTemplate(imageCount: number) {
  const count = Number(imageCount);
  if (isNaN(count)) {
    return 0;
  }
  if (count === 1) {
    return 1;
  } else if (count === 2) {
    return 2;
  } else if (count === 3) {
    return 3;
  } else if (count === 4) {
    return 2;
  } else if (count > 4) {
    return 3;
  }
  return 0;
}
