import { RouterMap } from 'lib_common';
import { MineGridItem } from '../types/Types';

export const mineGridList: MineGridItem[] = [
  {
    icon: $r('app.media.my_collect'),
    label: '我的收藏',
    routerName: RouterMap.COLLECT_PAGE,
  },
];
