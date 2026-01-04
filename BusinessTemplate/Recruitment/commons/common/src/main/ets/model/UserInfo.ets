import { getAppliedPositions, getCommunicatedPositions, getTotalFavoriteCount } from './PositionModel';

@ObservedV2
export class UserInfo {
  @Trace id: string = '';
  @Trace nickName: string = ''; // 昵称
  @Trace avatarUrl: string = ''; // 头像
  @Trace userSig: string = ''; // 签名
  @Trace gender: string = ''; // 性别
  @Trace age: string = ''; // 年龄
  @Trace birthday: string = ''; // 出生日期
  @Trace telephone: string = ''; // 手机号
  @Trace email: string = ''; // 邮箱
  @Trace introDesc: string = ''; // 个人简介
  @Trace isLogin: boolean = false; // 是否登录
}

export class PopInfoResult {
  phone: string = ''
  uid: string = ''
}

@ObservedV2
export class TabItem {
  @Trace text: string;
  @Trace num: number;

  constructor(text: string, num: number) {
    this.text = text
    this.num = num
  }
}

// 全局求职数据管理类
@ObservedV2
export class JobApplicationData {
  @Trace tabList: TabItem[] = [
    new TabItem('沟通过', 0),
    new TabItem('已投递', 0),
    new TabItem('待面试', 0),
    new TabItem('已收藏', 0)
  ];

  // 更新数据
  updateData() {
    this.tabList[0].num = getCommunicatedPositions().length
    this.tabList[1].num = getAppliedPositions().length
    this.tabList[2].num = getAppliedPositions().length
    this.tabList[3].num = getTotalFavoriteCount()
  }
}