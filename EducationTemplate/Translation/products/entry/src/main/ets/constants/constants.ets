import { TabSingleItem } from '../viewmodel/TabSingleItem';
import { TranslateHomePageBuilder } from 'home';
import { MinePage } from 'person';

@Builder
function minePageBuilder() {
  MinePage()
}

// Tab配置常量
export const TAB_CONFIG: TabSingleItem[] = [
  {
    label: $r('app.string.home'),
    index: 0,
    fontColor: '#99000000',
    fontColorActive: '#46B1E3',
    icon: $r('app.media.ic_public_home'),
    iconActive: $r('app.media.ic_public_home_filled'),
    component: wrapBuilder(TranslateHomePageBuilder),
  },
  {
    label: $r('app.string.person'),
    index: 1,
    fontColor: '#99000000',
    fontColorActive: '#46B1E3',
    icon: $r('app.media.ic_person'),
    iconActive: $r('app.media.ic_person_filled'),
    component: wrapBuilder(minePageBuilder),
  },
];
