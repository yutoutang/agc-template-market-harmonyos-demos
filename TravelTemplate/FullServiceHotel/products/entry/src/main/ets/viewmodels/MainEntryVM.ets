import { promptAction } from '@kit.ArkUI';
import { AccountUtil, RouterModule, UserInfo, UserInfoModel } from 'commonlib';
import { GetHotelUserInfoResp, HotelUserLoginResp, https } from 'network';
import { homeViewBuilder } from '../tabs/home/views/HomeView';
import { mineViewBuilder } from '../tabs/mine/mineView/MineView';
import { vipViewBuilder } from '../tabs/vip/views/VipView';
import { TabListItem } from '../types';

@ObservedV2
export class MainEntryVM {
  // 路由栈实例
  @Trace navStack: NavPathStack = RouterModule.stack;
  // 底部tab页签列表
  public tabList: TabListItem[] = [
    {
      label: '首页',
      icon: $r('app.media.ic_home'),
      iconChecked: $r('app.media.ic_home_checked'),
      component: wrapBuilder(homeViewBuilder),
    },
    {
      label: '会员',
      icon: $r('app.media.ic_vip'),
      iconChecked: $r('app.media.ic_vip_checked'),
      component: wrapBuilder(vipViewBuilder),
    },
    {
      label: '我的',
      icon: $r('app.media.ic_mine'),
      iconChecked: $r('app.media.ic_mine_checked'),
      component: wrapBuilder(mineViewBuilder),
    },
  ];
  // 当前页签
  @Trace curIndex: number = 0;
  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();
  @Trace firstBackTime: number = 0;
  private static _instance: MainEntryVM;

  public static get instance() {
    if (!MainEntryVM._instance) {
      MainEntryVM._instance = new MainEntryVM();
    }
    return MainEntryVM._instance;
  }

  public async getLoginUserInfo() {
    const id = this.userInfo.id
    if (id) {
      const res = await https.getHotelUserInfo();
      if (res.code === 0) {
        this.updateUserInfo(res.data);
      }
    }
  }

  public updateUserInfo(data: HotelUserLoginResp | GetHotelUserInfoResp) {
    const info: UserInfo = {
      avatar: data.avatar ? data.avatar : '',
      name: data.name,
      nickname: data.nickname,
      cellphone: data.cellphone,
      id: data.id,
      memberInfo: data.memberMsg,
    };
    AccountUtil.updateUserInfo(info);
  }

  public handleBackPressed() {
    let nowTime = Date.now();
    if (nowTime - this.firstBackTime < 1500) {
      return false;
    } else {
      this.firstBackTime = nowTime;
      promptAction.showToast({ message: '再按一次退出' });
      return true;
    }
  }
}
