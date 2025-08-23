@ObservedV2
export class GlobalState {
  @Trace cloudCard: boolean = false
}

@ObservedV2
export class UserInfoModel {
  @Trace phoneNumber: string = ''
  @Trace phoneToCard: string = ''
  @Trace certificateNumber: string = ''
  @Trace isLogin: boolean = false
  @Trace avatarUri: ResourceStr = $r('app.media.ic_empty')
  @Trace idToken: string = ''
  @Trace nickName: string = '华为用户'
  @Trace openID: string = ''
  @Trace unionID: string = ''
  @Trace trueName: string = ''
}