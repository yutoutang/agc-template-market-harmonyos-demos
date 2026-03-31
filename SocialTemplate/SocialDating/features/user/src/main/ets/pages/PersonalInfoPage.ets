import { PersonalInfo, PersonalInfoView, DataType, SwitchInfo, ApiHandler, GenderType } from 'collect_personal_info';
import { MockService } from 'commons';

@Builder
export function PersonalInfoPageBuilder() {
  PersonalInfoPage()
}

@ComponentV2
struct PersonalInfoPage {
  @Local switchInfo: SwitchInfo = {
    showAvatar: true,
    showNickName: true,
    showFullName: true,
    showGender: true,
    showBirthDate: true,
    showPhoneNumber: true,
    showIntroDesc: true,
  };
  @Local personalInfo: PersonalInfo = {
    avatar: MockService.account.avatar,
    nickName: MockService.account.nickname,
    gender: MockService.account.sex,
    birthDate: MockService.account.birthday,
    phoneNumber: MockService.account.phone,
    introDesc: '在自己的小世界里，做一个快乐的普通人，把节奏放慢，享受生活！十六岁的青春张扬 十八岁的未来可期，携零零碎碎的美好奔赴未知的将来！',
  };
  @Local apiInfo: ApiHandler = {
    updateAvatar: (param: Object) => new Promise((resolve) => resolve()),
    updateNickName: (param: Object) => new Promise((resolve) => resolve()),
    updateGender: (param: Object) => new Promise((resolve) => resolve()),
    updateBirth: (param: Object) => new Promise((resolve) => resolve()),
    updateFullName: (param: Object) => new Promise((resolve) => resolve()),
    updateIntro: (param: Object) => new Promise((resolve) => resolve()),
    updatePhoneInfo: {
      codeLength: 6,
      sendCode: (phone: string) => {
        return new Promise((resolve, reject) => {
          setTimeout(() => {
            this.getUIContext().getPromptAction().showToast({ message: `验证码${phone.slice(0, 6)}` });
            resolve()
          }, 1000)
        })
      },
      verifyCode: (phone: string, code: string) => {
        return new Promise((resolve, reject) => {
          setTimeout(() => {
            let result: boolean = (code === phone.slice(0, 6)) ? true : false;
            this.getUIContext().getPromptAction().showToast({ message: result ? '验证成功' : '验证失败' });
            resolve(result);
          }, 1000)
        })
      },
    },
  };

  build() {
    NavDestination() {
      Column() {
        PersonalInfoView({
          switchInfo: this.switchInfo,
          personalInfo: this.personalInfo,
          apiInfo: this.apiInfo,
          onChange: (type: DataType, data: PersonalInfo) => {
            console.log('personal info change, all data: ' + JSON.stringify(data));
            MockService.saveAccountInfo(data.nickName as string, data.phoneNumber as string,
              data.gender as GenderType, data.birthDate as Date,
              data.avatar as ResourceStr, data.marital as string);
            this.personalInfo = data
            this.getUIContext().getHostContext()?.eventHub.emit('refreshUserInfo');
          },
        })
      }
      .width('100%')
      .height('100%')
      .padding(16)
    }
    .title('个人信息')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}