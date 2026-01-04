import { RouterMap } from 'lib_common';
import { IMineMsgMenuItem, MineGridItem, MineMsgMenuType } from '../types/Types';

export const mineGridList: MineGridItem[] = [

  {
    icon: $r('app.media.my_list'),
    label: '播放历史',
    routerName: RouterMap.MINE_HISTORY_PAGE,
  },
  {
    icon: $r('app.media.my_celect'),
    label: '我的收藏',
    routerName: RouterMap.MINE_MARK_PAGE,
  },
  {
    icon: $r('app.media.my_Cache'),
    label: '我的缓存',
    routerName: RouterMap.MINE_CACHE_PAGE,
  },
  {
    icon: $r('app.media.my_Invoicing'),
    label: '我的点赞',
    routerName: RouterMap.MINE_LIKE_PAGE,
  },
];

/**
 * 离线WebID映射表
 */
export enum WebIdMap {
  ChatWebId = 'webId1',
}

export class Constants {
  public static readonly NEWS_IMAGE_WIDTH: number = 96;
  public static readonly NEWS_IMAGE_HEIGHT: number = 72;
  public static readonly NORMAL_BTN_H: number = 40;
  public static readonly SMALL_BTN_W: number = 72;
  public static readonly SMALL_BTN_H: number = 28;
}
