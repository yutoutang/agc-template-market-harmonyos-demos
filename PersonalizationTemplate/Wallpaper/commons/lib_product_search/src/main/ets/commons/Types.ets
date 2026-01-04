export interface HistorySearchItem {
  label: string;
  latestSearch: number; // 时间戳
}

export interface HotSearchItem {
  label: string;
  hotRate: number;
}

// 搜索页面参数
export interface SearchPageParams {
  initialKeyword: string;
  fromCarousel?: boolean;
}

// 搜索结果接口
export interface SearchResultItem {
  id: string;
  title: string;
  url: string;
  type: string;
  userAvatar: string;
  userName: string;
  hotValue: number;
  time: number;
  keywords: string;
  like: boolean;
}