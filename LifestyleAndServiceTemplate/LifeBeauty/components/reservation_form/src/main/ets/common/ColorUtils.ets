import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = '[ColorUtils]';
const FORMAT = '%{public}s';

export interface IRgb {
  r: number
  g: number
  b: number
}

/**
 * 将十六进制颜色转换为RGB值
 * @param {string} hex - 十六进制颜色字符串（不带#号）
 * @returns {Object} RGB对象 {r, g, b}
 */
export function hexToRgb(hex: string): IRgb {
  // 确保输入是6位字符
  if (hex.length !== 6) {
    throw new Error('无效的十六进制颜色值，必须是6位字符');
  }

  return {
    r: parseInt(hex.substring(0, 2), 16),
    g: parseInt(hex.substring(2, 4), 16),
    b: parseInt(hex.substring(4, 6), 16),
  } as IRgb;
}

/**
 * 将RGB值转换为十六进制颜色
 * @param {number} r - 红色值 (0-255)
 * @param {number} g - 绿色值 (0-255)
 * @param {number} b - 蓝色值 (0-255)
 * @returns {string} 十六进制颜色字符串（不带#号）
 */
export function rgbToHex(r: number, g: number, b: number): string {
  // 确保值在0-255范围内
  const clamp = (value: number) => Math.max(0, Math.min(255, Math.round(value)));

  return [r, g, b]
    .map(value => clamp(value).toString(16).padStart(2, '0'))
    .join('')
    .toUpperCase();
}

/**
 * 计算十六进制颜色叠加指定透明度后得到的新颜色
 * 假设背景为纯白色(#FFFFFF)
 * @param {string} hexColor - 基础颜色（十六进制，带#号）
 * @param {number} opacity - 透明度 (0-100)，0表示完全透明，100表示完全不透明
 * @returns {string} 结果颜色（十六进制，带#号）
 */
export function getColorWithOpacity(hexColor: string, opacity: number) {
  try {
    if (typeof hexColor !== 'string' || hexColor.length !== 7) {
      throw new Error('无效的十六进制颜色值，必须是7位字符');
    }

    if (typeof opacity !== 'number' || opacity < 0 || opacity > 100) {
      throw new Error('透明度必须是0到100之间的数字');
    }

    // 转换为0-1范围的透明度值
    const alpha = opacity / 100;

    // 获取前景色的RGB值
    const rgbV = hexToRgb(hexColor.substring(1));

    // 背景色为纯白色
    const br = 255;
    const bg = 255;
    const bb = 255;

    // 计算混合后的RGB值
    // 混合公式: 结果 = 前景色 × 透明度 + 背景色 × (1 - 透明度)
    const r = rgbV.r * alpha + br * (1 - alpha);
    const g = rgbV.g * alpha + bg * (1 - alpha);
    const b = rgbV.b * alpha + bb * (1 - alpha);

    // 转换回十六进制并返回
    return `#${rgbToHex(r, g, b)}`;
  } catch (e) {
    hilog.error(DOMAIN, TAG, FORMAT, 'getColorWithOpacity fail, error: ' + JSON.stringify(e));
    return hexColor;
  }
}
