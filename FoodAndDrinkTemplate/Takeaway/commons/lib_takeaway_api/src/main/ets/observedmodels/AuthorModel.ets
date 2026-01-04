import { AuthorResponse } from '../params/response/AuthorResponse'

@ObservedV2
export class AuthorModel implements AuthorResponse {
  @Trace authorId: string
  @Trace authorNickName: string
  @Trace authorIcon: string
  @Trace authorMemberGrade: string
  @Trace authorMemberGradeEXP: number
  @Trace authorDesc: string
  @Trace authorIp: string
  @Trace watchersCount: number
  @Trace followersCount: number
  @Trace likeNum: number
  @Trace watchers: string[]
  @Trace followers: string[]
  @Trace authorPhone: string

  constructor(v: AuthorResponse) {
    this.authorId = v.authorId;
    this.authorNickName = v.authorNickName;
    this.authorPhone = v.authorPhone || '';
    this.authorIcon = v.authorIcon;
    this.authorMemberGrade = v.authorMemberGrade;
    this.authorMemberGradeEXP = v.authorMemberGradeEXP;
    this.authorDesc = v.authorDesc;
    this.authorIp = v.authorIp;
    this.watchersCount = v.watchersCount;
    this.followersCount = v.followersCount;
    this.likeNum = v.likeNum;
    this.watchers = v.watchers || [];
    this.followers = v.followers || [];
  }
}