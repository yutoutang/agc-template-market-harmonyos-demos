import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { UserInfo } from '../model/UserInfo';
import { rightArrow } from '../components/RightArrow';
import { promptAction } from '@kit.ArkUI';


@Builder
export function UserInfoBuilder() {
  UserInfoPage();
}

@ComponentV2
export struct UserInfoPage {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Local isShow: boolean = false;
  private userInfo : UserInfo = UserInfo.instance;
  @Local nickName: string = this.userInfo.userName;

  @Builder
  nickNameBuilder() {
    Column() {
      TextInput({
        text: this.userInfo.userName,
        placeholder: '请输入昵称',
      })
        .backgroundColor($r('sys.color.comp_background_list_card'))
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
        .fontColor($r('sys.color.font_primary'))
        .backgroundColor($r('sys.color.warning'))
        .width('100%')
        .margin({ left: 28, right: 28 })
        .enabled(!!this.userInfo.userName.trim())
        .onClick(() => {
          const trimmedName = this.nickName.toString().trim();
          if (!trimmedName) {
            this.getUIContext().getPromptAction().showToast({
              message: '昵称不能为空或空格',
              alignment: Alignment.Bottom
            })
            return;
          }
          this.userInfo.userName = trimmedName;
          this.isShow = false;
        });
    }
    .padding(16)
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
  build() {
    NavDestination() {
      Column({ space: 16 }) {
        Row() {
          Text('头像')
            .fontSize(16)
            .layoutWeight(1)
            .lineHeight(22)
            .padding({
              left: 12,
            });

          FunctionalButton({
            params: {
              openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
              label: '',
              styleOption: {
                styleConfig: new functionalButtonComponentManager.ButtonConfig()
                  .type(ButtonType.Circle)
                  .backgroundImage(this.userInfo.userAvatar)
                  .backgroundImageSize(ImageSize.Cover)
                  .width(40)
                  .height(40)
              },
            },
            controller: new functionalButtonComponentManager.FunctionalButtonController()
              .onChooseAvatar((error, data) => {
                if (error) {
                  return;
                }
                this.userInfo.userAvatar = data.avatarUri ? data.avatarUri : this.userInfo.userAvatar;
              }),
          })
            .margin({
              right: 6,
            });

          Row() {
            rightArrow();
          }
          .margin({
            right: 8,
          });
        }
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .height(56)
        .borderRadius(16)
        .margin({ top: 16 });

        Column() {
          Row() {
            Text('昵称').opacity(0.9);
            Row() {
              Text(this.userInfo.userName).fontSize(14).opacity(0.6)
                .margin({
                  right: 6,
                });
              Image($r('app.media.ic_public_brush'))
                .fillColor($r('sys.color.font_secondary'))
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
              Text(this.userInfo.phone).fontSize(14).opacity(0.6);
            };
          }.width('100%')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .padding(12)
        .width('100%')
        .height(116)
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .borderRadius(16)
      }
      .backgroundColor($r('sys.color.background_secondary'))
      .height('100%')
      .padding({
        left: 16,
        right: 16,
      });
    }
    .title('个人信息')
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });
  }
}