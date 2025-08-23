import { AppStorageV2 } from '@kit.ArkUI';
import { getUserInfo } from 'lib_foundation';
import { AppStorageBank, IUserInfo, UserInfo } from 'module_base'

@ObservedV2
export class QuickLoginPageVM {
  private static _instance: QuickLoginPageVM;
  @Trace userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  @Trace public openMock: boolean = true

  public static get instance() {
    if (!QuickLoginPageVM._instance) {
      QuickLoginPageVM._instance = new QuickLoginPageVM();
    }
    return QuickLoginPageVM._instance;
  }

  public async login() {
    const res = await getUserInfo();
    AppStorageBank.updateUserInfo(res as IUserInfo)
  }
}
