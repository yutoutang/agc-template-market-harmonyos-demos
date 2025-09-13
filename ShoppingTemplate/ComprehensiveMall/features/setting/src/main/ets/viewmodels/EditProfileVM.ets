import { util } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import fs from '@ohos.file.fs';
import { iData, routerStack } from 'lib_foundation';
import { UserInfoModel } from 'lib_foundation/src/main/ets/models/UserInfoModel';

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
        getContext().cacheDir + `/${util.generateRandomUUID(false)}.png`;
      fs.copyFileSync(avatarFile.fd, newPath);
      this.avatar = 'file://' + newPath;
    } catch (err) {
      console.error('get photo error:' + err);
    } finally {
      if (avatarFile) {
        try {
          fs.closeSync(avatarFile);
          this.avatar = data.avatarUri!;
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
