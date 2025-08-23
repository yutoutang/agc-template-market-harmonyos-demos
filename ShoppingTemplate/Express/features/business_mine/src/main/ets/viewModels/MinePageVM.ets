import { AppStorageV2 } from '@kit.ArkUI';
import { userLogin } from 'lib_foundation';
import { AppStorageBank, IUserInfo, UserInfo } from 'module_base'

@ObservedV2
export class MinePageVM {
  private static _instance: MinePageVM;
  @Trace isLogin: boolean = false
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

  public static get instance() {
    if (!MinePageVM._instance) {
      MinePageVM._instance = new MinePageVM();
    }
    return MinePageVM._instance;
  }

  init() {
    this.checkLogin(this.userInfo.id)
  }


  public async login() {
    const res = await userLogin();
    AppStorageBank.updateUserInfo(res as IUserInfo)
  }
}
