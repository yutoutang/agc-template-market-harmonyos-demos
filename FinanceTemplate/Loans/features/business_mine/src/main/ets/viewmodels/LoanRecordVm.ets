import { BaseViewModel } from 'lib_common';
import { LoanRecordLite, LoanServiceApi } from 'lib_loan_api';
import { LoanProduct } from 'lib_loan_api';

@ObservedV2
export class LoanViewModel extends BaseViewModel {
  @Trace loanRecordList: LoanProduct[] = [];
  @Trace loanRecordListLite: LoanRecordLite[] = [];
  @Trace loanDetailsList: LoanProduct | null = null;
  // 存储定时器ID，用于页面销毁时清理
  private refreshTimer: number | null = null;

  // 初始化时启动定时刷新
  init() {
    this.getList(); // 首次加载
    this.startRefreshTimer(); // 启动定时任务
  }

  // 获取贷款列表
  getList() {
    LoanServiceApi.queryLoan().then((loanRecordList: LoanProduct[]) => {
      this.loanRecordList = loanRecordList;
      this.loanRecordListLite = this.loanRecordList.map(loanRecord => {
        return new LoanRecordLite(
          loanRecord.id,
          loanRecord.name,
          loanRecord.desc,
          loanRecord.createTime,
          loanRecord.rejectReason ?? '',
          loanRecord.loanAmount,
          loanRecord.loanStatus,
          loanRecord.returnedAmount ?? 0
        )
      });
    })
  }

  getLoanDetailByLoanId(loanId: string, callBack: (loan: LoanProduct) => void) {
    LoanServiceApi.queryLoan().then((loanRecordList) => {
      let detail: LoanProduct = loanRecordList.find(loanRecord => loanRecord.id === loanId) as LoanProduct
      callBack(detail)
    })
  }

  // 清理定时器（页面销毁时调用，防止内存泄漏）
  clearRefreshTimer() {
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer);
      this.refreshTimer = null;
    }
  }

  getStatusName(loanStatus: number) {
    if (loanStatus === 0) {
      return '审核中';
    } else if (loanStatus === 1) {
      return '放款中';
    } else if (loanStatus === 2) {
      return '审核未通过';
    } else if (loanStatus === 3) {
      return '还款中';
    } else {
      return '已结清';
    }
  }

  getBackImg(loanDetailsList: LoanProduct | null) {
    if (loanDetailsList === null) {
      return ''
    } else if (loanDetailsList.loanStatus === 0) {
      return $r('app.media.ic_bg_image');
    } else if (loanDetailsList.loanStatus === 1) {
      return $r('app.media.ic_bg_disbursement');
    } else if (loanDetailsList.loanStatus === 2) {
      return $r('app.media.ic_bg_none');
    } else if (loanDetailsList.loanStatus === 3) {
      return $r('app.media.ic_bg_loaning');
    } else {
      return $r('app.media.ic_bg_over');
    }
  }

  // 启动5秒一次的定时刷新
  private startRefreshTimer() {
    // 避免重复创建定时器
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer);
    }
    // 每5000毫秒（5秒）调用一次getList
    this.refreshTimer = setInterval(() => {
      this.getList();
    }, 5000);
  }
}