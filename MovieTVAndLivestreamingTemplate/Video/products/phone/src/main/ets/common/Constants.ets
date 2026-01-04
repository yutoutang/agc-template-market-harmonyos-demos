import { RouterMap } from 'lib_common';

export interface TabBarItem {
  id: TabBarType;
  title: ResourceStr;
  activeIcon: ResourceStr;
  selectIcon: ResourceStr;
}

export enum TabBarType {
  HOME = 0,
  MINE
}

export const TABS_INFO: TabBarItem[] = [
  {
    id: TabBarType.HOME,
    title: '首页',
    activeIcon: $r('app.media.ic_tab_home'),
    selectIcon: $r('app.media.tab_home'),
  },
  {
    id: TabBarType.MINE,
    title: '我的',
    activeIcon: $r('app.media.ic_tab_mine'),
    selectIcon: $r('app.media.face_smiling'),
  },
]

/**
 * 依赖登录的页面
 */
export const REQUIRE_LOGIN_PAGE_LIST: RouterMap[] = [
  RouterMap.MINE_MARK_PAGE,
  RouterMap.MINE_LIKE_PAGE,
  RouterMap.FEEDBACK_PAGE,
  RouterMap.MINE_MSG_IM_CHAT,
  RouterMap.MINE_MSG_IM_CHAT,
];

export const agreePrivacyKey: string = 'isAgreePrivacy';

export const SOURCE_FORM_CARD: string = 'FormCard';

export const NEWS_DETAIL_PAGE: string = 'NewsDetailPage';

export const DOWNLOAD_TASK_LIST: string = 'DownloadTaskList';

