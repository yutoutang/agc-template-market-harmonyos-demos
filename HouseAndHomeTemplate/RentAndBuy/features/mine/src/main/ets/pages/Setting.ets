import {
  AppStorageBank,
  AvoidAreaUtil,
  Constant,
  EventEmitName,
  RouterModule,
  SettingInfoModule,
  TitleBar,
} from 'foundation';
import { SETTING_INFO_ITEMS } from '../constant/Contants';
import { common } from '@kit.AbilityKit';

@Builder
export function SettingBuilder() {
  Setting();
}

@ComponentV2
export struct Setting {
  logout() {
    AppStorageBank.setUserInfo(AppStorageBank.getUserInfo().nickName, AppStorageBank.getUserInfo().avatar, '', '');
    (this.getUIContext().getHostContext() as common.UIAbilityContext).eventHub.emit(EventEmitName.UPDATE_AVATAR);
    RouterModule.stack.pop();
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          TitleBar({ title: '个人设置' });

          Column({ space: 12 }) {
            ForEach(SETTING_INFO_ITEMS, (item: SettingInfoModule) => {
              Row() {
                Text(item.type).opacity(0.9).fontColor($r('sys.color.black'));
                Image($r('app.media.ic_right')).size({ width: 16, height: 16 });
              }
              .width(Constant.FULL_PERCENT)
              .height(61)
              .justifyContent(FlexAlign.SpaceBetween)
              .padding(18)
              .onClick(item.clickEvent)
              .backgroundColor($r('sys.color.white'))
              .borderRadius(16);
            }, (item: SettingInfoModule) => item.type);
          }.padding(16);
        };

        Button('退出登录')
          .width('calc(100% - 48vp)')
          .backgroundColor('rgba(0,0,0,0.60)')
          .fontColor($r('sys.color.white'))
          .margin({ bottom: AvoidAreaUtil.getTopHeight() })
          .fontWeight(500)
          .onClick(() => {
            this.logout();
          });
      }.backgroundColor('#F1F3F5').height(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
    }.hideTitleBar(true);
  }
}