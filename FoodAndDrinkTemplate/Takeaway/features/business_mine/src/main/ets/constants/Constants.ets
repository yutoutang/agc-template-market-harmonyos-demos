import { RouterMap } from 'lib_common';
import { MineGridItem } from '../types/Types';

export const orderGridList: MineGridItem[] = [
  {
    icon: $r('app.media.ic_order_all'),
    label: '全部订单',
    routerName: RouterMap.ORDER_LIST,
  },
  {
    icon: $r('app.media.ic_order_dfk'),
    label: '待付款',
    routerName: RouterMap.ORDER_LIST,
  },
  {
    icon: $r('app.media.ic_order_jxz'),
    label: '进行中',
    routerName: RouterMap.ORDER_LIST,
  },
  {
    icon: $r('app.media.ic_order_pj'),
    label: '已完成',
    routerName: RouterMap.ORDER_LIST,
  },
  {
    icon: $r('app.media.ic_order_sh'),
    label: '退款/售后',
    routerName: RouterMap.ORDER_LIST,
  },
];

export const mineGridList: MineGridItem[] = [
  {
    icon: $r('app.media.ic_grid_gz'),
    label: '我的关注',
    routerName: RouterMap.MINE_FOLLOW_PAGE,
  },
  {
    icon: $r('app.media.ic_grid_jl'),
    label: '浏览记录',
    routerName: RouterMap.MINE_BROWSING_HISTORY_PAGE,
  },
  {
    icon: $r('app.media.ic_grid_kj'),
    label: '红包卡卷',
    routerName: RouterMap.MINE_COUPONS_PAGE,
  },
  {
    icon: $r('app.media.ic_grid_dz'),
    label: '我的地址',
    routerName: RouterMap.ADDRESS_PAGE,
  },
];

export class Constants {
  public static readonly NEWS_IMAGE_WIDTH: number = 96;
  public static readonly NEWS_IMAGE_HEIGHT: number = 72;
  public static readonly NORMAL_BTN_H: number = 40;
  public static readonly SMALL_BTN_W: number = 72;
  public static readonly SMALL_BTN_H: number = 28;
}
