import { http } from '../utils/api';
import { MyConfig } from '../constants/MyConfig'
import { TagItem, TagObject } from '../viewModel/TagModel';
import { MyTag } from '../viewModel/MyTagList';
import { ApiResponse } from '../utils/api'

interface setTagParams {
  token: string | number;
  interestLabels: string;
}

interface DictTagResponse {
  result?: number;
  content: TagObject;
  desc?: string;
}

interface MyTagParams {
  token: string
}


// 获取当前人身上的tag
export function getMyTag(params: MyTagParams): Promise<ApiResponse<string>> {
  return http.post<string>(`/getMyLabel`, params, {
    baseURL: MyConfig.PROJECTURL
  })
}

// 获取标签列表
export function getDictTags(): Promise<ApiResponse<TagItem[]>> {
  return http.get<TagItem[]>(`/getInterestLabel.json`)
}

// 设置感兴趣的标签
export function setTags(params: setTagParams): Promise<ApiResponse<DictTagResponse>> {
  return http.post<DictTagResponse>(`/setInterestLabel`, params, {
    baseURL: MyConfig.PROJECTURL
  })
}
