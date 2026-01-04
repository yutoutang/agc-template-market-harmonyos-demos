import { AsyncClass } from '../utils/AsyncUtils';
import { MockProduct } from './mockdata/MockProduct';
import { LoanProduct, RepaymentSchedule, LoanStatusEnum } from '../database/ProductType';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 贷款
 */
@AsyncClass
export class LoanService {
  // 存储定时器ID，用于清理（防止内存泄漏）
  private timers = new Map<string, number>();

  // 查询贷款最高额度
  public queryLoanMaxAmount(): Promise<number> {
    return new Promise((resolve) => {
      resolve(MockProduct.maxLoanAmount);
    })
  }

  // 查询全部贷款记录
  public queryLoan(): Promise<LoanProduct[]> {
    return new Promise((resolve) => {
      resolve(MockProduct.list);
      this.checkAndStartStatusFlow();
    });
  }

  // 查询全部待还款记录-已过滤已还款部分
  public queryRecordLoan(): Promise<RepaymentSchedule[][]> {
    return new Promise((resolve) => {
      let arrTemp: RepaymentSchedule[][] = []
      let arr: RepaymentSchedule[][] =
        MockProduct.list.filter(item => item.loanStatus === 3).map((loan: LoanProduct) => {
          return loan.repaymentSchedule!
        })
      arr.forEach(async (item: RepaymentSchedule[]) => {
        let arrItem = item.filter((schedule: RepaymentSchedule) => {
          return !schedule.isPaid
        })
        arrTemp.push(arrItem)
      })
      resolve(arrTemp);
    });
  }

  // 添加贷款记录
  public addLoad(loadItem: LoanProduct) {
    MockProduct.list.unshift(loadItem);
    this.checkAndStartStatusFlow();
  }

  // 清理定时器（页面销毁时调用）
  public clearTimers() {
    this.timers.forEach(timerId => clearTimeout(timerId));
    this.timers.clear();
  }

  //为刚审核通过并放款的贷款记录生成还款计划-假定还款日为每月10日
  public generateRepaymentSchedule(loanId: string): Promise<RepaymentSchedule[]> {
    let schedule: RepaymentSchedule[] = []
    const loanIndex = MockProduct.list.findIndex(loan => loan.id === loanId);
    if (loanIndex !== -1) {
      for (let index = 0; index < 12; index++) {
        // 计算每个月的还款日（每月10日）-从下个月开始
        const currentDate = new Date();
        const year = currentDate.getFullYear();
        const month = currentDate.getMonth() + 1 + index; // 自动处理跨年
        // 创建目标月份的10号日期对象
        const dueDateObj = new Date(year, month, 10);
        // 格式化日期为 YYYY-MM-DD 格式
        const dueDateStr =
          `${dueDateObj.getFullYear()}-${(dueDateObj.getMonth() + 1).toString().padStart(2, '0')}-${dueDateObj.getDate()
            .toString()
            .padStart(2, '0')}`;

        let principal = MockProduct.list[loanIndex].loanAmount / 12
        let annualInterestRateItem = MockProduct.list[loanIndex].annualInterestRate / 12

        let element: RepaymentSchedule = {
          term: index + 1,
          dueDate: dueDateStr,
          principal: principal,
          interest: principal * annualInterestRateItem,
          total: principal + (principal * annualInterestRateItem),
          remainingPrincipal: MockProduct.list[loanIndex].loanAmount - principal * index,
          isPaid: false,
          loanAmount: MockProduct.list[loanIndex].loanAmount,
          totalTerms: MockProduct.list[loanIndex].loanTerms,
          loadId: loanId,
          paidTerms: 0, //此处为mock自由流转数据状态，从审核到放款，未进行归还所以已还款期数统一为0
        }
        schedule.push(element)
      }
    }
    hilog.info(0, `生成贷款 ${loanId} 的还款计划成功`, JSON.stringify(schedule))
    return new Promise((resolve) => {
      resolve(schedule);
    });
  }

  //根据loanId查询贷款待还款计划
  public async queryRepaymentSchedule(loanId: string): Promise<RepaymentSchedule[]> {
    let schedule: RepaymentSchedule[] = []
    const index = MockProduct.list.findIndex(loan => loan.id === loanId);
    if (index !== -1) {
      schedule = MockProduct.list[index]!.repaymentSchedule!.filter(scheduleItem => !scheduleItem.isPaid);
    }
    return new Promise((resolve) => {
      resolve(schedule);
    });
  }

