import { BookListPageBuilder } from 'book_home';
import { PersonPageBuilder } from 'book_person';
import { BookShelfPageBuilder } from 'book_shelf';
import { BookSortPageBuilder } from 'book_sort';
import { Constants, TabInfo } from 'common';

export class IndexData {
  public static MAIN_TAB: TabInfo[] = [
    {
      index: Constants.TAB_INDEX_ZERO,
      label: '书架',
      activeIcon: $r('app.media.shelf_tab_active'),
      defaultIcon: $r('app.media.shelf_tab'),
      component: wrapBuilder(BookShelfPageBuilder)
    },
    {
      index: Constants.TAB_INDEX_ONE,
      label: '书城',
      activeIcon: $r('app.media.mall_tab_active'),
      defaultIcon: $r('app.media.mall_tab'),
      component: wrapBuilder(BookListPageBuilder)
    },
    {
      index: Constants.TAB_INDEX_TWO,
      label: '分类',
      activeIcon: $r('app.media.sort_tab_active'),
      defaultIcon: $r('app.media.sort_tab'),
      component: wrapBuilder(BookSortPageBuilder)
    },
    {
      index: Constants.TAB_INDEX_THREE,
      label: '我的',
      activeIcon: $r('app.media.person_tab_active'),
      defaultIcon: $r('app.media.person_tab'),
      component: wrapBuilder(PersonPageBuilder)
    },
  ]
}