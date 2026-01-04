import { promptAction, window } from '@kit.ArkUI';
import { BaseViewModel, BreakpointNameEnum, FileUtils, Logger, PhoneNumberUtils, RouterUtils } from 'lib_common';

const TAG = '[SettingPersonalVM]';

@ObservedV2
export class SettingPersonalVM extends BaseViewModel {
  @Trace nickName: string = this.userInfoModel.userNickName;
  @Trace contactPhone: string = this.userInfoModel.userPhone;
  @Trace personalDesc: string = this.userInfoModel.userDesc;
  @Trace showNickNameSheet: boolean = false;
  @Trace showPersonDescSheet: boolean = false;
  @Trace showPhoneSheet: boolean = false;
  @Trace hasModify: boolean = false;
  @Trace keyHeight: number = 0;
  readonly defaultSheetH: SheetSize | Length = SheetSize.LARGE;

  modifyNickName() {
    if (!this.nickName) {
      promptAction.showToast({ message: '昵称不能为空' });
      return
    }
    this.userInfoModel.userNickName = this.nickName;
    this.showNickNameSheet = false;
    this.hasModify = true;
  }

  modifyContactPhone() {
    if (!this.contactPhone) {
      promptAction.showToast({ message: '手机号码不能为空' });
      return;
    }
    if (!PhoneNumberUtils.isPhoneNumberValid(this.contactPhone)) {
      promptAction.showToast({ message: '请输入正确的手机号码' });
      return;
    }
    this.userInfoModel.userPhone = PhoneNumberUtils.encryptPhone(this.contactPhone);
    this.showPhoneSheet = false;
    this.hasModify = true;
  }

  modifyPersonalDesc() {
    this.userInfoModel.userDesc = this.personalDesc;
    this.showPersonDescSheet = false;
    this.hasModify = true;
  }

  saveUserIcon(uri: string) {
    if (!uri) {
      return;
    }
    const resp = FileUtils.handleUri(uri);
    Logger.info(TAG, 'user icon saved success, url:' + resp);
    this.userInfoModel.userIcon = resp;
    this.hasModify = true;
  }

  customBack() {
    RouterUtils.pop(this.hasModify ? 'modify-flag' : undefined);
  }

  registerKeyboard() {
    try {
      window.getLastWindow(getContext()).then(currentWindow => {
        currentWindow.on('avoidAreaChange', this.cb);
      })
    } catch (err) {
      Logger.error(TAG, `register keyboard error, code: ${err.code}, message: ${err.message}`);
      return
    }
  }

  unRegisterKeyboard() {
    try {
      window.getLastWindow(getContext()).then(currentWindow => {
        currentWindow.off('avoidAreaChange', this.cb);
      })
    } catch (err) {
      Logger.error(TAG, `unregister keyboard error, code: ${err.code}, message: ${err.message}`);
      return
    }
  }

  cb: (data: window.AvoidAreaOptions) => void = (data) => {
    if (data.type === window.AvoidAreaType.TYPE_KEYBOARD) {
      this.keyHeight = px2vp(data.area.bottomRect.height);
      if (this.keyHeight > 0 &&
      [BreakpointNameEnum.MD, BreakpointNameEnum.LG].includes(this.breakPointModel.currentBreakpoint)) {
        // 减去居中弹窗底部高度
        this.keyHeight -= 100;
      }
    }
  }
}