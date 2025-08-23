import { http, MyConfig } from 'commons';

export interface TaskCompleteParams {
  activityId: string
  token: string,
  taskId: string[] | number[],
  qrCode: string,
  hideToast?: boolean
}

interface TaskCompleteResult { //根据项目实际项目修改
  code: string,
  msg: string,
}

// 完成任务
export function completeTask(params: TaskCompleteParams) {
  return http.post<TaskCompleteResult>('/interactionplus/api/task/complete', params, {
    baseURL: MyConfig.PROJECTURL
  })
}



