import { SettingGroup, SettingItem, SettingType, SupportedSetting } from 'app_setting';
import { AccountUtil, DialogParams, GlobalContextUtils, RouterMap, RouterModule, UserInfo } from 'commonlib';
import { ConfirmDialogComponent } from '../components/ConfirmDialogComponent';
import { promptAction } from '@kit.ArkUI';

@ObservedV2
export class SettingsPageVM {
  @Trace wBuilder: WrappedBuilder<[DialogParams]> = wrapBuilder(ConfirmDialogComponent);
  @Trace userInfo: UserInfo = AccountUtil.getUserInfo();
  @Trace list1: SettingItem[] = [
    new SettingItem()
      .setType(SettingType.ROUTER)
      .setLabel('个人信息')
      .setClickEvent(() => {
        RouterModule.push(RouterMap.PERSON_INFO_PAGE)
      }),
  ];
  @Trace list2: SettingItem[] = [
    new SettingItem()
      .setType(SettingType.ROUTER)
      .setLabel('隐私政策')
      .setClickEvent(() => {
        RouterModule.push(RouterMap.TERMS_OF_SERVICE_PAGE)
      }),
  ];
  @Trace list3: SettingItem[] = [
    new SettingItem()
      .setType(SettingType.ROUTER)
      .setLabel('用户协议')
      .setClickEvent(() => {
        RouterModule.push(RouterMap.PRIVACY_POLICY_DETAIL_PAGE)
      }),
  ];
  @Trace list4: SettingItem[] = [
    new SettingItem()
      .setSupportedType(SupportedSetting.CLEAR_CACHE)
  ];
  @Trace group1: SettingGroup = new SettingGroup().setList(this.list1);
  @Trace group2: SettingGroup = new SettingGroup().setList(this.list2);
  @Trace group3: SettingGroup = new SettingGroup().setList(this.list3);
  @Trace group4: SettingGroup = new SettingGroup().setList(this.list4);


  logout():Promise<void> {
    return this.signOut();
  }

  public async signOut(): Promise<void> {
    return new Promise((resolve) => {
      setTimeout(() => {
        // 退出登录并清除登录信息
        this.userInfo.id = 0
        this.userInfo.avatar = ''
        this.userInfo.name = ''
        this.userInfo.nickname = ''
        this.userInfo.sex = ''
        this.userInfo.cellphone = ''
        this.userInfo.birthday = ''
        this.userInfo.code = ''
        this.userInfo.isLogin = false
        GlobalContextUtils.showToast({ message: '退出成功~！' });
        RouterModule.pop();
        resolve();
      }, 500);
    });
  }
}