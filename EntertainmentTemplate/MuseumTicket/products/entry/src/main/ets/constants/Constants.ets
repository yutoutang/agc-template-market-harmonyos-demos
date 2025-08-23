import { TabListItem } from '../types/Types';
import {HomePageBuilder} from 'home'
import {MyBookBuilder} from 'order'
import {MinePageBuilder} from 'mine'
export const TAB_LIST: TabListItem[] = [
  {
    label: '首页',
    icon: $r('app.media.icon_public_home'),
    iconChecked: $r('app.media.icon_public_home_checked'),
    component:wrapBuilder(HomePageBuilder)
  },
  {
    label: '我的预订',
    icon: $r('app.media.icon_my_order'),
    iconChecked: $r('app.media.icon_my_order_checked'),
    component:wrapBuilder(MyBookBuilder)
  },
  {
    label: '我的',
    icon: $r('app.media.icon_public_person'),
    iconChecked: $r('app.media.icon_public_person_checked'),
    component:wrapBuilder(MinePageBuilder)
  },
];