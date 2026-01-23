import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  FileUtils,
  Logger,
  UserInfo,
  ErrorCode,
  getAccountErrorMsg,
  CommonTipDialog
} from 'commonlib';

const TAG = '[SettingPersonalVM]';

@ObservedV2
export class PersonalVM {
  @Trace loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!
  @Trace showNickNameSheet: boolean = false;
  @Trace showAgeSheet: boolean = false;
  @Trace showHeightSheet: boolean = false;
  @Trace showGenderSheet: boolean = false;
  @Trace showWeightSheet: boolean = false;
  @Trace showPurposeSheet: boolean = false;
  @Trace showBodySheet: boolean = false;
  @Trace showPersonDescSheet: boolean = false;
  @Trace showPhoneSheet: boolean = false;
  @Trace hasModify: boolean = false;
  @Trace sheetType: SheetType = SheetType.BOTTOM;
  readonly defaultSheetH: SheetSize | Length = SheetSize.LARGE;

  saveUserIcon(uri: string) {
    if (!uri) {
      return;
    }
    const resp = FileUtils.handleUri(uri);
    Logger.info(TAG, 'user icon saved success, url:' + resp);
    this.loginUser.avatar = resp
    this.hasModify = true;
  }

  handleAvatarError(error: BusinessError) {
    Logger.error(TAG, 'onChooseAvatar failed, error: ' + JSON.stringify(error));
    if (error.code === ErrorCode.ERROR_CODE_CANCEL) {
      return;
    }
    let errorMsg: string = getAccountErrorMsg(error.code);

    CommonTipDialog.show({
      primaryTitle: '温馨提示',
      content: errorMsg,
      priBtnV: '确定',
    })
  }
}