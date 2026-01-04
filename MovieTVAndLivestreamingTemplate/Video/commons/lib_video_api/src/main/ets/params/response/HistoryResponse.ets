import { VideoResponse } from './VideoResponse'

/**
 * 播放历史-云侧接口响应模型
 */
export interface HistoryResponse {
  historyId: string
  videoId: string,
  videoInfo: VideoResponse
  url: ResourceStr
  sectionNo: number
  /**
   * 播放时间
   */
  playTime: number
  /**
   * 总时间
   */
  totalTime: number
  /**
   * 历史播放的时间
   */
  time: Date
}
