import { CategoryItem } from '../../params/response/HomeConfigResponse';

export interface ConditionsItem {
  label: string;
  latestSearch: number; // 值
}


export class MockHomeConfig {
  static readonly evaluationItem: ConditionsItem[] =
    [{ label: '5星好评', latestSearch: 5 }, { label: '4星以上', latestSearch: 4 }]
  static readonly salesVolumeItem: ConditionsItem[] =
    [{ label: '月销1000+', latestSearch: 1000 }, { label: '月销500+', latestSearch: 500 },
      { label: '月销100+', latestSearch: 100 }]
  static readonly deliveryTimeItem: ConditionsItem[] =
    [{ label: '30分钟内', latestSearch: 30 }, { label: '40分钟内', latestSearch: 40 },
      { label: '50分钟内', latestSearch: 50 }]
  static readonly categoryBarList: CategoryItem[] = [
    {
      id: '0',
      label: '地方菜系',
      iconUrl: $r('app.media.ic_category1'),
    },
    {
      id: '1',
      label: '汉堡披萨',
      iconUrl: $r('app.media.ic_category2'),
    },
    {
      id: '2',
      label: '甜食饮品',
      iconUrl: $r('app.media.ic_category3'),
    },
    {
      id: '3',
      label: '快食简餐',
      iconUrl: $r('app.media.ic_category4'),
    }
  ];
}

