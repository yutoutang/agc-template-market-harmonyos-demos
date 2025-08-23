import { AppStorageV2 } from '@kit.ArkUI';
import { UserInfo } from 'module_base';

const TAG = '[PersonalInformationVM]';

@ObservedV2
export class PersonalInformationVM {
  private static _instance: PersonalInformationVM;
  @Trace isLogin: boolean = false
  @Trace avatar: string = ''
  @Trace userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;

  @Monitor('userInfo.id')
  onChange(monitor: IMonitor) {
    const id = monitor.value()?.now as number;
    this.checkLogin(id)
  }

  checkLogin(id: number) {
    if (id === 0) {
      this.isLogin = false
    } else {
      this.isLogin = true
    }
  }

  init() {
    this.avatar = this.userInfo.avatar
  }

  modify() {
    if (!this.userInfo) {
      return
    }
    this.userInfo.avatar = this.avatar
  }

  public static get instance() {
    if (!PersonalInformationVM._instance) {
      PersonalInformationVM._instance = new PersonalInformationVM();
    }
    return PersonalInformationVM._instance;
  }
}
