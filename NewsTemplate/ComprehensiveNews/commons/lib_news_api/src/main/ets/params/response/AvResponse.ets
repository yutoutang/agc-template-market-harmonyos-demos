import { NewsEnum } from '../../constants/Constants';
import { NavInfo } from '../base/BaseModel';

/**
 * 音视频内容-云侧接口响应模型
 */
export interface AvResponse {
  id: string
  type: NewsEnum
  title: string
  description: string
  isFollow: boolean
  coverUrl: string
  total: number
  section: AvSectionModel[]
  // 动态布局参数
  navInfo?: NavInfo
}

/**
 * 视频节目单-云侧接口响应模型
 */
export interface VideoProgramResponse {
  programId: string
  title: string
  duration: number,
  updateTime: string
  isEnd: boolean
}

/**
 * 公众号-云侧接口响应模型
 */
export interface SubscribeResponse {
  subscribeName: string
  subscribeId: string
  subscribeDesc: string
  subscribeIcon: string
  subscribeWorks: string[]
}

export interface AvSectionModel {
  id: string
  title: string
  duration: number
  updateTime: string
  sectionUrl: string
  coverUrl: string
  needVip: boolean
}