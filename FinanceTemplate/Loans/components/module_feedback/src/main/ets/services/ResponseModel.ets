export interface FeedbackResponseParams {
  id: string
  createTime: number
  problemDesc: string
  screenShots: ResourceStr[]
  contactPhone?: string
}