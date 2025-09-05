import { GRID_MARGIN } from './Constants';

/**
 * 获取页面边距
 */
export const getPageMargin = (bp: string): number => {
  return Reflect.get(GRID_MARGIN, bp);
}