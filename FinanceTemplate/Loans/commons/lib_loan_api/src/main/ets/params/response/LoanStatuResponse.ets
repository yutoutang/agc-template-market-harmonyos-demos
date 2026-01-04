

/**
 * 评论-云侧接口响应模型
 */

export enum LoanStatusResponse {
  // 审核中
  Auditing = 0,
  // 放款中
  Disbursing = 1,
  // 审核未通过
  Rejected = 2,
  // 还款中
  Repaying = 3,
  // 已结清
  Settled = 4,
}