import { Notice } from '../../types/Notice';

const noticeList: Notice[] = [
  {
    id: 1,
    icon: 'ic_notice',
    type: 1,
    title: '热门活动',
    subTitle: '端午佳节 网红博主送惊喜！',
    uri: '',
    time: new Date().getTime() - 180000,
  },
  {
    id: 2,
    icon: 'avatar1',
    type: 2,
    title: '懒洋洋',
    subTitle: '我更新了新的菜谱，快来学习吧~',
    uri: '2',
    time: new Date().getTime() - 3600000,
  },
  {
    id: 3,
    icon: 'avatar1',
    type: 2,
    title: '懒洋洋',
    subTitle: '我更新了新的菜谱，快来学习吧~',
    uri: '3',
    time: new Date().getTime() - 3600000,
  },
]

export const getNoticeList = () => {
  return noticeList;
};
