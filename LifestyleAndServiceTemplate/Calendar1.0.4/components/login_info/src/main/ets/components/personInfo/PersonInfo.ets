import { BaseNavTitle, BaseTextStyleModifier } from 'base_apis';
import { ThemeState, UserInfo, UserState } from '../../model/Model';
import { ThemeVM } from '../../viewModel/ThemeController';
import { AvatarFunctionButton } from '../AvatarFunctionButton'
import { promptAction } from '@kit.ArkUI';

@Builder
export function PersonInfoBuilder() {
  PersonInfo()
}

@ComponentV2
export struct PersonInfo {
  @Local userInfo: UserInfo = new UserInfo();
  @Local isEdit: boolean = false
  @Local nickName: string = this.userInfo.userName as string
  @Local avatar: string = this.userInfo.userName as string
  @Event onUserNameChange: (value: string) => void = () => {}
  @Local routerModule: NavPathStack = new NavPathStack()
  @Local themeVM: ThemeVM = ThemeVM.instance;
  NICKNAME_LENGTH:number = 8
  @Styles
  infoFancyStyle() {
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .border({
      width: { bottom: 1 },
      color: '#f5f5f5',
    })
  }

  getNavigationParams() {
    this.userInfo =
      this.routerModule.getParamByName('PersonInformation')[0] as UserInfo
    this.nickName = this.userInfo.userName as string
  }

  build() {
    NavDestination() {
      BaseNavTitle({
        title: '个人信息',
        routerModule: this.routerModule,
        titleColor: this.themeVM.titleColor,
        currentTheme: this.themeVM.selectColor,
      })
      Column() {
        Column() {
          Row() {
            Text('头像')
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Row() {
              AvatarFunctionButton({
                avatarSize: 40,
                userInfo: this.userInfo,
                isLogin: Boolean(this.userInfo.userName),
              })
              Image($r('app.media.chevron_right')).width(12).height(24)
            }
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .infoFancyStyle()
          .backgroundColor($r('sys.color.background_primary'))
          .margin({ bottom: 12, top: 12 })
          .padding(12)
          .borderRadius(16)

          Column() {
            Row() {
              Text('昵称').fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
              Row() {
                if (this.isEdit) {
                  TextInput({ text: this.nickName })
                    .showUnderline(true)
                    .width('40%')
                    .maxLength(this.NICKNAME_LENGTH)
                    .fontSize($r('sys.float.Body_M'))
                    .key('nickName_input')
                    .onChange((value) => {
                      this.nickName = value
                      this.userInfo.userName = value
                      this.onUserNameChange(value)
                    })
                    .onBlur(() => {
                      this.isEdit = false
                    })
                } else {
                  Text(this.nickName).fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.font_secondary'))
                }
                Image($r('app.media.icon_brush')).width(24).height(24)
                  .onClick(() => {
                    this.isEdit = !this.isEdit
                    setTimeout(() => {
                      focusControl.requestFocus('nickName_input');
                    }, 300)
                  })
              }
            }.justifyContent(FlexAlign.SpaceBetween).infoFancyStyle()

            Row() {
              Text('电话').attributeModifier(new BaseTextStyleModifier('font_primary/Body_M/Medium'))
              Row() {
                Text(this.userInfo.phoneNumber.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2'))
                  .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_M/Regular'))
              }
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
            .alignItems(VerticalAlign.Center)
            .padding({ top: 12, bottom: 12 })
          }
          .padding({ left: 16, right: 16 })
          .borderRadius(16)
          .backgroundColor($r('sys.color.background_primary'))
        }
      }
      .backgroundColor($r('sys.color.background_secondary'))
      .padding({
        left: 16,
        right: 16,
      })
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .hideTitleBar(true)
    .onReady((ctx) => {
      this.routerModule = ctx.pathStack
      this.getNavigationParams()
    })
  }
}
