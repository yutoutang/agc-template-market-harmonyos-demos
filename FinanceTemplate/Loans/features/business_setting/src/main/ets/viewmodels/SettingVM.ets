import { promptAction } from '@kit.ArkUI';
import { BaseViewModel, RouterMap, RouterUtils } from 'lib_common';
import { AccountApi } from 'lib_account';
import { LoanProduct, LoanServiceApi, LoanStatusEnum } from 'lib_loan_api';

@ObservedV2
export class SettingViewModel extends BaseViewModel {
  @Trace isLoading: boolean = false;
  @Trace cacheSize: string = '10';
  @Trace location: string = '/storage/emulated/0/Download/Music/'
  @Trace teenagers: string = this.settingInfo.teenagersSwitch ? '已开启' : '未开启'
  @Trace oldPhone: string = ''; // 旧手机号
  @Trace newPhone: string = ''; // 新手机号
  @Trace newPassword: string = ''; // 旧手机号
  @Trace surePassword: string = ''; // 新手机号
  @Trace verifyCode: string = ''; // 验证码
  @Trace verifyCodeTime: number = 60; // 验证码
  timerID: number | null = null
  @Trace codeBtnDisabled: boolean = false; // “获取验证码”按钮是否禁用
  @Trace codeBtnText: string = '获取验证码'; // “获取验证码”按钮文字

  private accountInstance: AccountApi = new AccountApi();

  isPhoneNumberValid(phoneNumber: string): boolean {
    if (!phoneNumber) {
      return false;
    }
    // 正则表达式：以1开头，第二位是3-9，后面跟9位数字
    const phoneRegex = /^1[3-9]\d{9}$/;
    return phoneRegex.test(phoneNumber);
  }

  isFormComplete(verifyOldPhone: boolean = true): boolean {
    // 简单校验：判断三个字段是否都有值（可根据实际需求添加格式校验）
    if (verifyOldPhone) {
      return this.oldPhone.trim() !== '' &&
        this.verifyCode.trim() !== '';
    } else {
      return this.newPhone.trim() !== '' &&
        this.verifyCode.trim() !== '';
    }
  }

  isConfirmComplete(): boolean {
    // 简单校验：判断三个字段是否都有值（可根据实际需求添加格式校验）
    return this.oldPhone.trim() !== '' &&
      this.verifyCode.trim() !== ''
  }

  // 添加获取手机号的方法
  getLoginPhoneNumber() {
    // 假设用户信息中包含手机号，根据实际数据结构调整
    if (this.userInfoModel && this.userInfoModel.authorPhone) {
      // 如果有手机号则显示，否则显示'未设置'
      this.oldPhone = '';
      return this.userInfoModel.authorPhone || '未设置';
    }
    return '未登录';
  }

  // 在 SettingViewModel 类中添加
  changeLoginPhone(oldPhone: string, verifyCode: string) {
    if (!oldPhone) {
      promptAction.showToast({ message: '手机号不能为空' });
      return
    }
    if (this.userInfoModel.authorPhone !== oldPhone) {
      promptAction.showToast({ message: '旧手机号不正确' });
      return
    }
    // 验证验证码（这里应该是调用实际的验证接口）
    if (!verifyCode) {
      promptAction.showToast({ message: '验证码不能为空' });
      return
    }
    // 验证后去更新手机号

    RouterUtils.pushPathByName(RouterMap.SETTING_CHANGE_PHONE_NEXT)
  }

  changeLoginPhoneNext(newPhone: string, verifyCode: string) {

    if (!newPhone) {
      promptAction.showToast({ message: '新手机号不能为空' });
      return
    }
    if (!this.isPhoneNumberValid(newPhone)) {
      promptAction.showToast({ message: '新手机号格式不正确' });
      return;
    }
    // 验证验证码（这里应该是调用实际的验证接口）
    if (!verifyCode) {
      promptAction.showToast({ message: '验证码不能为空' });
      return
    }
    // 更新手机号
    this.userInfoModel.authorPhone = newPhone;
    promptAction.showToast({ message: '手机号更换成功,请重新登录' });
    this.accountInstance.signOut().then(() => {
      RouterUtils.popToName(RouterMap.INDEX_PAGE);
    })
  }

  async confirmPhone(oldPhone: string, verifyCode: string) {
    if (!this.isPhoneNumberValid(oldPhone)) {
      promptAction.showToast({ message: '手机号格式不正确' });
      return;
    }
    if (!verifyCode) {
      promptAction.showToast({ message: '验证码不能为空' });
      return
    }

    let isCanCancel: boolean = false
    isCanCancel = await this.verifyIsDoneAllLoan()
    if (isCanCancel) {
      promptAction.showToast({ message: '请先结清相关贷款业务后再进行注销' });
      return
    }
    this.isLoading = true;
    this.accountInstance.signOut()
      .then(() => {
        promptAction.showToast({ message: '账号已注销' });
        RouterUtils.popToName(RouterMap.INDEX_PAGE);
      })
      .finally(() => {
        this.isLoading = false;
      });
  }


  getLocationLabel() {
    return `${this.location}M`;
  }

  //校验是否存在未完成的贷款
  async verifyIsDoneAllLoan() {
    let isCanCancel: boolean = false
    let loanRecordList: LoanProduct[] = [];
    loanRecordList = await LoanServiceApi.queryLoan()
    isCanCancel = loanRecordList.map((item: LoanProduct) => item.loanStatus).some((item: number) => {
      return item === LoanStatusEnum.Auditing || item === LoanStatusEnum.Disbursing || item === LoanStatusEnum.Repaying
    })
    return isCanCancel
  }

  // 启动倒计时
  startCountdown(useType: 'changePhone' | 'cancelUser', needNewPhone: boolean = false, needOldPhone: boolean = false) {
    //启动前先判断 原手机号是否一致 和新手机号的格式
    if (this.userInfoModel.authorPhone !== this.oldPhone && needOldPhone) {
      promptAction.showToast({ message: useType === 'changePhone' ? '旧手机号不正确' : '绑定的手机号不匹配' });
      this.codeBtnDisabled = false
      return
    }
    if (useType === 'changePhone' && needNewPhone) {
      if (!this.isPhoneNumberValid(this.newPhone)) {
        promptAction.showToast({ message: '新手机号格式不正确' })
        this.codeBtnDisabled = false
        return
      }
    }
    this.codeBtnDisabled = true
    this.verifyCodeTime = 60
    this.codeBtnText = `${this.verifyCodeTime}s后重新获取`
    // 清除旧定时器
    if (this.timerID) {
      clearInterval(this.timerID)
    }
    this.timerID = setInterval(() => {
      this.verifyCodeTime--
      this.codeBtnText = `${this.verifyCodeTime}s后重新获取`
      if (this.verifyCodeTime <= 0) {
        clearInterval(this.timerID!)
        this.codeBtnText = '获取验证码'
        this.codeBtnDisabled = false
      }
    }, 1000)
  }
}