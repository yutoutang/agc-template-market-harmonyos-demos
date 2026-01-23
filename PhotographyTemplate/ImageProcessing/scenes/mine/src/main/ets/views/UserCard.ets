import { AppStorageV2, CircleShape } from '@kit.ArkUI';
import { RouterMap, RouterModule, UserInfo } from 'commonlib';
import { UserInfoRouter } from '../model/UserInfoModel';


@ComponentV2
export struct UserCard {
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  @Local userInfoRouter: UserInfoRouter = UserInfoRouter.instance;

  build() {
    Row() {
      Image(this.loginUser.isLogin ?
        (this.loginUser.avatar && this.loginUser.avatar !== '') ? this.loginUser.avatar :
          $r('app.media.ic_user_default') :
        $r('app.media.avatar_no_login'))
        .width(48)
        .height(48)
        .clipShape(new CircleShape({ width: 48, height: 48 }))
        .margin({ right: 12 });
      if (this.loginUser.isLogin) {
        Column() {
          Text(
            this.loginUser.name)
            .fontSize(18)
            .fontWeight(FontWeight.Medium);
        }
        .height('100%')
        .justifyContent(FlexAlign.SpaceAround)
        .alignItems(HorizontalAlign.Start);

        Column() {
          Row() {
            Image(this.userInfoRouter.isVip ? $r('app.media.vip') : $r('app.media.no_vip'))
              .width(12)
              .height(12)
              .margin({ right: 1 });
            Text(this.userInfoRouter.isVip ? '已开通' : '未开通')
              .fontSize(10);
          }
          .width(55)
          .height(16)
          .borderRadius(4)
          .padding(1)
          .backgroundColor($r('app.color.main_background_color'));
        }
        .margin({ left: 4 })
        .height('100%')
        .justifyContent(FlexAlign.Center);
      } else {
        Column() {
          Text('点击登录')
            .fontWeight(FontWeight.Medium)
            .fontSize(18);
        }
        .height('100%')
        .justifyContent(FlexAlign.SpaceAround)
        .alignItems(HorizontalAlign.Start)

        .height('100%')
        .justifyContent(FlexAlign.Center);
      }
      Blank();
      Column() {
        Image($r('app.media.forward'))
          .width(14)
          .height(14);
      };
    }
    .width('100%')
    .height(72)
    .padding(12)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .onClick(() => {
      if (this.loginUser.isLogin) {
        // 跳转个人信息页面
        RouterModule.push({ url: RouterMap.PERSONAL_INFO_PAGE });
      } else {
        RouterModule.push({ url: RouterMap.LOGIN_PAGE, param: true });
      }
    });
  }
}