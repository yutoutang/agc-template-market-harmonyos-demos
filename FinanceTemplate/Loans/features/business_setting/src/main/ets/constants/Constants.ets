import { RouterMap } from 'lib_common';
import { MineGridItem } from '../types/Types';

export const mineGridList: MineGridItem[] = [
  {
    icon: $r('app.media.feedback_page'),
    label: '意见反馈',
    routerName: RouterMap.FEEDBACK_PAGE,
  },
  {
    icon: $r('app.media.fraud_report_page'),
    label: '诈骗举报',
    routerName: RouterMap.FRAUD_REPORT_PAGE,
  },
  {
    icon: $r('app.media.customer_service'),
    label: '在线客服',
    routerName: RouterMap.CUSTOMER_SERVICE,
  },
  {
    icon: $r('app.media.phone_service'),
    label: '电话客服',
    routerName: RouterMap.CUSTOMER_SERVICE,
  },
];

export class Constants {
  public static readonly NEWS_IMAGE_WIDTH: number = 96;
  public static readonly NEWS_IMAGE_HEIGHT: number = 72;
  public static readonly NORMAL_BTN_H: number = 40;
  public static readonly SMALL_BTN_W: number = 72;
  public static readonly SMALL_BTN_H: number = 28;
  static readonly MAX_IMG_COUNT: number = 5;
  static readonly FULL_PERCENT: string = '100%';
  static readonly HALF_PERCENT: string = '50%';
  static readonly TITLE_HEIGHT: number = 56;
  static readonly TITLE_ICON_WIDTH: number = 40;
  static readonly ICON_WIDTH: number = 24;
  static readonly SPACE_8: number = 8;
  static readonly SPACE_12: number = 12;
  static readonly PADDING_PAGE: number = 16;
  static readonly PADDING_XS: number = 4;
  static readonly PADDING_S: number = 8;
  static readonly PADDING_M: number = 12;
  static readonly PADDING_L: number = 16;
  static readonly RADIUS_16: number = 16;
  static readonly BTN_HEIGHT: number = 40;
  static readonly TEXT_INPUT_HEIGHT: number = 48;
}
