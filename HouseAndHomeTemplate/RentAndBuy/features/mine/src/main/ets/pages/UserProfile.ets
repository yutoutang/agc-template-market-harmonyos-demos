import { AppStorageV2, promptAction } from '@kit.ArkUI';
import fs from '@ohos.file.fs';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import {
  AppStorageBank,
  AvatarFunctionButtonErrCode,
  AvoidAreaUtil,
  Constant,
  EventEmitName,
  Logger,
  RouterModule,
  TitleBar,
  UserInfo,
} from 'foundation';

@Builder
export function UserProfileBuilder() {
  UserProfile();
}

@Extend(Row)
function profileRow() {
  .width(Constant.FULL_PERCENT)
  .justifyContent(FlexAlign.SpaceBetween)
  .backgroundColor($r('sys.color.white'))
  .borderRadius(16)
  .padding({
    left: 12,
    right: 12,
    top: 22,
    bottom: 22,
  });
}

@ComponentV2
export struct UserProfile {
  @Local userInfo: UserInfo = AppStorageV2.connect(UserInfo, 'UserInfo', () => new UserInfo())!;
  @Local cloneNickName: string = '';
  @Local cloneAvatar: ResourceStr = '';
  @Local isShow: boolean = false;
  @Local nickName: string = '';

  aboutToAppear(): void {
    this.cloneAvatar = this.userInfo.avatar;
    this.cloneNickName = this.userInfo.nickName;
  }

  @Builder
  modifyNickNameBuilder() {
    Column() {
      TextInput({ text: this.nickName }).onChange((value: string) => {
        this.nickName = value;
      }).backgroundColor($r('sys.color.white'));

      Button('确定')
        .width('calc(100% - 48vp)')
        .backgroundColor('#64BB5C')
        .fontColor($r('sys.color.font_on_primary'))
        .margin({ bottom: AvoidAreaUtil.getTopHeight() })
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          this.isShow = false;
          this.cloneNickName = this.nickName;
        });
    }.justifyContent(FlexAlign.SpaceBetween).padding(16).height(Constant.FULL_PERCENT).backgroundColor('#F1F3F5');
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          TitleBar({ title: '个人信息' });

          Column({ space: 12 }) {
            Row() {
              Text('头像').fontWeight(500).opacity(0.9).fontColor($r('sys.color.black'));

              Row({ space: 4 }) {
                FunctionalButton({
                  params: {
                    openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
                    label: '',
                    styleOption: {
                      styleConfig: new functionalButtonComponentManager.ButtonConfig()
                        .type(ButtonType.Circle)
                        .backgroundImage(this.cloneAvatar ? this.cloneAvatar : $r('app.media.avatar'))
                        .backgroundImageSize(ImageSize.Contain)
                        .width(40)
                        .height(40)
                        .backgroundColor('#FFE5E5E5'),
                    },
                  },
                  controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((error,
                    data) => {
                    if (error) {
                      let msg = '';
                      if (error.code === AvatarFunctionButtonErrCode.ACCOUNT_NOT_LOGIN) {
                        msg = '请在设置中打开华为账号后重试';
                      }
                      this.getUIContext().getPromptAction().showToast({
                        message: msg,
                        duration: 1000,
                      });
                      return;
                    }
                    let avatarFile: fs.File = fs.openSync(data.avatarUri!, fs.OpenMode.READ_ONLY);
                    try {
                      let newPath: string = (this.getUIContext().getHostContext() as common.UIAbilityContext).cacheDir +
                        `/${util.generateRandomUUID(false)}.png`;
                      fs.copyFileSync(avatarFile.fd, newPath);
                      this.cloneAvatar = 'file://' + newPath;
                    } catch (err) {
                      Logger.error('choose avatar fail' + JSON.stringify(err));
                    } finally {
                      fs.close(avatarFile);
                    }
                  }),
                });
                Image($r('app.media.ic_right')).size({ width: 16, height: 24 });
              };
            }.profileRow().height(64);

            Row() {
              Text('昵称').fontWeight(500).opacity(0.9).fontColor($r('sys.color.black'));
              Row({ space: 4 }) {
                Text(this.cloneNickName)
                  .fontSize(14)
                  .opacity(0.6)
                  .fontColor($r('sys.color.black'))
                  .maxLines(1)
                  .width('50%')
                  .textAlign(TextAlign.End)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
                Image($r('app.media.ic_brush')).size({ width: 24, height: 24 }).onClick(() => {
                  this.nickName = this.cloneNickName;
                  this.isShow = !this.isShow;
                });
              };
            }.profileRow().height(58).bindSheet($$this.isShow, this.modifyNickNameBuilder(),
              { title: { title: '设置昵称' }, height: 420, preferType: SheetType.CENTER });
          }.padding(16);
        };

        Button('保存')
          .fontColor($r('sys.color.white'))
          .fontWeight(500)
          .backgroundColor('#64BB5C')
          .width('calc(100% - 48vp)')
          .margin({ bottom: AvoidAreaUtil.getTopHeight() })
          .padding({ left: 28, right: 28 })
          .onClick(() => {
            AppStorageBank.setUserInfo(this.cloneNickName, this.cloneAvatar, this.userInfo.phone, this.userInfo.uid);
            (this.getUIContext()
              .getHostContext() as common.UIAbilityContext).eventHub.emit(EventEmitName.UPDATE_AVATAR);
            RouterModule.pop();
          });
      }.backgroundColor('#F1F3F5').height(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
    }.hideTitleBar(true);
  }
}