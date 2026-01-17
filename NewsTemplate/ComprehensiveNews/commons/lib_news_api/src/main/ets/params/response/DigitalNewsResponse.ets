/**
 * 数字报纸云侧接口模型，包含单页报纸信息
 */
export interface DigitalNewsResponse {
  // 版面id
  id: number
  // 版面图片
  newsImg: string
  // 版面名称
  newsName: string
  // 位置信息，格式: x1,y1,x2,y2,x3,y3,x4,y4,,newsUrl,,newsId,,newsTitle||...
  position: string
  // 图片宽度
  width: string
  // 图片高度
  height: string
  // 报纸id
  paperId: number
  // 报纸时间，格式: 年月日xxxx-xx-xx
  paperTime: string
}

/**
 * 报纸来源
 */
export interface DigitalNewsSource {
  // 来源id
  id: string
  // 来源名称
  name: string
}