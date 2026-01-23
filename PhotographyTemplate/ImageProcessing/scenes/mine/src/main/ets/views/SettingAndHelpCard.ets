import { RouterMap, RouterModule, UserInfo } from 'commonlib'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct SettingAndHelpCard {
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!
  build() {
    Column() {
      Row() {
        Row() {
          Image($r('app.media.ic_me_feedback'))
            .width(16)
            .height(16)
            .margin({ right: 8 })
          Text('意见反馈')
            .fontSize(16)
        }

        Image($r('app.media.forward'))
          .width(13)
          .height(13)
      }
      .onClick(()=>{
        if (this.loginUser.isLogin) {
          RouterModule.push({ url: RouterMap.FEEDBACKLIST_PAGE })
        } else {
          RouterModule.push({ url: RouterMap.LOGIN_PAGE })
        }
      })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Divider()
        .margin({ top: 13, bottom: 13 })

      Row() {
        Row() {
          Image($r('app.media.setting'))
            .width(16)
            .height(16)
            .margin({ right: 8 })
          Text('设置')
            .fontSize(16)
        }

        Image($r('app.media.forward'))
          .width(13)
          .height(13)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(()=>{
        if (this.loginUser.isLogin) {
          RouterModule.push({ url: RouterMap.SETUP_PAGE })
        } else {
          RouterModule.push({ url: RouterMap.LOGIN_PAGE })
        }
      })
    }
    .width('100%')
    .padding(12)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }
}