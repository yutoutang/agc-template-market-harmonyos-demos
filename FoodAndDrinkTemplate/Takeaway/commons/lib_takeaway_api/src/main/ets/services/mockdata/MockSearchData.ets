import { HotSearchItem } from '../../params/response/SearchResponse';

export class SearchMockData {
  // 热搜数据
  static hotSearchList: HotSearchItem[] = [
    { label: '一碗小饭', hotRate: 125 },
    { label: '深夜食档', hotRate: 118 },
    { label: '元气盒饭', hotRate: 98 },
    { label: '日式料理', hotRate: 21 }
  ];
}