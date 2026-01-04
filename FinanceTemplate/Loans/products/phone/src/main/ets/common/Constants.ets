import { RouterMap } from 'lib_common';

export interface TabBarItem {
  id: TabBarType;
  title: ResourceStr;
  activeIcon: ResourceStr;
  selectIcon: ResourceStr;
  unselectIcon: ResourceStr;
}

export enum TabBarType {
  HOME = 0,
  MINE
}

export const TABS_INFO: TabBarItem[] = [
  {
    id: TabBarType.HOME,
    title: '首页',
    activeIcon: $r('app.media.ic_home'),
    selectIcon:$r('app.media.home_selected'),
    unselectIcon:$r('app.media.home_unselected')
  },
  {
    id: TabBarType.MINE,
    title: '我的',
    activeIcon: $r('app.media.ic_my'),
    selectIcon:$r('app.media.mine_selected'),
    unselectIcon:$r('app.media.mine_unselected')
  },
]

/**
 * 依赖登录的页面
 */
export const REQUIRE_LOGIN_PAGE_LIST: RouterMap[] = [
  RouterMap.MINE_COMMENT_PAGE,
];

export const agreePrivacyKey: string = 'isAgreePrivacy';
