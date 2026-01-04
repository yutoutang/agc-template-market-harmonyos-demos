/**
 * 用户信息
 */
@ObservedV2
export class UserInfoModel {
  @Trace isLogin: boolean = false;
  @Trace authorId: string = '';
  @Trace authorNickName: string = '';
  @Trace authorIcon: string = '';
  @Trace authorDesc: string = '';
  @Trace authorPhone: string = '';
  @Trace authorSex: string = '';
  @Trace authorBirthday: string = '';
  @Trace authorRegion: string = '';
  @Trace authorIp: string = '';
  @Trace watchersCount: number = 0;
  @Trace followersCount: number = 0;
  @Trace watchers: string[] = [];
  @Trace followers: string[] = [];
  @Trace likeNum: number = 0;
  @Trace loginChannel: string = '';

  static getSafeAuthorPhone(userInfo: UserInfoModel): string {
    let safePhone = ''
    if (userInfo.authorPhone) {
      safePhone = userInfo.authorPhone.slice(0, 3) + '******' +
      userInfo.authorPhone.slice(userInfo.authorPhone.length - 2, userInfo.authorPhone.length)
    }
    return safePhone
  }
}