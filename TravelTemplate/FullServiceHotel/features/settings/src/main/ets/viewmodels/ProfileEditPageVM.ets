import { promptAction } from '@kit.ArkUI';
import { AccountUtil, Logger, MemberInfoModel, RouterModule, UserInfoModel } from 'commonlib';
import { UpdateUserInfoRequest, BaseResponse, https } from 'network';
import { EditDialogType } from '../commons/Enums';
import { BusinessError } from '@kit.BasicServicesKit';
import { functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { util } from '@kit.ArkTS';
import fs from '@ohos.file.fs';

const TAG: string = '[ProfileEditPageVM]'

@ObservedV2
export class ProfileEditPageVM {
  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();
  @Trace newUserInfo: UserInfoModel = new UserInfoModel();
  @Trace editType: EditDialogType = EditDialogType.NICKNAME;
  @Trace loading: boolean = false;
  private static _instance: ProfileEditPageVM;

  public static get instance() {
    if (!ProfileEditPageVM._instance) {
      ProfileEditPageVM._instance = new ProfileEditPageVM();
    }
    return ProfileEditPageVM._instance;
  }

  public getAvatar(error: BusinessError, data: functionalButtonComponentManager.ChooseAvatarResult) {
    if (error) {
      return;
    }
    let avatarFile: fs.File | null = null;
    try {
      avatarFile = fs.openSync(data.avatarUri!, fs.OpenMode.READ_ONLY);
      let newPath: string = getContext().cacheDir + `/${util.generateRandomUUID(false)}.png`;
      fs.copyFileSync(avatarFile.fd, newPath);
      this.newUserInfo.avatar = 'file://' + newPath;
    } catch (err) {
      Logger.error(TAG, 'get photo error:' + err);
    } finally {
      if (avatarFile) {
        fs.closeSync(avatarFile);
      }
    }
  }

  public getEditStr() {
    if (this.editType === EditDialogType.NICKNAME) {
      return this.newUserInfo.nickname ?? '';
    } else if (this.editType === EditDialogType.NAME) {
      return this.newUserInfo.name ?? '';
    } else {
      return this.newUserInfo.cellphone ?? '';
    }
  }

  public cloneUserInfo() {
    this.newUserInfo.avatar = this.userInfo.avatar;
    this.newUserInfo.name = this.userInfo.name;
    this.newUserInfo.nickname = this.userInfo.nickname;
    this.newUserInfo.cellphone = this.userInfo.cellphone;
    this.newUserInfo.avatar = this.userInfo.avatar;
    this.newUserInfo.memberInfo = new MemberInfoModel(this.userInfo.memberInfo);
  }

  public async updateUserInfo() {
    this.loading = true;
    const profileInfo: UpdateUserInfoRequest = {
      id: this.userInfo.id,
      name: this.newUserInfo.name ?? '',
      nickname: this.newUserInfo.nickname ?? '',
      avatar: this.newUserInfo.avatar ?? '',
    };
    const res: BaseResponse = await https.updateHotelUserInfo(profileInfo);
    if (res.code === 0) {
      AccountUtil.updateUserInfo(this.newUserInfo);
      const timer = setTimeout(() => {
        RouterModule.pop();
        promptAction.showToast({ message: '修改成功!' });
        this.loading = false;
        clearTimeout(timer);
      }, 500);
    }
  }
}
