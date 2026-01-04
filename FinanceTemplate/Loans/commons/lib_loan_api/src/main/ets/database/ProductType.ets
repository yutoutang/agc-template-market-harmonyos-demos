/**
 * 贷款产品数据库字段
 */

export interface LoanProduct {
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
  loanTime?: string;

  //  已还期数
  paidTerms?: number;

  // 已还本金
  repaidAmount?: number;

  //   剩余代还本金
  returnedAmount?: number;
  // 审核失败原因
  rejectReason?: string;
  //   已还有息费
  interestAmount?: number;
  repaymentRecord?: RepaymentRecord[];
  repaymentSchedule?: RepaymentSchedule[];

}

@ObservedV2
export class LoanRecordLite {
  constructor(id: string, name: string, desc: string, createTime: string, rejectReason: string, loanAmount: number,
    loanStatus: LoanStatusEnum, returnedAmount: number) {
    this.id = id;
    this.name = name;
    this.desc = desc;
    this.createTime = createTime;
    this.rejectReason = rejectReason;
    this.loanAmount = loanAmount;
    this.loanStatus = loanStatus;
    this.returnedAmount = returnedAmount;
  }
  id?: string;
  name?: string;
  desc?: string;
  // 提交时间（格式化后，供页面展示）
  createTime?: string;
  // 审核失败原因
  @Trace rejectReason?: string;
  @Trace loanAmount?: number;
  // 审批状态
  @Trace loanStatus?: LoanStatusEnum;
  //   剩余代还本金
  @Trace returnedAmount?: number;
}
// 贷款状态枚举
export enum LoanStatusEnum {
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

/**
 * 还款记录数据模型
 */
export interface RepaymentRecord {
  // 还款记录ID
  id: string;

  // 关联的贷款产品ID
  loanProductId: string;

  // 还款期数 (如: 2/12 中的2)
  currentTerm: number;

  // 总期数
  totalTerms: number;

  // 应还本金
  duePrincipal: number;

  // 应还利息
  dueInterest: number;

  // 应还总额
  dueTotal: number;

  // 实际还款金额 (如果已还款)
  actualAmount?: number;

  // 还款截止日期
  dueDate: string;

  // 实际还款日期
  repaymentDate?: string;

  // 还款状态
  status: RepaymentStatusEnum;

  // 还款方式 (银行卡、支付宝、微信等)
  repaymentMethod?: string;

  // 还款账户
  repaymentAccount?: string;

  // 创建时间
  createTime: string;

  // 更新时间
  updateTime: string;

  // 是否逾期
  isOverdue: boolean;

  // 逾期天数 (如果逾期)
  overdueDays?: number;

  // 逾期费用
  overdueFee?: number;
  // 备注
  // 备注RepaymentRecord
  remark?: string;
  repaymentSchedule?: RepaymentSchedule[];
}

/**
 * 还款状态枚举
 */
export enum RepaymentStatusEnum {
  // 待还款
  Pending = 0,
  // 还款中 (处理中)
  Processing = 1,
  // 还款成功
  Success = 2,
  // 还款失败
  Failed = 3,
  // 部分还款
  Partial = 4,
  // 逾期
  Overdue = 5,
  // 已豁免
  Waived = 6,
}

/**
 * 还款计划数据模型 (用于生成还款记录)
 */
export interface RepaymentSchedule {
  // 期数
  term: number;

  //总期数
  totalTerms: number;

  // 已还期数
  paidTerms: number;

  // 应还日期
  dueDate: string;

  // 应还本金
  principal: number;

  // 应还利息
  interest: number;

  // 当期总额
  total: number;

  //当前产品贷款总额
  loanAmount: number;

  //产品ID
  loadId: string;

  // 剩余本金
  remainingPrincipal: number;

  // 是否已还
  isPaid: boolean;
}

/**
 * 还款请求参数
 */
export interface RepaymentRequest {
  // 贷款产品ID
  loanProductId: string;

  // 还款期数
  termNumber: number;

  // 还款金额
  amount: number;

  // 还款方式
  repaymentMethod: string;

  // 还款账户
  repaymentAccount: string;

  // 支付密码/验证码
  paymentToken: string;
}

/**
 * 还款响应结果
 */
export interface RepaymentResponse {
  // 还款记录ID
  repaymentId: string;

  // 还款状态
  status: RepaymentStatusEnum;

  // 交易流水号
  transactionNo: string;

  // 还款完成时间
  completedTime?: string;

  // 错误信息 (如果失败)
  errorMessage?: string;
}

