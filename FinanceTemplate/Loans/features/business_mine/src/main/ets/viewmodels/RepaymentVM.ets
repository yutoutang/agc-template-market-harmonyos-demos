import { BaseViewModel } from 'lib_common';
import { LoanServiceApi, RepaymentSchedule, LoanProduct } from 'lib_loan_api';

@ObservedV2
export class RepaymentViewModel extends BaseViewModel {
  @Trace loanRecordList: LoanProduct [] = []
  @Trace loanWaitPayList: RepaymentSchedule [][] = []
  @Trace rePayment: RepaymentSchedule[] = []

  // 获取全部数据
  init() {
    this.getWaitReturnList();
  }

  getList() {
    LoanServiceApi.queryLoan().then((loanRecordList: LoanProduct[]) => {
      this.loanRecordList = loanRecordList.filter(
        (loan: LoanProduct) => loan.loanStatus === 3
      );
    });
  }

  getWaitReturnList() {
    LoanServiceApi.queryRecordLoan().then((loanRecordList: RepaymentSchedule [][]) => {
      this.loanWaitPayList = loanRecordList
    })
  }

  getRepaymentSchedule(loadId: string) {
    LoanServiceApi.queryRepaymentSchedule(loadId).then((repayment: RepaymentSchedule[]) => {
      this.rePayment = repayment;
    });
  }

  //还款 某一期
  repayment(loadId: string, term: number, callback: () => void) {
    LoanServiceApi.repayment(loadId, term, callback)
  }
}