/**
 * 用户信息
 */
@ObservedV2
export class UserInfoModel {
  @Trace isLogin: boolean = false;
  @Trace userId: string = '';
  @Trace userNickName: string = '';
  @Trace userIcon: string = '';
  @Trace userDesc: string = '';
  @Trace userPhone: string = '';
  @Trace userIp: string = '';
  @Trace loginChannel: string = '';
  @Trace isVip: boolean = false
}