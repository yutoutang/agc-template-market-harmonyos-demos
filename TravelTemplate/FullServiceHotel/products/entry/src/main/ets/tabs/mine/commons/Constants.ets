import { MineOperationType, MineOperationItem } from './Types';

export const MINE_PAGE_SETTING: MineOperationItem[] = [
  {
    icon: $r('app.media.ic_my_order'),
    label: '我的订单',
    url: '',
    type: MineOperationType.MY_ORDERS,
  },
  {
    icon: $r('app.media.ic_setting'),
    label: '设置',
    url: '',
    type: MineOperationType.SETTINGS,
  },
]

export enum EditDialogType {
  NAME,
  NICKNAME,
  PHONE,
}

export enum Gender {
  MALE = '1',
  FEMALE = '2',
}
