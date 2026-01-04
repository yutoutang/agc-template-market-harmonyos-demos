import { promptAction } from '@kit.ArkUI'

@ObservedV2
export class LoanFormVM {
  bankBrandList: string[] = []
  @Trace userRealName: string = ''
  @Trace idNumber: string = ''
  @Trace passPortNumber: string = '' //护照号
  @Trace bankAccountNumber: string = ''
  @Trace selectBankBrand: string = ''
  @Trace bankBrandIndex: number = 0
  @Trace isShowBankBrand: boolean = false
  @Trace maxLoanAmount: number = 0
  @Trace idType: string = ''
  @Trace isShowIdType: boolean = false
  @Trace idTypeIndex: number = 0
  idTypeList: string[] = []
  @Trace marryType: string = ''
  @Trace isShowMarryType: boolean = false
  @Trace marryTypeIndex: number = 0
  marryTypeList: string[] = []
  @Trace ensureType: string = ''
  @Trace isShowEnsureType: boolean = false
  @Trace ensureTypeIndex: number = 0
  ensureTypeList: string[] = []
  @Trace myLoanAmount: string = ''
  @Trace isConfirm: boolean | undefined = undefined
  @Trace isStartCheck: boolean | undefined = undefined
  @Trace isIdNumberOk: boolean | undefined = undefined
  @Trace isUserRealNameOk: boolean | undefined = undefined
  @Trace isPassPortNumberOk: boolean | undefined = undefined
  @Trace isMyLoanAmountOk: boolean | undefined = undefined
  @Trace isBankAccountNumberOk: boolean | undefined = undefined
  loanTerms: number = 12
  repaymentMethod: string = ''

  initLoanFormVm() {
    this.idTypeList = ['身份证', '护照']
    this.idType = this.idTypeList[0]
    this.idTypeIndex = 0
    this.marryTypeList = ['已婚', '未婚']
    this.marryType = this.marryTypeList[0]
    this.marryTypeIndex = 0

    this.ensureTypeList = ['信用贷款']
    this.ensureType = this.ensureTypeList[0]
    this.ensureTypeIndex = 0

    this.loanTerms = 12
    this.repaymentMethod = '等额本息'

    this.bankBrandList = ['**银行储蓄卡', '**中国银行储蓄卡', '**农业银行储蓄卡', '**建设银行储蓄卡']
  }

