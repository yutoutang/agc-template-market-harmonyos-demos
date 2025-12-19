import { AppStorageV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import {
  AvoidAreaUtil,
  CommonUtils,
  Constant,
  EventEmitName,
  PersonalInfoModule,
  RouterModule,
  UserInfo,
} from 'foundation';
import { PERSONAL_INFO_ITEMS } from '../constant/Contants';

@Builder
export function MineBuilder() {
  Mine();
}

@Extend(Row)
function settingRow() {
  .backgroundColor($r('sys.color.white'))
  .borderRadius(16)
  .width(Constant.FULL_PERCENT)
  .justifyContent(FlexAlign.SpaceBetween)
  .padding(12);
}

@ComponentV2
export struct Mine {
  @Local avatar: ResourceStr = $r('app.media.avatar');
  @Local userInfo: UserInfo = AppStorageV2.connect(UserInfo, 'UserInfo', () => new UserInfo())!;
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
    this.context.eventHub.on(EventEmitName.UPDATE_AVATAR, () => {
      this.avatar = this.userInfo.avatar;
    });
  }

  aboutToDisappear(): void {
    this.context.eventHub.off(EventEmitName.UPDATE_AVATAR);
  }

  @Builder
  infoBuilder() {
    Row() {
      Row({ space: 16 }) {
        Image(this.userInfo.uid ? this.avatar : $r('app.media.default'))
          .size({ width: 48, height: 48 })
          .borderRadius(24);
        Column({ space: 4 }) {
          Text(this.userInfo.uid ? this.userInfo.nickName : '点击登录')
            .fontColor($r('sys.color.black'))
            .fontSize(18)
            .fontWeight(500)
            .width('50%')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          if (this.userInfo.uid) {
            Row({ space: 8 }) {
              Image($r('app.media.phone')).size({ width: 16, height: 16 });
              Text(this.userInfo.phone).fontSize(12).opacity(0.6).fontColor($r('sys.color.black'));
            };
          } else {
            Text('登录后享受更多服务').fontSize(12).opacity(0.6).fontColor($r('sys.color.black'));
          }
        }.alignItems(HorizontalAlign.Start);
      };

      Image($r('app.media.ic_right')).size({ width: 12, height: 20 }).fillColor('rgba(0,0,0,0.20)');
    }
    .settingRow()
    .onClick(this.userInfo.uid ? this.updateProfile : CommonUtils.login);
  }

  build() {
    NavDestination() {
      Column() {
        Text('我的')
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .opacity(0.9)
          .fontColor($r('sys.color.black'))
          .width(Constant.FULL_PERCENT)
          .textAlign(TextAlign.Start)
          .margin({ left: 24, top: AvoidAreaUtil.getTopHeight(), bottom: 22 });

        this.infoBuilder();
        Column({ space: 12 }) {
          ForEach(PERSONAL_INFO_ITEMS, (item: PersonalInfoModule) => {
            Row() {
              Row({ space: 8 }) {
                Image(item.icon).size({ width: 24, height: 24 });
                Text(item.name).opacity(0.9).fontColor($r('sys.color.black'));
              };

              Image($r('app.media.ic_right')).size({ width: 16, height: 16 });
            }.settingRow().onClick(this.userInfo.uid ? item.clickEvent : CommonUtils.login).height(46);
          }, (item: PersonalInfoModule) => item.name);
        }.margin({ top: 12 });
      }.backgroundColor('#F1F3F5').height(Constant.FULL_PERCENT).padding(16);
    }.hideTitleBar(true);
  }

  updateProfile() {
    RouterModule.stack.pushPathByName('UserProfile', null);
  }
}