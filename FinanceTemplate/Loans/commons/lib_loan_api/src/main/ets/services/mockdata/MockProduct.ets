import { LoanProduct, LoanStatusEnum } from '../../database/ProductType';

export class MockProduct {
  static list: LoanProduct[] = [
    // 审核未通过
    {
      id: 'loan_004',
      name: '个人消费贷款',
      desc: '用于个人消费的信用贷款',
      loanAmount: 20000,
      annualInterestRate: 0.072, // 7.2%
      loanTerms: 12,
      repaymentMethod: '等额本息',
      paymentAccount: '招商银行 *** 1234',
      loanStatus: LoanStatusEnum.Rejected,
      createTime: '2025-08-15',
      reviewCompletedTime: '2025-08-16',
      loanTime: '',
      paidTerms: 1,
      repaidAmount: 1610.67,
      returnedAmount: 18388.33,
      interestAmount: 288.00,
      rejectReason: '身份证不清晰',
    }
  ]
  static  maxLoanAmount: number = 200000 //最高额度 20w
}