import { http, MyConfig } from 'commons';
import { CateringArr, MyCatering, MyMap, MyMapArr, MyTrafficArr, MyTrafficItem } from '../viewModel/MyUniversalModel';


interface myUniversalServiceResponse<T> {
  code?: number;
  content: T;
  desc?: string;
}


// 大会地图
export function getMyMapJson() {
  return http.get<MyMap[]>(`/map.json`);
}

// 获取交通出行
export function getMyTrafficJson() {
  return http.get<MyTrafficItem[]>(`/traffic.json`);
}

// 获取大会餐饮
export function getMyCateringJson() {
  return http.get<MyCatering[]>(`/catering.json`);
}
