import { RouterMap } from 'lib_common';
import { MineGridItem } from '../types/Types';

export const mineGridList: MineGridItem[] = [
  {
    icon: $r('app.media.ic_grid_star'),
    label: '收藏记录',
    routerName: RouterMap.NEW_MINE_MARK_PAGE,
  },
  {
    icon: $r('app.media.ic_grid_like'),
    label: '上传记录',
    routerName: RouterMap.NEW_UPLOAD_RECORD,
  },
];

export class Constants {
  public static readonly NEWS_IMAGE_WIDTH: number = 96;
  public static readonly NEWS_IMAGE_HEIGHT: number = 72;
  public static readonly NORMAL_BTN_H: number = 40;
  public static readonly SMALL_BTN_W: number = 72;
  public static readonly SMALL_BTN_H: number = 28;
}
