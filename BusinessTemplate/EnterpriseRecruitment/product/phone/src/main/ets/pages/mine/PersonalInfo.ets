import fs from '@ohos.file.fs';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { util } from '@kit.ArkTS';
import { AccountUtil, AvoidArea, CommonModel, Logger, UserInfoModel } from '@ohos_agcit/common_component';
import { LeftReturnComponent ,TitleBar } from '@ohos_agcit/common_component';

import { CommonConstants } from '@ohos_agcit/common_component';
import { AppStorageV2, router } from '@kit.ArkUI';


@Builder
export function PersonalInfoBuilder() {
  PersonalInfo();
}

@Entry
@ComponentV2
struct PersonalInfo {
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local isShow: boolean = false;
  @Local nickName: string | Resource = '';
  @Local userInfo: UserInfoModel = AccountUtil.getUserInfo();
  vm: CommonModel = CommonModel.instance;

  aboutToAppear(): void {
    const userInfo = AccountUtil.getUserInfo();
    this.nickName = userInfo.nickname ? userInfo.nickname : '华为用户';
  }

  @Builder
  nickNameBuilder() {
    Column() {
      TextInput({
        text: this.nickName,
        placeholder: '请输入昵称',
      })
        .backgroundColor('#FFFFFF')
        .maxLength(10)
        .cancelButton({
          style: CancelButtonStyle.CONSTANT,
          icon: { size: 16, color: '#000000' }
        })
        .onChange((value: string) => {
          if (value.length <= 10) {
            this.nickName = value;
          }
        });

      Button('确定')
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor('#E84026')
        .width('100%')
        .margin({ left: 28, right: 28 })
        .enabled(!!this.nickName?.toString()?.trim())
        .onClick(() => {
          const trimmedName = this.nickName.toString().trim();
          if (!trimmedName) {
            return;
          }

          const userInfo = AccountUtil.getUserInfo();
          userInfo.nickname = trimmedName;
          AccountUtil.setUserInfo(userInfo);
          this.isShow = false;
        });

      if (!this.nickName?.toString()?.trim()) {
        Text('昵称不能为空或空格')
          .fontSize(12)
          .fontColor('#FF0000')
          .margin({ top: 8 })
      }
    }
    .padding(16)
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        LeftReturnComponent()
          .onClick(() => {
            router.back();
          });
        TitleBar({ text: '个人信息' });
      }
      .height(56)
      .alignItems(VerticalAlign.Center)
      .width(CommonConstants.FULL_WIDTH)
      .alignItems(VerticalAlign.Center);

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
                  .backgroundImage(
                    (() => {
                      const avatar = AccountUtil.getUserInfo().avatar;
                      if (typeof avatar === 'string') {
                        return avatar;
                      } else {
                        return avatar || $r('app.media.user_avatar');
                      }
                    })()
                  )
                  .backgroundImageSize(ImageSize.Cover)
                  .width(40)
                  .height(40)
                  .backgroundColor('#FFE5E5E5'),
              },
            },
            controller: new functionalButtonComponentManager.FunctionalButtonController()
              .onChooseAvatar((error, data) => {
                if (error) {
                  return;
                }
                let avatarFile: fs.File = fs.openSync(data.avatarUri!, fs.OpenMode.READ_ONLY);
                try {
                  let newPath: string = getContext().cacheDir + `/${util.generateRandomUUID(false)}.png`;
                  fs.copyFileSync(avatarFile.fd, newPath);
                  const userInfo = AccountUtil.getUserInfo();
                  userInfo.avatar = 'file://' + newPath;
                  AccountUtil.setUserInfo(userInfo);
                } catch (err) {
                  Logger.error('choose avatar fail' + JSON.stringify(err));
                } finally {
                  fs.close(avatarFile);
                }
              }),
          });
          Blank()
          Image($r('app.media.ic_right_arrow_lined'))
            .width(7)
            .height(14)
            .fillColor('rgba(0,0,0,0.2)')
            .margin({ right: 12 })
        };
      }
      .padding(12)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor('#FFFFFF')
      .borderRadius(16);

      Column() {
        Row() {
          Text('昵称').opacity(0.9);
          Row() {
            Text(this.userInfo.nickname ? this.userInfo.nickname : '设置昵称').fontSize(14).opacity(0.6);
            Image($r('app.media.ic_public_brush'))
              .size({ height: 24, width: 24 })
              .onClick(() => {
                this.isShow = true;
              })
              .bindSheet($$this.isShow, this.nickNameBuilder(), {
                height: 420, title: { title: '设置昵称' },
              });
          };
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween);

        Divider().margin({ top: 18, bottom: 18 });

        Row() {
          Text('电话').opacity(0.9);
          Row() {
            Text(this.userInfo.phone ? this.userInfo.phone : '手机号码暂不展示').fontSize(14).opacity(0.6);
          };
        }.width('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .padding(12)
      .width('100%')
      .height(116)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.FULL_HEIGHT)
    .backgroundColor('#F1F3F5')
    .padding({
      top: px2vp(this.avoidArea.topRectHeight),
      left: '4%',
      right: '4%',
    });
  }
}