/**
 * 用户信息
 */
@ObservedV2
export class UserInfoModel {
  @Trace authorUid: string = '';
  @Trace authorNickName: string = '';
  @Trace authorDesc: string = '';
  @Trace watchersCount: number = 0;
  @Trace authorIcon: string = '';
  @Trace watchers: string[] = [];
  @Trace authorPhone: string = '';
  @Trace loginChannel: string = '';
  @Trace authorIp: string = '';
  @Trace likeNum: number = 0;
  @Trace followersCount: number = 0;
  @Trace followers: string[] = [];
  @Trace authorId: string = '';
  @Trace isLogin: boolean = false;
}