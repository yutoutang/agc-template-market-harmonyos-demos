import { RouterMap } from 'lib_common';

export interface TabBarItem {
  id: TabBarType;
  title: ResourceStr;
  activeIcon: ResourceStr;
  selectActiveIcon: ResourceStr;
}

export enum TabBarType {
  HOME = 0,
  MESSGE,
  CART,
  MINE
}

export const TABS_INFO: TabBarItem[] = [
  {
    id: TabBarType.HOME,
    title: '首页',
    activeIcon: $r('app.media.ic_tab_home'),
    selectActiveIcon: $r('app.media.ic_tab_select_home'),
  },
  {
    id: TabBarType.MESSGE,
    title: '消息',
    activeIcon: $r('app.media.ic_tab_message'),
    selectActiveIcon: $r('app.media.ic_tab_select_message'),
  },
  {
    id: TabBarType.CART,
    title: '购物车',
    activeIcon: $r('app.media.ic_tab_cart'),
    selectActiveIcon: $r('app.media.ic_tab_select_cart'),
  },
  {
    id: TabBarType.MINE,
    title: '我的',
    activeIcon: $r('app.media.ic_tab_mine'),
    selectActiveIcon: $r('app.media.ic_tab_select_mine'),
  },
]

/**
 * 依赖登录的页面
 */
export const REQUIRE_LOGIN_PAGE_LIST: RouterMap[] = [
  RouterMap.FEEDBACK_PAGE,
  RouterMap.ORDER_LIST,
  RouterMap.CAR_PAGE,
];

export const agreePrivacyKey: string = 'isAgreePrivacy';