  CheckName(form: LoanFormVM) {
    let nameTest = form.userRealName.trim().match(/[\u3000-\u303F\uFF00-\uFFEF!"#%&'()*+,./:;<=>?@[\]^_`{|}~-]/g)
    if (nameTest) {
      promptAction.showToast({ message: '请输入正确内容后提交' })
      this.isUserRealNameOk = false
      return false
    } else {
      this.isUserRealNameOk = true
      return true
    }
  }

  checkCardId(form: LoanFormVM) {
    const passerCard = /^[1-9]\d{5}(18|19|20)\d{2}((0[1-9])|(1[0-2]))(([0-2][1-9])|10|20|30|31)\d{3}[0-9Xx]$/
    const passerCardflag = passerCard.test(form.idNumber!)
    if (!passerCardflag && form.idType === '身份证') {
      promptAction.showToast({
        message: '请输入正确内容后提交'
      })
      this.isIdNumberOk = false
      return false
    } else {
      this.isIdNumberOk = true
      return true
    }
  }

  checkPassId(form: LoanFormVM) {
    // 以下为常见护照的正则表达式，可根据业务护照的正则表达式修改
    const passerCard = /^[a-zA-Z][0-9]{7,8}$/;
    const passerCardflag = passerCard.test(form.passPortNumber!)
    if (!passerCardflag) {
      promptAction.showToast({
        message: '请输入正确内容后提交'
      })
      this.isPassPortNumberOk = false
      return false
    } else {
      this.isPassPortNumberOk = true
      return true
    }
  }

  checkMyLoanAmount(form: LoanFormVM) {
    if (form.myLoanAmount.trim() === '' || parseFloat(form.myLoanAmount.trim()) <= 1 ||
    form.myLoanAmount.trim().includes('.')) {
      promptAction.showToast({ message: '请输入正确金额内容后提交' })
      this.isMyLoanAmountOk = false
      return
    }
    if (parseFloat(form.myLoanAmount) > form.maxLoanAmount) {
      promptAction.showToast({ message: '贷款金额不能大于您的最高额度' + form.maxLoanAmount + '元' })
      this.isMyLoanAmountOk = false
      return
    }
    this.isMyLoanAmountOk = true
  }

  checkBankNumber(form: LoanFormVM) {
    const unionPayReg = /^62\d{14,17}$/; // 银联卡正则-其他校验规则由具体场景补充
    let isUnionCard = unionPayReg.test(form.bankAccountNumber.trim())
    if (!isUnionCard) {
      promptAction.showToast({ message: '请输入正确内容后提交' })
      this.isBankAccountNumberOk = false
      return false
    } else {
      this.isBankAccountNumberOk = true
      return true
    }
  }

  checkAll(form: LoanFormVM) {
    //独立管理各项的红线提示的显隐
    this.CheckName(form)
    this.checkCardId(form)
    this.checkPassId(form)
    this.checkMyLoanAmount(form)
    this.checkBankNumber(form)
  }

  confirmLordForm(form: LoanFormVM, callBack: (form: LoanFormVM) => void) {
    if (!form.isConfirm) {
      promptAction.showToast({ message: '请勾选确认填写信息的有效性' })
      return
    }
    this.isStartCheck = true
    this.checkAll(form)
    if (form.userRealName.trim() === '') {
      promptAction.showToast({ message: '请输入正确内容后提交' })
      return
    }
    let nameTest = form.userRealName.trim().match(/[\u3000-\u303F\uFF00-\uFFEF!"#%&'()*+,./:;<=>?@[\]^_`{|}~-]/g)
    if (nameTest) {
      promptAction.showToast({ message: '请输入正确内容后提交' })
      return
    }
    if (form.idType === '身份证') {
      const passerCard = /^[1-9]\d{5}(18|19|20)\d{2}((0[1-9])|(1[0-2]))(([0-2][1-9])|10|20|30|31)\d{3}[0-9Xx]$/
      const passerCardflag = passerCard.test(form.idNumber!)
      if (!passerCardflag) {
        promptAction.showToast({
          message: '请输入正确内容后提交'
        })
        return;
      }
    } else if (form.idType === '护照') {
      // 以下为常见护照的正则表达式，可根据业务护照的正则表达式修改
      const passerCard = /^[a-zA-Z][0-9]{7,8}$/
      const passerCardflag = passerCard.test(form.passPortNumber!)
      if (!passerCardflag) {
        promptAction.showToast({
          message: '请输入正确内容后提交'
        })
        return;
      }
    }
    if (form.myLoanAmount.trim() === '' || parseFloat(form.myLoanAmount.trim()) <= 1 ||
    form.myLoanAmount.trim().includes('.')) {
      promptAction.showToast({ message: '请输入正确内容后提交' })
      return
    }
    if (parseFloat(form.myLoanAmount) > form.maxLoanAmount) {
      promptAction.showToast({ message: '贷款金额不能大于您的最高额度' + form.maxLoanAmount + '元' })
      return
    }
    if (form.selectBankBrand.trim() === '') {
      promptAction.showToast({ message: '请输入正确内容后提交' })
      return
    }
    if (form.bankAccountNumber.trim() === '') {
      promptAction.showToast({ message: '请输入正确内容后提交' })
      return
    } else {
      const unionPayReg = /^62\d{14,17}$/; // 银联卡正则-其他校验规则由具体场景补充
      let isUnionCard = unionPayReg.test(form.bankAccountNumber.trim())
      if (!isUnionCard) {
        promptAction.showToast({ message: '请输入正确内容后提交' })
        return
      }
    }
    callBack(form)
  }
}