  // 根据loanId和term进行还款，对应还款计划期数的isPaid字段设置为true
  public async repayment(loanId: string, term: number, callback: () => void) {
    const index = MockProduct.list.findIndex(loan => loan.id === loanId)
    if (index !== -1) {
      const schedule = MockProduct.list[index]!.repaymentSchedule!;
      const scheduleItem = schedule.find(scheduleItem => scheduleItem.term === term);
      if (scheduleItem) {
        let itemIndex = schedule.findIndex(scheduleItem => scheduleItem.term === term);
        scheduleItem.isPaid = true;
        scheduleItem.paidTerms = scheduleItem.paidTerms++
        scheduleItem.remainingPrincipal = scheduleItem.remainingPrincipal - scheduleItem.principal
        if (itemIndex !== -1) {
          MockProduct.list[index]!.repaymentSchedule![itemIndex] = scheduleItem
          MockProduct.list[index]!.paidTerms = (MockProduct.list[index]!.paidTerms as number) + 1
          MockProduct.list[index]!.repaidAmount! = MockProduct.list[index]!.repaidAmount! + scheduleItem.principal
          MockProduct.list[index]!.returnedAmount! =
            MockProduct.list[index].returnedAmount! - scheduleItem.principal
          MockProduct.list[index]!.interestAmount! = MockProduct.list[index].interestAmount! + scheduleItem.interest
          if (itemIndex === 11) {
            //说明上面处理的是最后一期，此时所有的期数都处理完毕，可以进行整条贷款记录的状态变为已结清
            MockProduct.list[index].loanStatus = LoanStatusEnum.Settled
          }
        }
        hilog.info(0, `贷款 ${loanId} 的第 ${term} 期已还款成功`,'');
        callback()
      }
    }
  }

  // 工具函数：格式化时间为 'YYYY-MM-DD HH:MM:SS'
  private formatTime(date: Date = new Date()): string {
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate()
      .toString()
      .padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes()
      .toString()
      .padStart(2, '0')}:${date.getSeconds().toString().padStart(2, '0')}`;
  }

  // 检查并启动状态自动流转
  private checkAndStartStatusFlow() {
    MockProduct.list.forEach((loan) => {
      if (this.timers.has(loan.id)) {
        return;
      }
      // 状态：审核中（0）→ 放款中（1）：记录审核完成时间和放款时间
      if (loan.loanStatus === 0) {
        const timerId = setTimeout(() => {
          // 生成当前时间作为审核完成时间和放款时间
          let date = new Date()
          this.updateLoanStatus(loan.id, 1, {
            reviewCompletedTime: date.getFullYear() + '-' +
            (date.getMonth() + 1).toString().padStart(2, '0') +
              '-' + date.getDate().toString().padStart(2, '0'), // 审核完成时间（状态流转时）
            loanTime: date.getFullYear() + '-' + (date.getMonth() + 1).toString().padStart(2, '0') + '-' +
            date.getDate().toString().padStart(2, '0') // 放款时间（状态流转时）
          });
          this.timers.delete(loan.id);
        }, 3000); // 3秒后流转（实际场景可改为30000即30秒）
        this.timers.set(loan.id, timerId);
      }

      // 状态：放款中（1）→ 还款中（3）
      else if (loan.loanStatus === 1) {
        const timerId = setTimeout(() => {
          this.updateLoanStatus(loan.id, 3);
          this.timers.delete(loan.id);
        }, 3000); // 3秒后流转
        this.timers.set(loan.id, timerId);
      }
    });
  }

  // 更新贷款状态（支持附加属性，如时间）
  private async updateLoanStatus(
    loanId: string,
    newStatus: number,
    extraProps: Partial<LoanProduct> = {}
  ) {
    const index = MockProduct.list.findIndex(loan => loan.id === loanId);
    if (index !== -1 && index < MockProduct.list.length) {
      const currentItem = MockProduct.list[index] as LoanProduct;
      let schedule: RepaymentSchedule[] = []
      if (currentItem) {
        if (newStatus === 3) {
          schedule = await this.generateRepaymentSchedule(currentItem.id)
        }
        setTimeout(() => {
          // 手动复制属性并更新状态和附加时间
          MockProduct.list[index] = {
            id: currentItem.id,
            name: currentItem.name,
            desc: currentItem.desc,
            loanAmount: currentItem.loanAmount,
            annualInterestRate: currentItem.annualInterestRate,
            loanTerms: currentItem.loanTerms,
            repaymentMethod: currentItem.repaymentMethod,
            paymentAccount: currentItem.paymentAccount,
            loanStatus: newStatus,
            createTime: currentItem.createTime.split('-')[0] + '-' +
            currentItem.createTime.split('-')[1].padStart(2, '0') + '-' +
            currentItem.createTime.split('-')[2].padStart(2, '0'),
            // 优先使用新传入的时间（状态流转时），否则保留原时间
            reviewCompletedTime: extraProps.reviewCompletedTime || currentItem.reviewCompletedTime,
            loanTime: extraProps.loanTime || currentItem.loanTime,
            paidTerms: currentItem.paidTerms??0,
            repaidAmount: currentItem.repaidAmount??0,
            returnedAmount: newStatus === 3 ? currentItem.loanAmount - (currentItem?.repaidAmount ?? 0) :
            (currentItem.returnedAmount??0),
            interestAmount: currentItem.interestAmount??0,
            repaymentRecord: newStatus === 3 ? [] : currentItem.repaymentRecord,
            repaymentSchedule: newStatus === 3 ? schedule : currentItem.repaymentSchedule
          };
          hilog.info(0,`贷款 ${loanId} 状态已更新为: `, JSON.stringify(schedule));
        }, 2000)
      }
    }
  }
}

const instance = new LoanService();

export { instance as LoanServiceApi };