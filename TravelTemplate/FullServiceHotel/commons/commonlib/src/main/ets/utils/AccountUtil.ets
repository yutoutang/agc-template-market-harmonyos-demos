import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { AppStorageMap } from '../constants/CommonEnum';
import { MemberInfo, UserInfo } from '../types/Types';

@ObservedV2
export class UserInfoModel implements UserInfo {
  @Trace id: number = 0;
  @Trace avatar: string = '';
  @Trace name: string = '';
  @Trace nickname: string = '';
  @Trace cellphone: string = '';
  @Trace memberInfo: MemberInfoModel = new MemberInfoModel();
}

@ObservedV2
export class MemberInfoModel implements MemberInfo {
  @Trace memberCardNo: string = '';
  @Trace memberClassTName: string = '';
  @Trace memberClassTLevel: string = '';
  @Trace pointBalance: string = '';

  constructor(memberInfo?: MemberInfo) {
    if (memberInfo) {
      this.memberCardNo = memberInfo.memberCardNo;
      this.memberClassTName = memberInfo.memberClassTName;
      this.memberClassTLevel = memberInfo.memberClassTLevel;
      this.pointBalance = memberInfo.pointBalance;
    }
  }
}

@ObservedV2
export class AccountUtil {
  @Trace
  public static isLogin:boolean = false
  private static _userInfo: UserInfoModel = AppStorageV2.connect(
    UserInfoModel,
    AppStorageMap.USER_INFO,
    () => new UserInfoModel(),
  )!;

  public static getUserInfo(): UserInfoModel {
    return AccountUtil._userInfo;
  }

  public static loginAccount(data: UserInfo) {
    AccountUtil.isLogin = true;
    AccountUtil._userInfo.cellphone = data.cellphone;
    AccountUtil.updateUserInfo(data);
  }

  public static updateUserInfo(data: UserInfo) {
    AccountUtil._userInfo.id = data.id;
    AccountUtil._userInfo.name = data.name;
    AccountUtil._userInfo.nickname = data.nickname;
    AccountUtil._userInfo.avatar = data.avatar;
    if (data.memberInfo) {
      AccountUtil._userInfo.memberInfo = new MemberInfoModel(data.memberInfo);
    }
  }

  public static logoutAccount() {
    AccountUtil.isLogin = false;

    promptAction.showToast({ message: '退出登录成功！' })
  }
}
