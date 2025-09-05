export class Constants {
  static readonly FULL_PERCENT: string = '100%';
  static readonly PADDING_S: number = 8;
  static readonly PADDING_L: number = 16;
  static readonly PADDING_PAGE: number = 16;
}

export interface IButtonItem {
  id: string;
  label: string;
}

export const BUTTON_LIST: IButtonItem[] = [
  { id: '1', label: '列表页' },
  { id: '2', label: '详情页' },
];

export enum FontSizeEnum {
  SMALL = 0.85,
  NORMAL = 1,
  LARGE = 1.15,
  XL = 1.45,
}

export interface FontSizeItem {
  id: number;
  value: FontSizeEnum,
  label: string;
}

export const FONT_SIZE_LIST: FontSizeItem[] = [
  {
    id: 0,
    value: FontSizeEnum.SMALL,
    label: '小'
  },
  {
    id: 1,
    value: FontSizeEnum.NORMAL,
    label: '标准'
  },
  {
    id: 2,
    value: FontSizeEnum.LARGE,
    label: '大'
  },
  {
    id: 3,
    value: FontSizeEnum.XL,
    label: '特大'
  },
];

export const GRID_MARGIN: GridRowColumnOption = {
  sm: 16,
  md: 24,
  lg: 32,
  xl: 32,
};