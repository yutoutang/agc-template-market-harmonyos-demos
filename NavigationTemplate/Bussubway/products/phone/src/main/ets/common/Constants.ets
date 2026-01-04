import { RouterMap } from 'lib_common';

export interface TabBarItem {
  id: TabBarType;
  title: ResourceStr;
  activeIcon: ResourceStr;
}

export enum TabBarType {
  HOME = 0,
  MAP = 1,
  MINE = 2
}

export const TABS_INFO: TabBarItem[] = [
  {
    id: TabBarType.HOME,
    title: '首页',
    activeIcon: $r('app.media.ic_home'),
  },
  {
    id: TabBarType.MAP,
    title: '地图',
    activeIcon: $r('app.media.ic_map'),
  },
  {
    id: TabBarType.MINE,
    title: '我的',
    activeIcon: $r('app.media.ic_my'),
  },
]

/**
 * 依赖登录的页面
 */
export const REQUIRE_LOGIN_PAGE_LIST: RouterMap[] = [
  RouterMap.MINE_COMMENT_PAGE,
  RouterMap.MINE_MARK_PAGE,
  RouterMap.MINE_LIKE_PAGE,
  RouterMap.FEEDBACK_PAGE,
  RouterMap.MINE_MSG_IM_CHAT,
];

export const agreePrivacyKey: string = 'isAgreePrivacy';

export const SOURCE_FORM_CARD: string = 'FormCard';

export const NEWS_DETAIL_PAGE: string = 'NewsDetailPage';
