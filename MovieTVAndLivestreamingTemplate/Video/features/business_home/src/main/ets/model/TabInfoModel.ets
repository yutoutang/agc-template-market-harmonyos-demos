import { TabType } from 'lib_video_api'

export interface TabInfo {
  id: TabType
  text: string
  selected: boolean
  icon: ResourceStr
  selectIcon: ResourceStr
}

export const channelList: TabInfo[] = [
  {
    text: '精选推荐',
    id: TabType.Recommend,
    selected: true,
    icon: $r('app.media.ic_Recommend'),
    selectIcon: $r('app.media.ic_select_Recommend'),
  },

  {
    text: '电视剧',
    id: TabType.TvMovie,
    selected: false,
    icon: $r('app.media.ic_tv'),
    selectIcon: $r('app.media.ic_select_TV'),
  },
  {
    text: '电影',
    id: TabType.Movie,
    selected: false,
    icon: $r('app.media.ic_movie'),
    selectIcon: $r('app.media.ic_select_Movie'),
  },
  {
    text: '少儿',
    id: TabType.Children,
    selected: false,
    icon: $r('app.media.ic_child'),
    selectIcon: $r('app.media.ic_select_child'),
  },
  {
    text: '全部',
    id: TabType.ALL,
    selected: false,
    icon: $r('app.media.ic_all'),
    selectIcon: $r('app.media.ic_select_all'),
  }
]


export interface FilterTab {
  id: string;
  text: string;
}


// 在 TabInfoModel.ts 文件末尾添加
export interface MorePageParams {
  title: string;
  currentIndex: number;
}