import { display } from '@kit.ArkUI';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import dayjs from 'dayjs';
import relativeTime from 'dayjs/plugin/relativeTime';
import isToday from 'dayjs/plugin/isToday';
import isYesterday from 'dayjs/plugin/isYesterday';
import { Size } from './Model'
import { FeedCardInfoModel } from '../model/RecommendModel';

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
    return px2vp(value);
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

export function calculateDimensionsUser(url: string): Size {
  // 调用 extractDimension 函数提取宽度和高度
  let width = extractDimension(url, 'w');
  let height = extractDimension(url, 'h');

  // 如果提取的宽度或高度为 null，则使用 0 作为默认值
  width = width !== null ? width : 0;
  height = height !== null ? height : 0;

  // 计算宽高比
  const aspectRatio = width / height;

  if (aspectRatio < 1) {
    width = 220 - 16
    height = width / (2 / 3);
  } else if (aspectRatio === 1) {
    width = 280 - 16
    height = width;
  } else {
    width = 327 - 16
    height = width / 1.5;
  }
  return new Size(width, height);
}

export function twoImagesSize(num: number, content: UIContext, componentId: string) {
  let info = content.getComponentUtils().getRectangleById(componentId)
  let currentWidth = info.size.width
  if (componentId === 'home_news' && AppStorage.get('home_news')) {
    currentWidth = AppStorage.get('home_news') ?? currentWidth
  }
  if (componentId === 'home_news') {
    AppStorage.setOrCreate('home_news', currentWidth)
  }
  console.log(currentWidth + 'currentWidth', componentId)
  /*
   * 组件padding 24 间距 8
   * num 组件数量
   * */
  if (!(num % 3) || num >= 6) {
    return (px2vp(currentWidth) - 16) / 3
  }
  return (px2vp(currentWidth) - 16) / 2
}

export function twoImagesSizeUser(num: number) {
  let displayClass: display.Display = display.getDefaultDisplaySync();
  /*
   * 组件padding 24 间距 8
   * num 组件数量
   * */
  if (num === 9) {
    return (px2vp(displayClass.width) - 24 - 24 - 32) / 3
  }
  if (num >= 4) {
    return (px2vp(displayClass.width) - 24 - 16 - 32) / 2
  }
  return (px2vp(displayClass.width) - 24 - 16 - 32) / num
}

export function harmonyOSSystemShare(content: string, context: common.UIAbilityContext) {
  /*
   * 拉起华为分享
   * 当前只支持分享链接
   * */
  let data: systemShare.SharedData = new systemShare.SharedData({
    utd: utd.UniformDataType.PLAIN_TEXT,
    content: content,
  });

  let controller: systemShare.ShareController = new systemShare.ShareController(data);
  controller.show(context, {
    previewMode: systemShare.SharePreviewMode.DETAIL,
    selectionMode: systemShare.SelectionMode.SINGLE,
  });
  let callback = () => {
    console.info('Share panel closed');
  };
  controller.on('dismiss', callback);
  controller.off('dismiss', callback);
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
