import { AppointState, RouterMap } from 'foundation';

// 订单状态
export interface ITabMenu {
  type: string;
  label: string;
}

export const TAB_MENUS: ITabMenu[] = [
  {
    type: 'total',
    label: '全部',
  },
  {
    type: 'toPay',
    label: '待支付',
  },
  {
    type: 'toUse',
    label: '待使用',
  },
  {
    type: 'finished',
    label: '已完成',
  },
  {
    type: 'refund',
    label: '退款/售后',
  },
];

// 图文类型
export interface MineIconLabelItem {
  icon: ResourceStr
  label: ResourceStr
  routeUrl: RouterMap | string,
  routeParam: Object | undefined
  iconSize?: SizeOptions
}

// 我的预约
export const APPOINTMENT_MENUS: MineIconLabelItem[] = [
  {
    icon: $r('app.media.ic_bar_appointed'),
    label: '已预约',
    routeUrl: RouterMap.MY_APPOINTMENT_LIST,
    routeParam: AppointState.NEW,
  },
  {
    icon: $r('app.media.ic_bar_appoint_done'),
    label: '已完成',
    routeUrl: RouterMap.MY_APPOINTMENT_LIST,
    routeParam: AppointState.FINISH,
  },
  {
    icon: $r('app.media.ic_bar_appoint_cancel'),
    label: '已取消',
    routeUrl: RouterMap.MY_APPOINTMENT_LIST,
    routeParam: AppointState.CANCEL,
  },
  {
    icon: $r('app.media.ic_bar_appoint_expired'),
    label: '已失效',
    routeUrl: RouterMap.MY_APPOINTMENT_LIST,
    routeParam: AppointState.OVER_TIME,
  }
]

// 页面状态
export enum LoadingStatus {
  OFF = 'off',
  EMPTY = 'empty',
  LOADING = 'loading',
  SUCCESS = 'success',
  FAILED = 'failed'
}