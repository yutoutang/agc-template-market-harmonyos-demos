import { PersistenceV2 } from '@kit.ArkUI';
import { BaseViewModel, PreferenceUtils, SettingModel } from 'lib_common';
import { LoanServiceApi } from 'lib_loan_api';

@ObservedV2
export class HomeViewModel extends BaseViewModel {
  @Trace settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;
  @Trace moneyEDu: number = 0 //首页顶部最高额度-同全局的最高可贷金额-由服务端获取
  loanPerDay: number = -1

  getHomeInterduceData() {
    LoanServiceApi.queryLoanMaxAmount().then((res: number) => {
      this.moneyEDu = res
      PreferenceUtils.getInstance().put('maxLoanAmount', res)
    })
    this.loanPerDay = 0.52
  }
}