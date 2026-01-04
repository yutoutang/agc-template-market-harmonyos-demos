import { RouterMap } from 'lib_common';
import { MineGridItem } from '../types/Types';

export const mineGridList: MineGridItem[] = [
  {
    icon: $r('app.media.ic_grid_loan'),
    label: '贷款记录',
    routerName: RouterMap.LOAN_RECORD_PAGE,

  },
  {
    icon: $r('app.media.ic_grid_repayment'),
    label: '我要还款',
    routerName: RouterMap.REPAYMENT_PAGE,
  },
];


