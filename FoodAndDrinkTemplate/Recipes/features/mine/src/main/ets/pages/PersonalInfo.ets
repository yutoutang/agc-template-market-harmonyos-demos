import fs from '@ohos.file.fs';
import { MinePageVM } from '../viewModels/MinePageVM';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { buildTitleBar, Logger } from 'commonlib';
import { util } from '@kit.ArkTS';
import { LengthMetrics } from '@kit.ArkUI';

@Builder
export function PersonalInfoBuilder() {
  PersonalInfo();
}

@Extend(Column)
function personalColumn() {
  .width('100%')
  .justifyContent(FlexAlign.SpaceBetween)
  .backgroundColor('#FFFFFF')
  .borderRadius(16)
  .padding(12);
}

@ComponentV2
struct PersonalInfo {
  vm: MinePageVM = MinePageVM.instance;
  @Local isShow: boolean = false;
  @Local nickName: string = '';

  aboutToAppear(): void {
    this.nickName = this.vm.userInfo.nickname ? this.vm.userInfo.nickname : '华为用户';
  }

  @Builder
  nickNameBuilder() {
    Column() {
      Row() {
        TextInput({
          text: this.nickName,
          placeholder: '请填写用户昵称',
        })
          .backgroundColor('#FFFFFF')
          .maxLength(10)
          .cancelButton({
            style: CancelButtonStyle.CONSTANT,
            icon: {
              size: 16,
              src: $r('app.media.clear'),
              color: '#000000',
            },
          }).onChange((value: string) => {
          this.nickName = value;
        });
      };

      Button('确定')
        .fontColor('#FFFFFF')
        .backgroundColor('#E84026')
        .width('100%')
        .margin({ left: 28, right: 28, bottom: 12 })
        .onClick(() => {
          this.vm.userInfo.nickname = this.nickName;
          this.isShow = false;
        });
    }.padding(16).height('100%')
    .justifyContent(FlexAlign.SpaceBetween);
  }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        Row() {
          Text('头像').opacity(0.9);
          Row({ space: 8 }) {
            FunctionalButton({
              params: {
                openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
                label: '',
                styleOption: {
                  styleConfig: new functionalButtonComponentManager.ButtonConfig()
                    .type(ButtonType.Circle)
                    .backgroundImage(this.vm.userInfo.avatar ?
                      this.vm.userInfo.avatar.startsWith('file://') ? this.vm.userInfo.avatar :
                      $r(`app.media.${this.vm.userInfo.avatar}`) : $r('app.media.ic_avatar'))
                    .backgroundImageSize(ImageSize.Cover)
                    .width(40)
                    .height(40)
                    .backgroundColor('#FFE5E5E5'),
                },
              },
              controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((error,
                data) => {
                if (error) {
                  return;
                }
                let avatarFile: fs.File = fs.openSync(data.avatarUri!, fs.OpenMode.READ_ONLY);
                try {
                  let newPath: string = getContext().cacheDir + `/${util.generateRandomUUID(false)}.png`;
                  fs.copyFileSync(avatarFile.fd, newPath);
                  this.vm.userInfo.avatar = 'file://' + newPath;
                } catch (err) {
                  Logger.error('choose avatar fail' + JSON.stringify(err));
                } finally {
                  fs.close(avatarFile);
                }
              }),
            });
            Image($r('app.media.ic_right')).size({ height: 26, width: 8 });
          };
        }
        .padding(12)
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor('#FFFFFF')
        .borderRadius(16);

        Column({ space: 18 }) {
          Row() {
            Text('昵称').opacity(0.9);
            Row({ space: 8 }) {
              Text(this.vm.userInfo.nickname ? this.vm.userInfo.nickname : '华为用户').fontSize(14).opacity(0.6);
              Image($r('app.media.ic_public_brush'))
                .size({ height: 24, width: 24 })
                .onClick(() => {
                  this.isShow = true;
                })
                .bindSheet($$this.isShow, this.nickNameBuilder(), {
                  height: 420, preferType: SheetType.CENTER, title: { title: '设置昵称' },
                });
            };
          }.width('100%')
          .justifyContent(FlexAlign.SpaceBetween);

          Divider().margin({ top: 18, bottom: 18 });

          Row() {
            Text('电话').opacity(0.9);
            Row({ space: 8 }) {
              Text('100****0000').fontSize(14).opacity(0.6);
            };
          }.width('100%')
          .justifyContent(FlexAlign.SpaceBetween);
        }.personalColumn();
      }
      .height('100%')
      .backgroundColor('#F1F3F5')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .padding({ top: 12, left: 16, right: 16 });
    }
    .title(buildTitleBar('个人信息'), { paddingStart: LengthMetrics.vp(16) });
  }
}