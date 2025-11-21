import { CircleShape, CustomContentDialog, PersistenceV2, promptAction } from '@kit.ArkUI';
import { BaseResponse } from '@ohos_agcit/office_attendance_network';
import { RequestProxy } from '../api/RequestProxy';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { AccountUtil, Logger, RouterMap, RouterModule } from '@ohos_agcit/office_attendance_common_lib';
import { BusinessError } from '@kit.BasicServicesKit';
import { LoginController } from '../model/LoginController';

const TAG = '[MineView]'

@ComponentV2
export struct MineView {
  @Param callback: () => void = () => {
  };
  private loginController: LoginController = LoginController.instance;

  build() {
    Column() {
      Column() {
        Row() {
          Image(this.loginController.userAvatar)
            .height(48)
            .width(48)
            .margin({ left: 10 })
            .clipShape(new CircleShape({ width: 48, height: 48 }))
          Text(this.loginController.userName)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('rgba(0,0,0,0.90)').margin({ left: 12, right:12 })
            .layoutWeight(1)
            .maxLines(2)
            .textOverflow({
              overflow:TextOverflow.Ellipsis
            })
          Blank();
          Image($r('app.media.arrow_right')).margin({ right: 12 }).height(24).width(12)
        }.width('100%').height(72).backgroundColor(Color.White).borderRadius(16)
      }.onClick(()=>{
        RouterModule.replace({ 'url': RouterMap.USER_INFO })
      })
      .margin({ top: 8 })
      .padding({
        left:16,
        right:16
      })
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      Column() {
        Row() {
          Image($r('app.media.question')).height(24).width(24).margin({ left: 10 })
          Text($r('app.string.about_us')).fontSize(16).fontWeight(FontWeight.Medium).margin({ left: 12 })
          Blank()
          Image($r('app.media.arrow_right')).margin({ right: 12 }).height(24).width(12)
        }.width('100%')
        .height(56)
        .backgroundColor(Color.White)
        .borderRadius(16)
      }
      .onClick(() => {
        RouterModule.replace({ 'url': RouterMap.ABOUT })
      })
      .padding({
        left:16,
        right:16
      })
      .width('100%')
      .margin({ top: 20 }).alignItems(HorizontalAlign.Center)

      Column() {
        Row() {
          Image($r('app.media.tools')).height(24).width(24).margin({ left: 10 })
          Text($r('app.string.tools')).fontSize(16).fontWeight(FontWeight.Medium).margin({ left: 12 })
          Blank()
          Image($r('app.media.arrow_right')).margin({ right: 12 }).height(24).width(12)
        }.width('100%')
        .height(56)
        .backgroundColor(Color.White)
        .borderRadius(16)
      }
      .onClick(() => {
        RouterModule.replace({ 'url': RouterMap.TOOLS })
      })
      .padding({
        left:16,
        right:16
      })
      .width('100%')
      .margin({ top: 12 }).alignItems(HorizontalAlign.Center)
    }.width('100%').height('100%').backgroundColor($r('app.color.mine_background')).align(Alignment.Top)
  }

  getAvatar(): string | Resource {
    if (AccountUtil.getUserInfo().avatar === undefined) {
      return $r('app.media.ic_user_default');
    }

    return AccountUtil.getUserInfo().avatar as string
  }

  getNickName(): string | Resource {
    if (AccountUtil.getUserInfo().nickname === undefined) {
      return $r('app.string.account_name')
    }

    return AccountUtil.getUserInfo().nickname as string;
  }
}