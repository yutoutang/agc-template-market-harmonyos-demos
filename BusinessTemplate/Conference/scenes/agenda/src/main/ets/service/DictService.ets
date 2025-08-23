import { http, ApiResponse } from 'commons';
import { DictListItem } from '../viewModel/DistListModel';

// 会议地点 获取会议少选 字典集合
export function getMyAgendaFilterDictList(): Promise<ApiResponse<DictListItem[]>> {
  return http.get<DictListItem[]>(`/filter_label.json`,)
}
