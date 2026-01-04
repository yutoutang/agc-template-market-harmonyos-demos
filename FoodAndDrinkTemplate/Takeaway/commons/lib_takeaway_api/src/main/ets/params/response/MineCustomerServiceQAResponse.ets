/**
 * 客服QA内容-云侧接口响应模型
 */
export interface MineCustomerServiceQAResponse {
  // id
  id: string
  // 问题
  question: string
  // 创建时间
  createTime: number
  // 回答标题
  title: string
  // 图片
  image: Resource | string
  // 回答内容
  content: Resource | string
}
