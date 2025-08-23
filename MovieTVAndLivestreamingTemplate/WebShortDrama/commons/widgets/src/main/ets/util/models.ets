export interface UserInfo {
  id?: string;
  isPhoneAssociated?: boolean;
  avatar?: string;
  nickname?: string;
  cellphone?: string;
  isMock?: boolean;
  isVip?: boolean;
  bonus?: number;
  vipExpiryDate?: Date | null; //  VIP 到期时间
}

@ObservedV2
export class UserInfoModel implements UserInfo {
  @Trace id: string = '';
  @Trace isPhoneAssociated: boolean = false;
  @Trace isMock: boolean = false;
  @Trace avatar: string = '';
  @Trace nickname: string = '';
  @Trace cellphone: string = '';
  @Trace isVip: boolean = false;
  @Trace bonus: number = 0
  @Trace vipExpiryDate: Date  = new Date();
  @Trace channels: Set<string> = new Set()
  @Trace category: Set<string> = new Set()
}

@ObservedV2
export class AccountModel {
  @Trace idToken: string = '';
  @Trace openID: string = '';
  @Trace unionID: string = '';
  @Trace authCode: string = '';
  @Trace loginToken: string = '';
}