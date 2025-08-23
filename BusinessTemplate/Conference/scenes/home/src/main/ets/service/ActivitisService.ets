import { http } from 'commons';
import { ActivityListItem } from '../viewModel/ActivitisModel';

interface activityListServiceResponse<T> {
  code?: number;
  content: T;
  desc?: string;
}

// 精彩活动
export function getActivityListJson() {
  return http.get<ActivityListItem[]>(`/activityList.json`)
}


