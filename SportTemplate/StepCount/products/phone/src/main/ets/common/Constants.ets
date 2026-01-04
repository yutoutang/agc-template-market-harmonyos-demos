import { RouterMap } from 'lib_common';

export interface TabBarItem {
  id: TabBarType;
  title: ResourceStr;
  icon: ResourceStr;
  activeIcon: ResourceStr;
}

export enum TabBarType {
  HOME = 0,
  SPORT,
  MINE
}

export const TABS_INFO: TabBarItem[] = [
  {
    id: TabBarType.HOME,
    title: '首页',
    icon: $r('app.media.ic_tab_home'),
    activeIcon: $r('app.media.ic_tab_home_active'),
  },
  {
    id: TabBarType.SPORT,
    title: '运动',
    icon: $r('app.media.ic_tab_move'),
    activeIcon: $r('app.media.ic_tab_move_active'),
  },
  {
    id: TabBarType.MINE,
    title: '我的',
    icon: $r('app.media.ic_tab_mine'),
    activeIcon: $r('app.media.ic_tab_mine_active'),
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
  RouterMap.SETTING_NOTICE,
  RouterMap.SETTING_AUTO_SPORT_RECORD,

  RouterMap.STEP_COUNT_PAGE,
  RouterMap.STEP_DETAIL_PAGE,
  RouterMap.ALL_SPORT_RECORDS_PAGE,
  RouterMap.SPORT_RECORD_DETAIL_PAGE,
  RouterMap.EDIT_BMI_INFO,
  RouterMap.DRINK_PAGE// 添加BMI页面到需要登录的页面列表
];

export const agreePrivacyKey: string = 'isAgreePrivacy';

export const SOURCE_FORM_CARD: string = 'FormCard';

export const NEWS_DETAIL_PAGE: string = 'NewsDetailPage';
