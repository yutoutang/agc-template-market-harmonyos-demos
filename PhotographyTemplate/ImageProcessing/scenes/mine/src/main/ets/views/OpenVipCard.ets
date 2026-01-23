import { RouterMap, RouterModule, UserInfo } from 'commonlib';
import { AppStorageV2 } from '@kit.ArkUI';
import { UserInfoRouter } from '../model/UserInfoModel';

@ComponentV2
export struct OpenVipCard {
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!
  @Local userInfoRouter: UserInfoRouter = UserInfoRouter.instance
  @Monitor('userInfoRouter.isVip')

  aboutToAppear(): void {
    console.log('当前的vip状态',this.userInfoRouter.isVip);
  }


  build() {
    Row() {
      Column() {
        if (this.userInfoRouter.isVip) {
          Row(){
            Text('请查看您的会员权益')
              .fontSize(18)
          }
          .height('100%')
          .alignItems(VerticalAlign.Center)
        } else {
          Row() {
            Text('会员')
              .fontSize(18)
            Image($r('app.media.vip'))
              .width(16)
              .height(16)
              .margin(4)
            Text('订阅')
              .fontSize(18)
          }

          Text('现在订阅低至0.8元/天')
            .fontSize(12)
        }
      }
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)

      Button(this.userInfoRouter.isVip ? '会员续费' : '现在开通')
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize($r('sys.float.Body_M'))
        .height(28)
        .backgroundColor($r('sys.color.multi_color_aux_01'))
        .onClick(() => {
          if (!this.loginUser.isLogin) {
            RouterModule.push({ url: RouterMap.LOGIN_PAGE })
          } else {
            RouterModule.push({ url: RouterMap.VIP_PAGE })
          }
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundImage($r('app.media.open_vip_background'))
    .backgroundImageSize({ width: '120%', height: '100%' })
    .width('100%')
    .height(72)
    .padding(12)
    .borderRadius(16)
  }
}