import { promptAction } from '@kit.ArkUI';
import { GetUserInfoResp, https } from 'network';
import { FormatUtil, AccountUtil, UserInfo, Logger } from 'commonlib';
import { RecommendListItem, Contacts } from '../types/Index';


const TAG = '[MinePageVM]';

@ObservedV2
export class MinePageVM {
  @Trace bannerUrl: string = '';
  // 精彩推荐
  @Trace recommendList: RecommendListItem[] = [];
  @Trace privacyText: string[][] = [];
  // 联系人列表
  @Trace contactList: Contacts[] = [];
  // 联系人信息
  @Trace contactInfo: Contacts | undefined = undefined;
  @Trace userInfo: UserInfo = AccountUtil.getUserInfo();
  // 将要删除的联系人id
  @Trace delPersonId: string = '';
  @Trace titleBgOpacity: number = 0;
  private static _instance: MinePageVM;

  public static get instance() {
    if (!MinePageVM._instance) {
      MinePageVM._instance = new MinePageVM();
    }
    return MinePageVM._instance;
  }

  public getRecommendList() {
    https.getRecommendList().then(res => {
      if (res.code === 0) {
        res.data.forEach((item: RecommendListItem, index) => {
          const img = FormatUtil.getImgResource(item.img);
          this.recommendList.push({
            id: item.id,
            price: item.price,
            img: img,
            name: item.name,
            detail: item.detail,
          });
        });
      }
    });
  }


  isBindPhone() {
    return this.userInfo?.cellphone !== '';
  }

  public async getPrivacyText() {
    const res = await https.getPrivacyText();
    if (res.code === 0) {
      this.privacyText = res.data;
    }
  }


  public async getBannerImg() {
    const res = await https.getBannerImg({ pageType: 2 });
    if (res.code === 0) {
      this.bannerUrl = res.data as string;
    }
  }

  public updateUserInfo(data: GetUserInfoResp) {
    const info: UserInfo = {
      avatar: data.avatar,
      name: data.name,
      nickname: data.nickname,
      sex: data.sex,
      cellphone: data.cellphone,
      birthday: data.birthday,
      id: data.id,
    };
    AccountUtil.updateUserInfo(info);
  }

  // 绑定后更新用户信息
  public async reloadUserInfo() {
    const res = await https.getUserInfo();
    if (res.code === 0) {
      this.updateUserInfo(res.data);
    }
  }

  public mockBindPhone() {
    AlertDialog.show({
      title: '提示',
      message: '元服务未获取phone权限或用户授权，点击确定将模拟创建关联账号？',
      height: 170,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '取消',
        action: () => {
          Logger.info(TAG, '取消模拟创建关联账号');
        },
      },
      secondaryButton: {
        value: '确定',
        action: () => {
          this.bindPone('0');
        },
      },
    });
  }


  public async bindPone(code: string | undefined) {
    if (!code) {
      return;
    }
    const res = await https.bindPhone(code);
    if (res.code === 0) {
      this.reloadUserInfo();
      promptAction.showToast({ message: '关联成功！' });
    }
  }

  public async cancelPhone() {
    const res = await https.cancelPhone();
    if (res.code === 0) {
      this.reloadUserInfo();
      promptAction.showToast({ message: '取消成功！' });
    }
  }

  public clear() {
    this.contactInfo = undefined;
  }
}