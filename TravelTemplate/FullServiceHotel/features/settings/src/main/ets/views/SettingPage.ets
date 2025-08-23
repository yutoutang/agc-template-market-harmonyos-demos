import { AccountUtil, RouterMap, RouterModule, UserInfoModel } from 'commonlib'
import { CommonButton, CommonConfirmDialog, CommonScroll } from 'componentlib'
import { SettingType } from '../commons/Enums'

@Builder
export function SettingPageBuilder() {
  SettingPage()
}

@ComponentV2
export struct SettingPage {
  @Local
  isLogin: boolean = AccountUtil.isLogin

  build() {
    NavDestination() {
      CommonScroll() {
        this.formItemBuilder('隐私政策', SettingType.AGREEMENT)
      }

      if (this.isLogin) {
        CommonButton({
          title: '退出登录',
          bgColor: $r('app.color.background_color_grey_light'),
          fontColor: $r('app.color.font_color_level1'),
          handleClick: () => {
            CommonConfirmDialog.show({
              primaryTitle: '提示',
              content: '确认退出登录吗?',
              confirm: () => {
                AccountUtil.logoutAccount();
                this.isLogin = AccountUtil.isLogin;
              },
            })
          },
        })
      }
    }
    .title('设置')
    .backgroundColor($r('app.color.background_color_grey'))
  }

  @Builder
  formItemBuilder(title: string, type: SettingType) {
    Row() {
      Text(title).fontColor($r('app.color.font_color_level1'))
      Image($r('app.media.ic_right_arrow')).height(16).fillColor($r('app.color.font_color_level3'))
    }
    .width($r('app.string.width_percent_full'))
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('app.color.background_color_white'))
    .borderRadius($r('app.string.border_radius_16'))
    .padding($r('app.string.padding_m'))
    .onClick(() => {
      this.handleClickSetting(type)
    })
  }

  handleClickSetting(type: SettingType) {
    switch (type) {
      case SettingType.AGREEMENT:
        RouterModule.push({ url: RouterMap.MINE_AGREEMENT })
        break
      default:
        break;
    }
  }
}
