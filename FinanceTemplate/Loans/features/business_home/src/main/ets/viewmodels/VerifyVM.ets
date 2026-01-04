import { promptAction } from '@kit.ArkUI';
import { BaseViewModel, CommonConfirmDialog, PreferenceUtils, RouterUtils } from 'lib_common';
import { IDCardInfo ,StepTypes } from 'module_card_verification';
import { LoanProduct, LoanServiceApi, LoanStatusEnum } from 'lib_loan_api';
import { LoanFormVM } from 'module_loan_form';

@ObservedV2
export class VerifyVM extends BaseViewModel {
  @Trace isDoneStep: boolean = false
  @Trace isIDCardDone: boolean = false
  @Trace isFaceDone: boolean = false
  @Trace fixedAnnualRate = 0.072;
  @Trace maxLoanAmount: number = PreferenceUtils.getInstance().get('maxLoanAmount', 0) as number
  @Trace cardPersonName: string = '' //用于身份证卡片识别后的人名传给人脸验证组件和填写资料组件
  @Trace cardPersonId: string = '' //用于身份证卡片识别后的人名传给人脸验证组件和填写资料组件

  stepList: StepTypes[] = [
    {
      title: '身份认证',
      indexStep: 0,
      isDone: false,
      stepIcon: $r('app.media.select_icon'),
      selectedStepIcon: $r('app.media.one_selected'),
      selectedIcon: $r('app.media.select_icon')
    },
    {
      title: '人脸验证',
      indexStep: 1,
      isDone: false,
      stepIcon: $r('app.media.two_unselected'),
      selectedStepIcon: $r('app.media.two_selected'),
      selectedIcon: $r('app.media.select_icon')
    },
    {
      title: '资料填写',
      indexStep: 2,
      isDone: false,
      stepIcon: $r('app.media.three_unselected'),
      selectedStepIcon: $r('app.media.select_icon'),
      selectedIcon: $r('app.media.select_icon')
    }
  ]

  VerifyNextFunc(cardInfo: IDCardInfo, callback: (isComplete: boolean) => void) {
    if (!cardInfo?.name) {
      promptAction.showToast({ message: '请填完成身份证照片的上传' })
      callback(false)
      return
    }
    if (!cardInfo?.address) {
      promptAction.showToast({ message: '请填完成身份证照片的上传' })
      callback(false)
      return
    }
    if (!cardInfo?.frontImageUri) {
      promptAction.showToast({ message: '请填完成身份证照片的上传' })
      callback(false)
      return
    }
    if (!cardInfo?.backImageUri) {
      promptAction.showToast({ message: '请填完成身份证照片的上传' })
      callback(false)
      return
    }
    if (!cardInfo?.idNumber) {
      promptAction.showToast({ message: '请填完成身份证照片的上传' })
      callback(false)
      return
    }
    const passerCard = /^[1-9]\d{5}(18|19|20)\d{2}((0[1-9])|(1[0-2]))(([0-2][1-9])|10|20|30|31)\d{3}[0-9Xx]$/
    const passerCardflag = passerCard.test(cardInfo.idNumber!)
    if (!passerCardflag && cardInfo.idNumber!.length !== 0) {
      promptAction.showToast({
        message: '证件号不正确或未正确识别，请重新上传身份证正面照片'
      })
      return;
    }
    //进行下一步
    callback(true)
  }

  BackConfirm() {
    CommonConfirmDialog.show({
      primaryTitle: '是否返回首页？',
      content: '将不会保留您此次编辑的内容',
      secBtnV: '返回',
      priBtnFg: 'rgba(0, 0, 0, 0.60)',
      secBtnFg: '#FF317AF7',
      confirm: () => {
        RouterUtils.pop()
      },
    });
  }

  async addLoadRecord(loanFormVMData: LoanFormVM, annualInterestRate: number) {
    let date = new Date()
    let loadItem: LoanProduct = {
      id: 'loan_099' + date.getTime(),
      name: loanFormVMData.userRealName,
      desc: '',
      loanAmount: parseFloat(loanFormVMData.myLoanAmount),
      annualInterestRate: annualInterestRate,
      loanTerms: loanFormVMData.loanTerms,
      repaymentMethod: loanFormVMData.repaymentMethod,
      paymentAccount: loanFormVMData.selectBankBrand + loanFormVMData.bankAccountNumber,
      loanStatus: LoanStatusEnum.Auditing,
      createTime: date.getFullYear() + '-' + (date.getMonth() + 1).toString().padStart(2, '0') + '-' +
      date.getDate().toString().padStart(2, '0'),
    }
    LoanServiceApi.addLoad(loadItem)
  }
}