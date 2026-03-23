@ObservedV2
export class PersonalInfo {
  authCode?: string = ''
  @Trace avatar?: ResourceStr = ''
  idToken?: string = ''
  @Trace phoneNumber?: string = ''
  @Trace userName?: string = ''
}

export enum CancelAuthState {
  SUCCESS = 1,
  ERROR = 2
}