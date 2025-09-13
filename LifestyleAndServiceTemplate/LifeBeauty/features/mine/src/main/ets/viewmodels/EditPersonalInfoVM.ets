import { BusinessError } from '@kit.BasicServicesKit';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import {
  CommonUtils,
  GetUserInfoResp,
  Logger,
  RouterModule,
  SystemSceneUtils,
  updateUserInfo,
  ErrorCode,
} from 'foundation';

const TAG = 'EditPersonalInfoVM';

@ObservedV2
export class EditPersonalInfoVM {
  @Trace userInfo: GetUserInfoResp = AppStorageV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;
  @Trace nickName: string = this.userInfo.nickName;
  @Trace showNickNameSheet: boolean = false;

  saveUserIcon(uri: string) {
    if (!uri) {
      return;
    }
    const resp = SystemSceneUtils.handleUri(uri);
    this.userInfo.avatar = resp;
    updateUserInfo({ avatarUrl: resp });
    Logger.info(TAG, 'user icon saved success, url:' + resp);
  }

  modifyNickName() {
    if (!this.nickName) {
      promptAction.showToast({ message: '昵称不能为空' });
      return
    }
    this.userInfo.nickName = this.nickName;
    updateUserInfo({ nickName: this.nickName });
    this.showNickNameSheet = false;
  }

  handleAvatarError(error: BusinessError) {
    Logger.error(TAG, 'onChooseAvatar failed, error: ' + JSON.stringify(error));
    if (error.code === ErrorCode.EXTEND_SERVICE_USER_CANCELED) {
      return;
    }
    let errorMsg: string = this.getAccountErrorMsg(error.code);

    CommonUtils.openNoticeDialog(errorMsg, '确定');
  }

  getAccountErrorMsg(code: number) {
    if ([ErrorCode.UN_LOGIN_1, ErrorCode.UN_LOGIN_2].includes(code)) {
      return '用户未登录华为账号，请前往设置-登录华为账号。';
    }
    return '未知异常';
  }

  customBack() {
    if (this.showNickNameSheet) {
      this.showNickNameSheet = false;
      return true;
    }
    RouterModule.pop();
    return true;
  }
}