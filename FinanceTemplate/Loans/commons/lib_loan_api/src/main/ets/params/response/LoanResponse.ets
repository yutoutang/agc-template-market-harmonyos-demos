import { LoanStatusEnum, RepaymentRecord, RepaymentSchedule } from '../../database/ProductType'

export interface LoanResponse {
  id: string;
  name: string;
  desc: string;
  // 贷款金额
  loanAmount: number;

  // 贷款年利率
  annualInterestRate: number;

  // 贷款期数
  loanTerms: number;

  // 还款方式
  repaymentMethod: string;

  // 收款账户
  paymentAccount: string;

  // 审批状态
  loanStatus: LoanStatusEnum;

  // 提交时间（格式化后，供页面展示）
  createTime: string;

  // 审核完成时间
  reviewCompletedTime?: string;

  // 放款时间
  loanTime: string;

  //  已还期数
  paidTerms?: number;

  // 已还本金
  repaidAmount?: number;

  //   代还本金
  returnedAmount?: number;

  //   已还有息费
  interestAmount?: number;
  repaymentRecord?: RepaymentRecord[];
  repaymentSchedule?: RepaymentSchedule[];

}