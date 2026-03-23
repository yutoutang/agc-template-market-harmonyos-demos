import { CommonRsp, Constants, LoginState, NavigationTitleBuilder,UserFullInfo } from 'commons';
import UserService from '../service/UserService';
import Logger from 'commons/src/main/ets/utils/Logger';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function ConfigPageBuilder() {
  ConfigPage()
}

@Preview
@ComponentV2
export struct ConfigPage {
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack();
  @Local userFullInfo: UserFullInfo = new UserFullInfo();
  @Local loginStateStorage : LoginState = AppStorageV2.connect(LoginState, 'LoginState', () => new LoginState())!
  @Local isPublic: boolean = true;

  build() {
    NavDestination() {
      Column() {
        this.buildPersonalInfo()
        this.buildRealNameAuth()
        this.buildPublicSettingRow()
        this.buildAccountDeregister()
      }
    }.onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack
    }).backgroundColor($r('app.color.page_background_color'))
    .title(NavigationTitleBuilder('设置'))
  }

  @Builder
  buildPersonalInfo() {
    Row() {
      Column() {
        Text('个人信息')
          .margin({ left: 12, top: 12, bottom: 12 })
          .align(Alignment.Start)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_font_color_black'))
      }
      .width('50%')
      .alignItems(HorizontalAlign.Start)

      Column() {
        Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ right: 12, top: 12, bottom: 12 })
      }
      .width('50%')
      .alignItems(HorizontalAlign.End)
    }
    .justifyContent(FlexAlign.SpaceAround)
    .margin({
      left: 16,
      right: 16,
      bottom: 12,
      top: 12
    })
    .backgroundColor(Color.White)
    .borderRadius(16)
    .height(56)
    .onClick(() => {
      if (this.loginStateStorage.loginState) {
        this.pageStack.pushPathByName('PersonalInfoPage', null);
      } else {
        this.getUIContext().getPromptAction().showToast({ message: '请先关联账号' })
      }
    })
  }

  @Builder
  buildRealNameAuth() {
    Row() {
      Column() {
        Text('实名认证')
          .margin({ left: 12, top: 12, bottom: 12 })
          .align(Alignment.Start)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_font_color_black'))
      }
      .width('50%')
      .alignItems(HorizontalAlign.Start)

      Column() {
        Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ right: 12, top: 12, bottom: 12 })
      }
      .width('50%')
      .alignItems(HorizontalAlign.End)
    }
    .justifyContent(FlexAlign.SpaceAround)
    .margin({
      left: 16,
      right: 16
    })
    .backgroundColor(Color.White)
    .borderRadius(16)
    .height(56)
    .onClick(() => {
      this.pageStack.pushPathByName('RealNameAuthPage', null, (pop: PopInfo) => {
        // this.refreshUserInfo(pop); // todo 刷新个人信息
      });
    })
  }

  @Builder
  buildPublicSettingRow() {
    Row() {
      Column() {
        Row() {
          Column() {
            Text('资料公开')
              .margin({ left: 12, top: 12, bottom: 12 })
              .align(Alignment.Start)
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_font_color_black'))
          }.width('50%').alignItems(HorizontalAlign.Start)

          Column() {
            Toggle({ type: ToggleType.Switch, isOn: this.isPublic })
              .selectedColor($r('sys.color.comp_background_emphasize'))
              .switchPointColor($r('sys.color.comp_background_primary_contrary'))
              .onChange((res: boolean) => {
                this.isPublic = res;
                if (this.userFullInfo != null && this.userFullInfo.userInfo != null) {
                  this.userFullInfo.userInfo.isPublic = this.isPublic ? Constants.YES : Constants.NO
                  UserService.updateUser(this.userFullInfo);
                }
              }).margin({ right: 12, top: 12, bottom: 12 })
          }.width('50%').alignItems(HorizontalAlign.End)

        }.justifyContent(FlexAlign.SpaceAround)

        Row() {
          Text('关闭后，其他用户无法搜索和查看您的资料')
            .align(Alignment.Start)
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('app.color.text_font_color_gray'))
            .margin({ left: 12 })
        }.margin({ bottom: 12 }).width('100%').justifyContent(FlexAlign.Start)
      }
    }.backgroundColor(Color.White)
    .margin({
      left: 16,
      right: 16,
      bottom: 12,
      top: 12
    })
    .borderRadius(16)
    .height(76)
  }

  @Builder
  buildAccountDeregister() {
    Row() {
      Column() {
        Row() {
          Column() {
            Text('相亲平台账户注销')
              .margin({ left: 12, top: 12, bottom: 12 })
              .align(Alignment.Start)
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_font_color_black'))
          }.width('50%').alignItems(HorizontalAlign.Start)

          Column() {
            Image($r('app.media.ic_right_arrow')).width(24).height(24).margin({ right: 12, top: 12, bottom: 12 })
          }.width('50%').alignItems(HorizontalAlign.End)
        }.justifyContent(FlexAlign.SpaceAround).onClick(() => {
          this.getUIContext().showAlertDialog({
            message: '确定注销？',
            autoCancel: true,
            alignment: DialogAlignment.Center,
            offset: { dx: 0, dy: -20 },
            primaryButton:
            {
              enabled: true,
              defaultFocus: true,
              style: DialogButtonStyle.HIGHLIGHT,
              value: '确定',
              action: () => {
                UserService.deleteUser(this.getUIContext(), this.userFullInfo).then((data: CommonRsp | null) => {
                  if (data != null && data.retCode === Constants.RET_SUCCESS_CODE) {
                    AppStorage.delete(Constants.CURRENT_USER_BASIC);
                    AppStorage.delete(Constants.UNION_ID);
                    AppStorage.setOrCreate(Constants.NEW_REGISTER_FLAG, true);
                    this.pageStack.pushPathByName('UserRegister', null, () => {
                      Logger.debug('ConfigPage, onUserRegisterPop');
                      this.pageStack.pop('', false);
                    });
                  }
                })
              }
            },
            secondaryButton: {
              enabled: true,
              defaultFocus: false,
              style: DialogButtonStyle.HIGHLIGHT,
              value: '取消',
              action: () => {
              }
            }
          });
        });

        Row() {
          Text('注销后，您在本相亲平台的个人资料将被删除，不可恢复，请谨慎操作')
            .align(Alignment.Start)
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('app.color.text_font_color_gray'))
            .margin({ left: 12, bottom: 12 })
            .width('86%')
        }.width('100%').justifyContent(FlexAlign.Start)
      }
    }.backgroundColor(Color.White)
    .borderRadius(16)
    .height(96)
    .margin({
      left: 16,
      right: 16
    })
  }
}