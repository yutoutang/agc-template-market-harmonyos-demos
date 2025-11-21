import { util } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import fs from '@ohos.file.fs';
import { iData, routerStack } from 'lib_foundation';
import { UserInfoModel } from 'lib_foundation';

@ObservedV2
export class EditProfileVM {
  @Trace
  avatar: ResourceStr = '';
  @Trace
  tempNickname: string = '';
  @Trace
  nickname: string = '';
  @Trace
  userInfo: UserInfoModel = iData.global.userInfo;

  @Computed
  get displayPhone(){
    if(!this.userInfo.phone){
      return ''
    }
    return `${this.userInfo.phone.substring(0, 3)}****${this.userInfo.phone.substring(7)}`;
  }

  initData() {
    this.avatar = this.userInfo.avatar;
    this.nickname = this.userInfo.nickname;
  }

  getAvatarSrc(
    error: BusinessError,
    data: functionalButtonComponentManager.ChooseAvatarResult,
  ) {
    if (error) {
      promptAction.showToast({ message: '获取头像失败，请稍后重试' });
      return;
    }
    let avatarFile: fs.File | null = null;
    try {
      avatarFile = fs.openSync(data.avatarUri!, fs.OpenMode.READ_ONLY);
      let newPath =
        getContext().filesDir + `/${util.generateRandomUUID(false)}.png`;
      fs.copyFileSync(avatarFile.fd, newPath);
      this.avatar = 'file://' + newPath;
    } catch (err) {
      console.error('get photo error:' + err);
    } finally {
      if (avatarFile) {
        try {
          fs.closeSync(avatarFile);
        } catch (err) {
          console.error('close file failed,error:' + JSON.stringify(err));
        }
      }
    }
  }

  handleSave() {
    this.userInfo.avatar = this.avatar;
    this.userInfo.nickname = this.nickname;
    routerStack.pop();
  }
}
